"""Isolated engine checks against the actual map mission; never uses player saves."""
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
    global GAME
    ap = argparse.ArgumentParser()
    ap.add_argument('--game-directory', type=Path, default=GAME)
    ap.add_argument('--variant', choices=['default','expanded'], default='default')
    ap.add_argument('--control', choices=['pass','assertion','syntax','runtime','timeout','protocol'])
    ap.add_argument('--timeout', type=int, default=150)
    ap.add_argument('--baseline', action='store_true')
    ap.add_argument('--clients', type=int, choices=[0,1,2], default=0)
    ap.add_argument('--attribution',action='store_true')
    ap.add_argument('--headless', type=int, choices=[0,2], default=0)
    ap.add_argument('--hc-binary',choices=['server','client'],default='server')
    ap.add_argument('--hold', type=int, default=0)
    ap.add_argument('--map', choices=['Altis','Malden'], default='Malden')
    ap.add_argument('--scenario', action='store_true')
    ap.add_argument('--commander', action='store_true')
    ap.add_argument('--source-ref')
    ap.add_argument('--compact',action='store_true',help='Apply release compaction before packaging.')
    ap.add_argument('--mod',action='append',default=[])
    ap.add_argument('--missing-faction',choices=['settings','campaign'])
    args = ap.parse_args()
    GAME=args.game_directory
    if args.attribution and args.headless != 2: ap.error("--attribution requires --headless 2")
    if args.scenario and args.commander:
        ap.error('Run --scenario and --commander separately: scenario cleanup stops the warfare managers needed by commander checks.')
    if args.scenario and args.headless:
        ap.error('Run --scenario and --headless separately: scenario cleanup stops the warfare managers needed by HC checks.')
    run_id = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%f') + '-' + args.variant + '-' + ('baseline' if args.baseline else args.control or 'smoke')
    out = ROOT/'mybuild'/'hippo_tests'/run_id
    out.mkdir(parents=True, exist_ok=False)
    stage = out/'s'/f'Liberation_RX_T{datetime.now(timezone.utc).strftime("%H%M%S%f")}.{args.map}'
    source_root=ROOT
    if args.baseline or args.source_ref:
        source_root=out/'upstream'
        archive=subprocess.check_output(['git','archive','--format=zip',args.source_ref or 'upstream/master','core.liberation',f'maps/Liberation_RX.{args.map}'],cwd=ROOT)
        with zipfile.ZipFile(io.BytesIO(archive)) as z: z.extractall(source_root)
    shutil.copytree(source_root/'core.liberation', stage)
    shutil.copytree(source_root/'maps'/f'Liberation_RX.{args.map}', stage, dirs_exist_ok=True)
    tag=subprocess.check_output(['git','describe','--tags','upstream/master'],cwd=ROOT).decode().strip()
    (stage/'build_info.sqf').write_text(f'GRLIB_build_date="{run_id}"; GRLIB_build_time="test"; GRLIB_build_version="{tag}-hippo-test";\n')
    tests=stage/'hippo_tests'; tests.mkdir()
    cases=['engine.compile','startup.server','telemetry.ownership','civilians.ambient','civilians.traffic','sector.fortifications','settings.defaults','factions.available','settings.english','skills.toggle','damage.civilian','catalog.classification','catalog.order','catalog.unlockFilter','objects.simple','cargo.restore','vehicles.emptyPools','warfare.armedPool']
    if args.scenario: cases+=['warfare.spawn','sector.commanderGate','sector.capture','warfare.cleanup']
    if args.commander: cases+=['commander.emptyRoster','commander.townLoaded','commander.progress','warfare.enemyFOB']
    if args.headless: cases+=['hc.connected','hc.legacy','hc.warfare','hc.balanced','hc.weighted','hc.playerSafe','hc.orders','hc.recovered','hc.rejoined','hc.serverFallback','hc.cleanup']
    if args.attribution: cases=['engine.compile','startup.server','reward.squad','reward.vehicleHistory','reward.vehicleBounty','reward.projectile']
    if args.control: cases=['control']
    if args.baseline: cases=['startup.server']
    if args.missing_faction: cases=['faction.rejected','faction.savePreserved','faction.ended']
    (tests/'run.sqf').write_text((ROOT/'tools'/'hippo_testing'/'server.sqf').read_text(encoding='utf-8'),encoding='utf-8')
    shutil.copy2(ROOT/'tools/hippo_testing/review.sqf',tests/'review.sqf')
    if args.attribution:
        shutil.copy2(ROOT/'tools/hippo_testing/attribution.sqf',tests/'attribution.sqf')
        p=tests/'run.sqf'
        p.write_text('HPC_testAttribution=true; publicVariable "HPC_testAttribution";\n'+p.read_text(encoding='utf-8'),encoding='utf-8')
    if args.headless:
        p=tests/'run.sqf'
        p.write_text('HPC_testHeadless=true; publicVariable "HPC_testRun";\n'+p.read_text(encoding='utf-8'),encoding='utf-8')
        shutil.copy2(ROOT/'tools/hippo_testing/headless.sqf',tests/'headless.sqf')
        shutil.copy2(ROOT/'tools/hippo_testing/hc_client.sqf',tests/'hc_client.sqf')
        p=stage/'init.sqf'
        p.write_text(p.read_text(encoding='utf-8-sig')+'\nif (!hasInterface && !isServer) then {[] execVM "hippo_tests\\hc_client.sqf"};\n',encoding='utf-8')
    if args.scenario: shutil.copy2(ROOT/'tools/hippo_testing/scenario.sqf',tests/'scenario.sqf')
    if args.commander: shutil.copy2(ROOT/'tools/hippo_testing/commander.sqf',tests/'commander.sqf')
    changed = subprocess.check_output(['git','-c','core.safecrlf=false','-c','core.autocrlf=false','diff','--name-only','upstream/master'], cwd=ROOT,stderr=subprocess.DEVNULL).decode().splitlines()
    changed += subprocess.check_output(['git','ls-files','--others','--exclude-standard','core.liberation'],cwd=ROOT).decode().splitlines()
    scripts=sorted({p.removeprefix('core.liberation/').replace('/','\\') for p in changed if p.startswith('core.liberation/') and p.endswith('.sqf') and 'hippo_params' not in p and (stage/p.removeprefix('core.liberation/')).exists()})
    settings=''
    if args.variant=='expanded':
        settings='GRLIB_LRX_params set ["HippoAllFactions", createHashMapFromArray [[GRLIB_PARAM_ValueKey,1]]];\n'
        p=stage/'scripts/server/fetch_params.sqf'
        p.write_text(p.read_text(encoding='utf-8-sig').replace('// Save back cleaned params',settings+'\n// Save back cleaned params'),encoding='utf-8')
    (stage/'initServer.sqf').write_text(f'HPC_testRun="{run_id}"; HPC_testVariant="{args.variant}"; HPC_testControl="{args.control or ""}"; HPC_testBaseline={str(args.baseline).lower()}; HPC_testScenario={str(args.scenario).lower()}; HPC_testCommander={str(args.commander).lower()}; HPC_testScripts='+json.dumps(scripts).replace('\\\\','\\')+'; [] execVM "hippo_tests\\run.sqf";\n',encoding='utf-8')
    if args.missing_faction:
        injection = '''
HPC_testBeforeSettings = createHashMapFromArray [["ModPresetEast",createHashMapFromArray [["Value","RHS_AFRF"]]]];
HPC_testBeforeCampaign = [0,[],[],[],[],[],[],"A3_BLU","RHS_AFRF"];
'''
        if args.missing_faction=='settings': injection+='HPC_testBeforeCampaign = [];\n'
        else: injection+='HPC_testBeforeSettings = createHashMap;\n'
        injection+='''
profileNamespace setVariable [GRLIB_paramsV2_save_key,HPC_testBeforeSettings];
profileNamespace setVariable [GRLIB_save_key,HPC_testBeforeCampaign];
HPC_testSettingsText = str HPC_testBeforeSettings;
HPC_testCampaignText = str HPC_testBeforeCampaign;
HPC_testFactionEmit = {
 params ["_id","_ok"];
 diag_log format ["HPC_TEST|%1|server|CASE_START|%2",HPC_testRun,_id];
 diag_log format ["HPC_TEST|%1|server|ASSERT|%2|%3",HPC_testRun,_id,["FAIL","PASS"] select _ok];
 diag_log format ["HPC_TEST|%1|server|CASE_DONE|%2",HPC_testRun,_id];
};
addMissionEventHandler ["MPEnded",{
 ["faction.ended",true] call HPC_testFactionEmit;
 diag_log format ["HPC_TEST|%1|server|RUN_DONE|3",HPC_testRun];
 "hippo-test-command" serverCommand "#shutdown";
}];
'''
        p=stage/'scripts/server/fetch_params.sqf'
        p.write_text(p.read_text(encoding='utf-8-sig').replace('// Load Mission settings',injection+'\n// Load Mission settings'),encoding='utf-8')
        (stage/'initServer.sqf').write_text(f'HPC_testRun="{run_id}"; [] execVM "hippo_tests\\missing_faction.sqf";')
        shutil.copy2(ROOT/'tools/hippo_testing/missing_faction.sqf',tests/'missing_faction.sqf')
    if args.clients:
        shutil.copy2(ROOT/'tools/hippo_testing/client.sqf',tests/'client.sqf')
        (stage/'initPlayerLocal.sqf').write_text(f'HPC_testRun="{run_id}"; [] execVM "hippo_tests\\client.sqf";\n',encoding='utf-8')
    compaction=None
    if args.compact:
        import sys
        sys.path.insert(0,str(ROOT/'tools'))
        from mission_compact import compact_stage
        if not args.control and not args.attribution:
            cases.append('compaction.leaves')
            shutil.copy2(ROOT/'tools/hippo_testing/compact.sqf',tests/'compact.sqf')
            p=tests/'run.sqf'
            p.write_text(p.read_text(encoding='utf-8').replace('["settings.defaults",', '[] call compile preprocessFileLineNumbers "hippo_tests\\compact.sqf";\n["settings.defaults",').replace('18 + (if (HPC_testScenario)', '19 + (if (HPC_testScenario)'),encoding='utf-8')
        # Include all delivered SQF in the native syntax check.
        scripts=sorted(p.relative_to(stage).as_posix().replace('/','\\') for p in stage.rglob('*.sqf') if 'hippo_tests' not in p.parts)
        p=stage/'initServer.sqf'
        p.write_text(p.read_text(encoding='utf-8')+'\nHPC_testScripts='+json.dumps(scripts).replace('\\\\','\\')+';\n',encoding='utf-8')
        compaction=compact_stage(stage,out/'compaction.json')
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
    if args.headless:
        for candidate in range(24680,24800,4):
            try:
                with socket.socket(socket.AF_INET,socket.SOCK_DGRAM) as sock:sock.bind(('127.0.0.1',candidate))
                port=candidate;break
            except OSError:continue
    config=out/'server.cfg'
    config.write_text('hostname="Hippo isolated test"; password="hippo-local-test"; passwordAdmin="hippo-test-admin"; serverCommandPassword="hippo-test-command"; maxPlayers=4; persistent=1; loopback=1; BattlEye=0; verifySignatures=0; kickDuplicate=0; statisticsEnabled=0; allowedFilePatching=0;\nclass Missions {class Smoke {template="'+name+'"; difficulty="Regular"; class Params {OpenParams=0;Whitelist=0;Exclusive=0;WipeSave1=0;};};};\n',encoding='utf-8')
    if args.missing_faction: config.write_text(config.read_text().replace('loopback=1','loopback=0'))
    argv=[str(GAME/'arma3server_x64.exe'),f'-config={config}',f'-profiles={profiles}',f'-port={port}','-ip=127.0.0.1','-autoInit','-world=empty','-noSound']
    if args.headless or args.clients:
        # On Windows, binding only 127.0.0.1 lets a local HC bind the same
        # server+2 UDP port on 0.0.0.0 and steal packets. LAN-only mode remains
        # enforced by loopback=1; reserve the server ports on all interfaces.
        argv[argv.index('-ip=127.0.0.1')]='-ip=0.0.0.0'
    if args.mod: argv.append('-mod='+';'.join(args.mod))
    source_hash=hashlib.sha256()
    for path in sorted((source_root/'core.liberation').rglob('*')):
        if path.is_file(): source_hash.update(str(path.relative_to(source_root)).encode()); source_hash.update(bytes.fromhex(sha(path)))
    roles=['server']+[f'client{i+1}' for i in range(args.clients)]+((['hc1','hc2'] if args.attribution else ['hc1','hc2','hc1_rejoin']) if args.headless else [])
    client_cases=['startup.client','player.abilities','catalog.filters','catalog.empty','purchase.filtered','reward.owner','services.cooldown','revive.manual','catalog.groups','catalog.singleType','catalog.rankVisible','catalog.toggle','catalog.tools']
    manifest={'run_id':run_id,'map':args.map,'source_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT).decode().strip(),'source_sha256':source_hash.hexdigest(),'baseline':args.baseline,'variant':args.variant,'control':args.control,'cases':cases,'client_cases':client_cases,'scripts':scripts,'package_sha256':sha(pbo),'argv':argv,'roles':roles,'port':port}
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
    if compaction:
        manifest['compaction']={k:compaction[k] for k in ('source_bytes','release_bytes','renamed_files')}
        manifest['compaction_report_sha256']=sha(out/'compaction.json')
        (out/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
    process=None; completed=False; rpt=''; stop_reason='watchdog'; clients={}; pipes={}; connected=set(); last_connect={}; client_ready={}; headless={}; hc_dropped=False;hc_stop_all=False;hc_last_connect={}
    def logs(folder):
        return '\n'.join(p.read_text(errors='replace') for p in dict.fromkeys(list(folder.glob('*.rpt'))+list(folder.glob('*.RPT'))))
    try:
        if args.headless:
            config.write_text(config.read_text().replace('maxPlayers=4','maxPlayers=8')+'\ndisableVoN=1;headlessClients[]={"127.0.0.1"};localClient[]={"127.0.0.1"};\n')
        process=subprocess.Popen(argv,cwd=GAME,creationflags=subprocess.CREATE_NO_WINDOW,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
        from native_pipe import ArmaPipe
        def launch_hc(role):
            folder=out/role;folder.mkdir()
            pipe_name='HPC_'+run_id+'_'+role
            cmd=[str(GAME/('arma3server_x64.exe' if args.hc_binary=='server' else 'arma3_x64.exe')),'-client','-noSplash','-skipIntro','-noPause','-connect=127.0.0.1',f'-port={port}','-password=hippo-local-test',f'-profiles={folder}',f'-name={role}',f'-command={pipe_name}','-world=empty','-noSound']
            if args.mod: cmd.append('-mod='+';'.join(args.mod))
            child=subprocess.Popen(cmd,cwd=GAME,creationflags=subprocess.CREATE_NO_WINDOW,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
            headless[role]=(child,folder)
            manifest[role+'_argv']=cmd
        def connect_hc(role):
            child,folder=headless[role]
            deadline=time.monotonic()+50
            while time.monotonic()<deadline and child.poll() is None:
                content=logs(folder)
                if 'HPC_HC|READY|' in content:return
                if 'sessionID:' in content:
                    try:
                        pipe=ArmaPipe('HPC_'+run_id+'_'+role)
                        pipes[role]=pipe
                        pipe.send('connect '+json.dumps({'ip':'127.0.0.1','port':port,'password':'hippo-local-test'}))
                        return
                    except OSError:pass
                time.sleep(0.5)
        if args.headless:
            boot_deadline=time.monotonic()+120
            while time.monotonic()<boot_deadline and '--- Server Init stop ---' not in logs(profiles) and process.poll() is None: time.sleep(0.5)
            launch_hc('hc1')
            connect_hc('hc1')
            join_deadline=time.monotonic()+60
            while time.monotonic()<join_deadline and 'HPC_HC|READY|' not in logs(headless['hc1'][1]) and headless['hc1'][0].poll() is None: time.sleep(0.5)
            launch_hc('hc2')
            connect_hc('hc2')
        for i in range(args.clients):
            role=f'client{i+1}'; folder=out/role; folder.mkdir()
            user=folder/'Users'/f'HpcClient{i+1}'; user.mkdir(parents=True)
            (user/f'HpcClient{i+1}.Arma3Profile').write_text('version=2;singleVoice=0;sceneComplexity=300000;viewDistance=1600;preferredObjectViewDistance=1200;terrainGrid=25;\n',encoding='utf-8')
            video=out/f'{role}.cfg'; video.write_text('language="English";forcedAdapterId=-1;displayMode=0;winX=30;winY=30;winWidth=1280;winHeight=720;winDefWidth=1280;winDefHeight=720;renderWidth=1280;renderHeight=720;HDRPrecision=16;vsync=0;multiSampleCount=1;PPAA=0;pipQuality=0;GPU_MaxFramesAhead=1;GPU_DetectedFramesAhead=1;\n')
            pipe_name='HPC_'+run_id+'_'+role
            cmd=[str(GAME/'arma3_x64.exe'),'-noSplash','-skipIntro','-world=empty','-window','-noPause','-noSound',f'-name=HpcClient{i+1}',f'-profiles={folder}',f'-cfg={video}',f'-command={pipe_name}', '-connect=127.0.0.1',f'-port={port}','-password=hippo-local-test']
            client_mods=args.mod
            if client_mods: cmd.append('-mod='+';'.join(client_mods))
            # A rendering client needs a normal initial window for DX11 setup;
            # forcing a minimized startup can fail before mission entry.
            child=subprocess.Popen(cmd,cwd=GAME,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
            clients[role]=(child,folder,pipe_name)
            startup_deadline=time.monotonic()+45
            while time.monotonic()<startup_deadline and child.poll() is None:
                content=logs(folder)
                if 'Error creating Direct3D' in content: break
                if 'MovesType CfgMovesMaleSdr load time' not in content:
                    time.sleep(0.5); continue
                # Do not claim the command pipe during early initialization.
                break
            manifest[role+'_argv']=cmd
        (out/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
        deadline=time.monotonic()+args.timeout
        while time.monotonic()<deadline:
            rpt=logs(profiles)
            if args.headless:
                for role,(child,folder) in list(headless.items()):
                    content=logs(folder)
                    if child.poll() is None and 'sessionID:' in content and 'Starting mission:' not in content and time.monotonic()-hc_last_connect.get(role,0)>20:
                        try:
                            if role not in pipes:pipes[role]=ArmaPipe('HPC_'+run_id+'_'+role)
                            pipes[role].send('connect '+json.dumps({'ip':'127.0.0.1','port':port,'password':'hippo-local-test'}))
                            hc_last_connect[role]=time.monotonic()
                        except OSError:pass
                if '|HC_DROP|hc1' in rpt and not hc_dropped:
                    headless['hc1'][0].terminate();headless['hc1'][0].wait(timeout=8);hc_dropped=True
                if '|HC_REJOIN|hc1' in rpt and 'hc1_rejoin' not in headless:
                    launch_hc('hc1_rejoin')
                    connect_hc('hc1_rejoin')
                if '|HC_DROP_ALL|' in rpt and not hc_stop_all:
                    hc_stop_all=True
                    for child,_ in headless.values():
                        if child.poll() is None:child.terminate();child.wait(timeout=8)
                if any(p.poll() is not None for role,(p,_) in headless.items() if not hc_stop_all and not (role=='hc1' and hc_dropped)):
                    stop_reason='headless_early_exit';break
            if any(child.poll() is not None or 'Error creating Direct3D' in logs(folder) for child,folder,_ in clients.values()):
                stop_reason='client_startup_failure'; break
            for role,(_,folder,pipe_name) in clients.items():
                if role not in connected or (f'HPC_TEST|{run_id}|{role}|RUN_START|' not in logs(folder) and time.monotonic()-last_connect.get(role,0)>120):
                    if 'MovesType CfgMovesMaleSdr load time' not in logs(folder): continue
                    # Steam/profile/audio initialization continues after the
                    # pipe opens. Do not interrupt an ongoing connection with
                    # rapid retries; fresh-profile mission entry can be slow.
                    if role not in client_ready: client_ready[role]=time.monotonic()
                    if time.monotonic()-client_ready[role]<10: continue
                    try:
                        if role not in pipes: pipes[role]=ArmaPipe(pipe_name)
                        answer=pipes[role].send('reply hippo_test_pipe',reply=True)
                        if 'hippo_test_pipe' not in answer: raise RuntimeError('Pipe handshake failed')
                        pipes[role].send('connect '+json.dumps({'ip':'127.0.0.1','port':port,'password':'hippo-local-test'})); connected.add(role); last_connect[role]=time.monotonic()
                    except (OSError,TimeoutError) as error:
                        # Never retain an early/stale pipe handle indefinitely.
                        if not isinstance(error,TimeoutError) and role in pipes: pipes.pop(role).close()
                        with (out/'connection.log').open('a',encoding='utf-8') as log:
                            log.write(json.dumps({'role':role,'error':str(error)})+'\n')
            if f'HPC_TEST|{run_id}|server|RUN_DONE|' in rpt and all(f'HPC_TEST|{run_id}|{role}|RUN_DONE|' in logs(folder) for role,(_,folder,_) in clients.items()) and (not args.headless or ((args.attribution or 'hc1_rejoin' in headless) and all(f'HPC_TEST|{run_id}|{role}|RUN_DONE|' in logs(folder) for role,(_,folder) in headless.items()))):
                completed=True; stop_reason='protocol_complete'
                if args.hold: time.sleep(min(args.hold,60))
                break
            if process.poll() is not None: stop_reason='early_exit'; break
            time.sleep(0.5)
        time.sleep(1)
    finally:
        for child,_ in headless.values():
            if child.poll() is None:
                child.terminate()
                try: child.wait(timeout=8)
                except subprocess.TimeoutExpired:child.kill();child.wait(timeout=5)
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
    totals=re.findall(re.escape(prefix)+r'RUN_DONE\|(\d+)',rpt)
    exact=sorted(starts)==sorted(cases) and sorted(dones)==sorted(cases) and sorted(a[0] for a in assertions)==sorted(cases) and rpt.count(prefix+'RUN_START|')==1 and totals==[str(len(cases))]
    client_results={}
    for role,(_,folder,_) in clients.items():
        content=logs(folder); tag=f'HPC_TEST|{run_id}|{role}|'
        checks=re.findall(re.escape(tag)+r'ASSERT\|([^|"\r\n]+)\|(PASS|FAIL)',content)
        role_starts=re.findall(re.escape(tag)+r'CASE_START\|([^|"\r\n]+)',content)
        role_dones=re.findall(re.escape(tag)+r'CASE_DONE\|([^|"\r\n]+)',content)
        role_totals=re.findall(re.escape(tag)+r'RUN_DONE\|(\d+)',content)
        role_exact=sorted(c[0] for c in checks)==sorted(client_cases) and sorted(role_starts)==sorted(client_cases) and sorted(role_dones)==sorted(client_cases) and content.count(tag+'RUN_START|')==1 and role_totals==[str(len(client_cases))]
        role_errors,role_known=classify_errors(content)
        known_issues.extend(role_known)
        client_results[role]={'exact_inventory':role_exact,'assertions':checks,'errors':role_errors}
        exact=exact and role_exact
        errors+=role_errors
        assertions+=checks
    passed=completed and exact and all(a[1]=='PASS' for a in assertions) and not errors
    for role,(_,folder) in headless.items():
        content=logs(folder);tag=f'HPC_TEST|{run_id}|{role}|'
        expected=['hc.ready'] if role=='hc1_rejoin' or args.attribution else ['hc.ready','hc.locality','hc.orders']
        checks=re.findall(re.escape(tag)+r'ASSERT\|([^|"\r\n]+)\|(PASS|FAIL)',content)
        starts=re.findall(re.escape(tag)+r'CASE_START\|([^|"\r\n]+)',content)
        dones=re.findall(re.escape(tag)+r'CASE_DONE\|([^|"\r\n]+)',content)
        totals=re.findall(re.escape(tag)+r'RUN_DONE\|(\d+)',content)
        role_exact=sorted(c[0] for c in checks)==sorted(expected) and sorted(starts)==sorted(expected) and sorted(dones)==sorted(expected) and content.count(tag+'RUN_START|')==1 and totals==[str(len(expected))]
        role_errors,role_known=classify_errors(content)
        known_issues.extend(role_known);errors+=role_errors;assertions+=checks
        client_results[role]={'exact_inventory':role_exact,'assertions':checks,'errors':role_errors}
        exact=exact and role_exact
        passed=passed and role_exact and all(c[1]=='PASS' for c in checks) and not role_errors
    result={'passed':passed,'completed':completed,'exact_inventory':exact,'stop_reason':stop_reason,'assertions':assertions,'clients':client_results,'errors':errors,'known_upstream_issues':known_issues,'output':str(out)}
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
    (out/'result.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
    print(json.dumps({**result,'errors':errors[:12],'error_count':len(errors),'known_upstream_issues':[n['kind'] for n in known_issues]},indent=2),flush=True)
    return 0 if passed else 1

if __name__=='__main__': raise SystemExit(main())
