"""Isolated engine checks against the actual Altis mission; never uses player saves."""
import argparse
import hashlib
import json
import re
import shutil
import socket
import subprocess
import time
import io
import zipfile
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
GAME = Path('E:/SteamLibrary/steamapps/common/Arma 3')
ERRORS = re.compile(r'Error in expression|Error position:|Error (?:Undefined variable|Missing|Type|Generic|Zero divisor)|Script .* not found|File .* line \d+.*Error|Config : some input after EndOfFile|Warning Message:.*(?:not found|cannot|No entry|not an array)|Include file .* not found', re.I)

def classify_errors(content):
    """Retain narrowly identified upstream engine/module issues separately."""
    lines=content.splitlines(); inherited=set(); notes=[]
    for i,line in enumerate(lines):
        if 'Error in expression' in line:
            block='\n'.join(lines[i:i+9])
            if 'File A3\\modules_f\\HC\\data\\scripts\\hc.sqf' in block and 'Error Undefined variable in expression: _leader' in block:
                end=next((j for j in range(i,min(i+9,len(lines))) if 'File A3\\modules_f\\HC' in lines[j]),i)
                inherited.update(range(i,end+1)); notes.append({'kind':'upstream_empty_server_HC_module','evidence':'\n'.join(lines[i:end+1])})
        if 'Warning Message: You cannot play/edit this mission;' in line and line.endswith('\\na3_characters_f'):
            inherited.add(i); notes.append({'kind':'upstream_legacy_map_addon','evidence':line})
        if line.endswith('Warning Message: Picture res\\liberation.paa not found') and i>0 and 'Shutdown normally' in lines[i-1]:
            inherited.add(i); notes.append({'kind':'engine_shutdown_picture_lookup','evidence':'\n'.join(lines[i-1:i+1])})
    return [line for i,line in enumerate(lines) if ERRORS.search(line) and i not in inherited],notes

def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--variant', choices=['default','expanded'], default='default')
    ap.add_argument('--control', choices=['pass','assertion','syntax','runtime','timeout','protocol'])
    ap.add_argument('--timeout', type=int, default=150)
    ap.add_argument('--baseline', action='store_true')
    ap.add_argument('--clients', type=int, choices=[0,1,2], default=0)
    ap.add_argument('--hold', type=int, default=0)
    ap.add_argument('--map', choices=['Altis','Malden'], default='Malden')
    ap.add_argument('--scenario', action='store_true')
    args = ap.parse_args()
    run_id = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S') + '-' + args.variant + '-' + ('baseline' if args.baseline else args.control or 'smoke')
    out = ROOT/'mybuild'/'hippo_tests'/run_id
    out.mkdir(parents=True, exist_ok=False)
    stage = out/'s'/f'Liberation_RX_T{datetime.now(timezone.utc).strftime("%H%M%S%f")}.{args.map}'
    source_root=ROOT
    if args.baseline:
        source_root=out/'upstream'
        archive=subprocess.check_output(['git','archive','--format=zip','upstream/master','core.liberation',f'maps/Liberation_RX.{args.map}'],cwd=ROOT)
        with zipfile.ZipFile(io.BytesIO(archive)) as z: z.extractall(source_root)
    shutil.copytree(source_root/'core.liberation', stage)
    shutil.copytree(source_root/'maps'/f'Liberation_RX.{args.map}', stage, dirs_exist_ok=True)
    (stage/'build_info.sqf').write_text(f'GRLIB_build_date="{run_id}"; GRLIB_build_time="test"; GRLIB_build_version="hippo-rebase-candidate";\n')
    tests=stage/'hippo_tests'; tests.mkdir()
    cases=['engine.compile','startup.server','settings.defaults','skills.toggle','damage.civilian','catalog.classification','objects.simple']
    if args.scenario: cases+=['warfare.spawn','sector.capture','warfare.cleanup']
    if args.control: cases=['control']
    if args.baseline: cases=['startup.server']
    (tests/'run.sqf').write_text((ROOT/'tools'/'hippo_testing'/'server.sqf').read_text(encoding='utf-8'),encoding='utf-8')
    if args.scenario: shutil.copy2(ROOT/'tools/hippo_testing/scenario.sqf',tests/'scenario.sqf')
    changed = subprocess.check_output(['git','-c','core.safecrlf=false','-c','core.autocrlf=false','diff','--name-only','upstream/master'], cwd=ROOT,stderr=subprocess.DEVNULL).decode().splitlines()
    changed += subprocess.check_output(['git','ls-files','--others','--exclude-standard','core.liberation'],cwd=ROOT).decode().splitlines()
    scripts=sorted({p.removeprefix('core.liberation/').replace('/','\\') for p in changed if p.startswith('core.liberation/') and p.endswith('.sqf') and 'hippo_params' not in p})
    settings=''
    if args.variant=='expanded':
        settings='GRLIB_LRX_params set ["HippoAllFactions", createHashMapFromArray [[GRLIB_PARAM_ValueKey,1]]];\n'
        p=stage/'scripts/server/fetch_params.sqf'
        p.write_text(p.read_text(encoding='utf-8-sig').replace('// Save back cleaned params',settings+'\n// Save back cleaned params'),encoding='utf-8')
    (stage/'initServer.sqf').write_text(f'HPC_testRun="{run_id}"; HPC_testVariant="{args.variant}"; HPC_testControl="{args.control or ""}"; HPC_testBaseline={str(args.baseline).lower()}; HPC_testScenario={str(args.scenario).lower()}; HPC_testScripts='+json.dumps(scripts).replace('\\\\','\\')+'; [] execVM "hippo_tests\\run.sqf";\n',encoding='utf-8')
    if args.clients:
        shutil.copy2(ROOT/'tools/hippo_testing/client.sqf',tests/'client.sqf')
        (stage/'initPlayerLocal.sqf').write_text(f'HPC_testRun="{run_id}"; [] execVM "hippo_tests\\client.sqf";\n',encoding='utf-8')
    profiles=out/'profiles'; profiles.mkdir()
    name=stage.name
    pbo=out/(name+'.pbo')
    pack=subprocess.run([str(ROOT/'build/bin/PBOConsole.exe'),'-pack',str(stage),str(pbo)],capture_output=True,text=True)
    (out/'pack.log').write_text(pack.stdout+pack.stderr,encoding='utf-8')
    if pack.returncode or not pbo.exists(): raise RuntimeError('PBO packaging failed: '+str(out/'pack.log'))
    installed=GAME/'MPMissions'/pbo.name
    if installed.exists(): raise FileExistsError(installed)
    shutil.copy2(pbo,installed)
    with socket.socket(socket.AF_INET,socket.SOCK_DGRAM) as sock:
        sock.bind(('127.0.0.1',0)); port=sock.getsockname()[1]
    config=out/'server.cfg'
    config.write_text('hostname="Hippo isolated test"; password="hippo-local-test"; passwordAdmin="hippo-test-admin"; serverCommandPassword="hippo-test-command"; maxPlayers=4; persistent=1; loopback=1; BattlEye=0; verifySignatures=0; kickDuplicate=0; statisticsEnabled=0; allowedFilePatching=0;\nclass Missions {class Smoke {template="'+name+'"; difficulty="Regular"; class Params {OpenParams=0;Whitelist=0;Exclusive=0;WipeSave1=0;};};};\n',encoding='utf-8')
    argv=[str(GAME/'arma3server_x64.exe'),f'-config={config}',f'-profiles={profiles}',f'-port={port}','-ip=127.0.0.1','-autoInit','-world=empty','-noSound']
    source_hash=hashlib.sha256()
    for path in sorted((source_root/'core.liberation').rglob('*')):
        if path.is_file(): source_hash.update(str(path.relative_to(source_root)).encode()); source_hash.update(bytes.fromhex(sha(path)))
    roles=['server']+[f'client{i+1}' for i in range(args.clients)]
    client_cases=['startup.client','player.abilities','catalog.filters','catalog.empty','purchase.filtered','reward.owner','services.cooldown','revive.manual']
    manifest={'run_id':run_id,'map':args.map,'source_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT).decode().strip(),'source_sha256':source_hash.hexdigest(),'baseline':args.baseline,'variant':args.variant,'control':args.control,'cases':cases,'client_cases':client_cases,'scripts':scripts,'package_sha256':sha(pbo),'argv':argv,'roles':roles,'port':port}
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
    process=None; completed=False; rpt=''; stop_reason='watchdog'; clients={}; pipes={}; connected=set()
    def logs(folder):
        return '\n'.join(p.read_text(errors='replace') for p in dict.fromkeys(list(folder.glob('*.rpt'))+list(folder.glob('*.RPT'))))
    try:
        process=subprocess.Popen(argv,cwd=GAME,creationflags=subprocess.CREATE_NO_WINDOW,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
        from native_pipe import ArmaPipe
        for i in range(args.clients):
            role=f'client{i+1}'; folder=out/role; folder.mkdir()
            video=out/f'{role}.cfg'; video.write_text('language="English";winX=30;winY=30;winW=1280;winH=720;winWidth=1280;winHeight=720;winDefWidth=1280;winDefHeight=720;renderWidth=1280;renderHeight=720;HDRPrecision=16;vsync=0;multiSampleCount=1;PPAA=0;pipQuality=0;\n')
            pipe_name='HPC_'+run_id+'_'+role
            cmd=[str(GAME/'arma3_x64.exe'),'-noSplash','-skipIntro','-world=empty','-window','-noPause','-noSound',f'-name=HpcClient{i+1}',f'-profiles={folder}',f'-cfg={video}',f'-command={pipe_name}']
            clients[role]=(subprocess.Popen(cmd,cwd=GAME,creationflags=subprocess.CREATE_NO_WINDOW,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL),folder,pipe_name)
            manifest[role+'_argv']=cmd
        (out/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
        deadline=time.monotonic()+args.timeout
        while time.monotonic()<deadline:
            rpt=logs(profiles)
            for role,(_,folder,pipe_name) in clients.items():
                if role not in connected:
                    try:
                        if role not in pipes: pipes[role]=ArmaPipe(pipe_name)
                        answer=pipes[role].send('reply hippo_test_pipe',reply=True)
                        if 'hippo_test_pipe' not in answer: raise RuntimeError('Pipe handshake failed')
                        pipes[role].send('connect '+json.dumps({'ip':'127.0.0.1','port':port,'password':'hippo-local-test'})); connected.add(role)
                    except (OSError,TimeoutError): pass
            if f'HPC_TEST|{run_id}|server|RUN_DONE|' in rpt and all(f'HPC_TEST|{run_id}|{role}|RUN_DONE|' in logs(folder) for role,(_,folder,_) in clients.items()):
                completed=True; stop_reason='protocol_complete'
                if args.hold: time.sleep(min(args.hold,60))
                break
            if process.poll() is not None: stop_reason='early_exit'; break
            time.sleep(0.5)
        time.sleep(1)
    finally:
        for role,(child,_,_) in clients.items():
            if child.poll() is None:
                try:
                    if role in pipes: pipes[role].send('shutdown'); child.wait(timeout=8)
                except (OSError,subprocess.TimeoutExpired): pass
                if child.poll() is None:
                    child.terminate()
                    try: child.wait(timeout=5)
                    except subprocess.TimeoutExpired: child.kill(); child.wait(timeout=5)
        for pipe in pipes.values(): pipe.close()
        if process and process.poll() is None:
            process.terminate()
            try: process.wait(timeout=8)
            except subprocess.TimeoutExpired: process.kill(); process.wait(timeout=5)
        if installed.exists() and sha(installed)==manifest['package_sha256']: installed.unlink()
    rpt=logs(profiles)
    prefix=f'HPC_TEST|{run_id}|server|'
    assertions=re.findall(re.escape(prefix)+r'ASSERT\|([^|"\r\n]+)\|(PASS|FAIL)',rpt)
    starts=re.findall(re.escape(prefix)+r'CASE_START\|([^|"\r\n]+)',rpt)
    dones=re.findall(re.escape(prefix)+r'CASE_DONE\|([^|"\r\n]+)',rpt)
    errors,known_issues=classify_errors(rpt)
    exact=sorted(starts)==sorted(cases) and sorted(dones)==sorted(cases) and sorted(a[0] for a in assertions)==sorted(cases) and rpt.count(prefix+'RUN_START|')==1 and rpt.count(prefix+'RUN_DONE|')==1
    client_results={}
    for role,(_,folder,_) in clients.items():
        content=logs(folder); tag=f'HPC_TEST|{run_id}|{role}|'
        checks=re.findall(re.escape(tag)+r'ASSERT\|([^|"\r\n]+)\|(PASS|FAIL)',content)
        role_starts=re.findall(re.escape(tag)+r'CASE_START\|([^|"\r\n]+)',content)
        role_dones=re.findall(re.escape(tag)+r'CASE_DONE\|([^|"\r\n]+)',content)
        role_exact=sorted(c[0] for c in checks)==sorted(client_cases) and sorted(role_starts)==sorted(client_cases) and sorted(role_dones)==sorted(client_cases) and content.count(tag+'RUN_START|')==1 and content.count(tag+'RUN_DONE|')==1
        role_errors,role_known=classify_errors(content)
        known_issues.extend(role_known)
        client_results[role]={'exact_inventory':role_exact,'assertions':checks,'errors':role_errors}
        exact=exact and role_exact
        errors+=role_errors
        assertions+=checks
    passed=completed and exact and all(a[1]=='PASS' for a in assertions) and not errors
    result={'passed':passed,'completed':completed,'exact_inventory':exact,'stop_reason':stop_reason,'assertions':assertions,'clients':client_results,'errors':errors,'known_upstream_issues':known_issues,'output':str(out)}
    (out/'result.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
    print(json.dumps({**result,'errors':errors[:12],'error_count':len(errors),'known_upstream_issues':[n['kind'] for n in known_issues]},indent=2),flush=True)
    return 0 if passed else 1

if __name__=='__main__': raise SystemExit(main())
