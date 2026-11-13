"""Build Hippos Conquest for normal Arma 3 multiplayer hosting."""
import argparse
import hashlib
import json
import shutil
import subprocess
import re
import tempfile
from mission_compact import compact_stage
from map_layout import check_maps
from template_audit import audit as audit_templates
import xml.etree.ElementTree as ET
from datetime import datetime
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
import os
GAME=Path(os.environ.get('ARMA3_DIR', 'C:/Program Files (x86)/Steam/steamapps/common/Arma 3'))

def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()

# Mission browser / lobby description (written into each map's mission.sqm).
OVERVIEW_TEXT='Hippos Conquest: a Liberation RX fork. Capture the island sector by sector with your squad: build FOBs, command AI forces and manage manpower, ammo and fuel.'

# Map folder suffix -> terrain name shown in Arma.
_TERRAIN_NAMES={'Malden':'Malden 2035','Enoch':'Livonia','SefrouRamal':'Sefrou-Ramal','Cam_Lao_Nam':'Cam Lao Nam','Chernarus_Winter':'Chernarus (Winter)','SPE_Mortain':'Mortain','SPEX_carentan':'Carentan','gm_weferlingen_summer':'Weferlingen (Summer)','gm_weferlingen_winter':'Weferlingen (Winter)','UMB_Colombia':'Colombia','OPTRE_iberius':'Iberius'}
# Every maps/Liberation_RX.<suffix> folder can be built.
MAPS={p.name.split('.',1)[1]:_TERRAIN_NAMES.get(p.name.split('.',1)[1],p.name.split('.',1)[1]) for p in sorted((ROOT/'maps').glob('Liberation_RX.*')) if (p/'mission.sqm').exists()}

def next_version(base_version, manifest_paths):
    """Advance the patch number after every successful local build (shared by all maps)."""
    versions = [base_version]
    for manifest_path in manifest_paths:
        versions.append(json.loads(manifest_path.read_text(encoding='utf-8'))['version'])
    latest = max(tuple(map(int, value.split('+', 1)[0].split('.'))) for value in versions)
    if len(latest) != 3:
        raise ValueError('Expected a major.minor.patch mission version')
    return f'{latest[0]}.{latest[1]}.{latest[2] + 1}'

def stamp_scenario_data(text, title):
    """Write picture, text and author into a decoded mission.sqm's ScenarioData.
    The server browser and lobby read these from ScenarioData; description.ext is
    only parsed once the mission loads."""
    overview=('\tauthor="TheHungryHippo";\n\toverviewPicture="res\\overview.paa";\n\toverviewText="'
              +OVERVIEW_TEXT+'";\n\tloadScreen="res\\liberation.paa";\n\tonLoadName="'+title+'";\n\tonLoadMission="'+OVERVIEW_TEXT+'";\n')
    head=text.find('class ScenarioData')
    if head<0: raise RuntimeError('Expected a ScenarioData class in mission.sqm')
    # Only touch ScenarioData's own top-level entries (one tab deep).
    end=re.search(r'(?m)^\};',text[head:])
    if end is None: raise RuntimeError('ScenarioData in mission.sqm is not closed at column 0')
    title=title.replace('"','""')
    block=text[head:head+end.end()]
    block=re.sub(r'(?m)^\t(author|overviewPicture|overviewText|loadScreen|onLoadName|onLoadMission)=.*;\r?\n','',block)
    block,count=re.subn(r'(class ScenarioData\r?\n\{\r?\n)',lambda m:m[1]+overview,block,count=1)
    if count!=1: raise RuntimeError('Expected a ScenarioData class in mission.sqm')
    return text[:head]+block+text[head+end.end():]

def stamp_identity(stage, version):
    """Show the same unique release ID in mission selection and loading UI."""
    title=f'Hippos Conquest v{version}'
    path=stage/'stringtable.xml'
    text=path.read_text(encoding='utf-8-sig')
    for key,value in [('STR_MISSION_TITLE',title),('STR_MISSION_VERSION',version)]:
        pattern=rf'(<Key ID="{key}">\s*<Original>)[^<]*(</Original>)'
        text,count=re.subn(pattern,lambda m:m[1]+value+m[2],text)
        if count!=1: raise RuntimeError('Missing/duplicate release identity key: '+key)
    path.write_text(text,encoding='utf-8')
    path=stage/'description.ext'
    text=path.read_text(encoding='utf-8-sig')
    for key in ('briefingName','onLoadName'):
        text,count=re.subn(rf'(?m)^{key}\s*=.*?;',lambda m:f'{key} = "{title}";',text)
        if count!=1: raise RuntimeError('Missing/duplicate mission title: '+key)
    path.write_text(text,encoding='utf-8')
    # The map mission.sqm files are binarized: never edit their offsets as raw bytes.
    converter=GAME.parent/'Arma 3 Tools/CfgConvert/CfgConvert.exe'
    with tempfile.TemporaryDirectory(prefix='Hippo-release-title-') as folder:
        decoded=Path(folder)/'mission.cpp'
        subprocess.run([str(converter),'-txt','-dst',str(decoded),str(stage/'mission.sqm')],check=True,capture_output=True)
        text=decoded.read_text(encoding='utf-8-sig')
        text,count=re.subn(r'\bbriefingName\s*=\s*"[^"]*";',lambda m:f'briefingName="{title}";',text)
        if count!=1: raise RuntimeError('Expected one Intel briefingName in mission.sqm')
        text=stamp_scenario_data(text,title)
        decoded.write_text(text,encoding='utf-8')
        subprocess.run([str(converter),'-bin','-dst',str(stage/'mission.sqm'),str(decoded)],check=True,capture_output=True)
        verified=Path(folder)/'verified.cpp'
        subprocess.run([str(converter),'-txt','-dst',str(verified),str(stage/'mission.sqm')],check=True,capture_output=True)
        if f'briefingName="{title}";' not in verified.read_text(encoding='utf-8-sig'):
            raise RuntimeError('Native mission title round-trip verification failed')
    return title

def main():
    global GAME
    parser=argparse.ArgumentParser()
    parser.add_argument('--game-directory', type=Path, default=GAME, help='Arma 3 install (also locates sibling Arma 3 Tools).')
    deployment=parser.add_mutually_exclusive_group()
    deployment.add_argument('--install',dest='install',action='store_true',help='Install into the game MPMissions folder (default).')
    deployment.add_argument('--build-only',dest='install',action='store_false',help='Build without replacing the installed mission.')
    parser.set_defaults(install=True)
    parser.add_argument('--whitelist',type=Path,help='Private access lists (e.g. tools/server/local/whitelist.sqf) to build in for your own server. Never upload such a build.')
    parser.add_argument('--map',nargs='+',choices=sorted(MAPS),default=['Malden'],help='Maps to build; all get the same release version.')
    args=parser.parse_args()
    if args.whitelist:
        text=args.whitelist.read_text(encoding='utf-8-sig')
        missing=[name for name in ('GRLIB_whitelisted_steamids','GRLIB_whitelisted_moderators','GRLIB_blacklisted_names') if name not in text]
        if missing: raise RuntimeError(f'{args.whitelist} does not define: '+', '.join(missing))
    GAME=args.game_directory
    dirty=subprocess.check_output(['git','status','--porcelain','--','core.liberation',*[f'maps/Liberation_RX.{m}' for m in args.map]],cwd=ROOT).decode().strip()
    if dirty: raise RuntimeError('Commit mission source before producing a release candidate.\n'+dirty)
    bad=check_maps(list(dict.fromkeys(args.map)),GAME)
    if bad: raise RuntimeError('Map layout out of date (fix with python tools/map_layout.py --fix):\n'+'\n'.join(f'{m}: {i}' for m,v in bad.items() for i in v))
    tpl=audit_templates()
    if tpl: raise RuntimeError('Faction templates need fixing (python tools/template_audit.py --fix):\n'+'\n'.join(tpl))
    version=next(k.findtext('Original') for k in ET.parse(ROOT/'core.liberation/stringtable.xml').getroot().iter('Key') if k.attrib.get('ID')=='STR_MISSION_VERSION')
    stamp=datetime.now().strftime('%Y%m%d-%H%M%S')
    out=ROOT/'mybuild'/'releases'
    out.mkdir(parents=True,exist_ok=True)
    release_version=next_version(version,sorted(out.glob('Hippos_Conquest.*.manifest.json')))
    for map_name in dict.fromkeys(args.map):
        build_map(map_name,args,out,stamp,version,release_version)

def build_map(map_name,args,out,stamp,version,release_version):
    revision=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT).decode().strip()
    stage=out/stamp/f'Hippos_Conquest.{map_name}'
    shutil.copytree(ROOT/'core.liberation',stage)
    shutil.copytree(ROOT/f'maps/Liberation_RX.{map_name}',stage,dirs_exist_ok=True)
    for name in ['CREDITS.md','COPYING.md']: shutil.copy2(ROOT/name,stage/name)
    if args.whitelist: shutil.copy2(args.whitelist,stage/'whitelist.sqf')
    title=stamp_identity(stage,release_version)
    (stage/'build_info.sqf').write_text(f'// Hippos Conquest release provenance\nGRLIB_build_date="{stamp}";\nGRLIB_build_time="{datetime.now().strftime("%H:%M:%S")}";\nGRLIB_build_version="{release_version}";\n',encoding='utf-8')
    compact_report=out/stamp/f'compaction.{map_name}.json'
    compaction=compact_stage(stage,compact_report)
    pbo=out/f'Hippos_Conquest.{map_name}.pbo'
    if pbo.exists(): shutil.copy2(pbo,out/stamp/('previous-'+pbo.name))
    pack=subprocess.run([str(ROOT/'build/bin/PBOConsole.exe'),'-pack',str(stage),str(pbo)],cwd=ROOT,capture_output=True,text=True)
    (out/stamp/f'pack.{map_name}.log').write_text(pack.stdout+pack.stderr,encoding='utf-8')
    if pack.returncode or not pbo.exists() or pbo.stat().st_size==0: raise RuntimeError('PBO packaging failed')
    source_hash=hashlib.sha256()
    entries=[]
    for path in sorted(stage.rglob('*')):
        if path.is_file():
            name=str(path.relative_to(stage)).replace('\\','/')
            entries.append(name)
            source_hash.update(name.encode()); source_hash.update(bytes.fromhex(sha(path)))
    manifest={'mission':'Hippos Conquest','terrain':MAPS[map_name],'source_commit':revision,'upstream_base':subprocess.check_output(['git','rev-parse','upstream/master'],cwd=ROOT).decode().strip(),'package':str(pbo),'package_sha256':sha(pbo),'staged_source_sha256':source_hash.hexdigest(),'entries':entries,'built_at':stamp}
    manifest.update(version=release_version,base_version=version,title=title)
    manifest['private_whitelist']=str(args.whitelist) if args.whitelist else None
    if args.install:
        destination=GAME/'MPMissions'/pbo.name
        if destination.exists() and sha(destination)!=manifest['package_sha256']:
            backup=out/stamp/('installed-backup-'+pbo.name)
            shutil.copy2(destination,backup)
            manifest['previous_installed_backup']=str(backup)
        shutil.copy2(pbo,destination)
        if sha(destination)!=manifest['package_sha256']: raise RuntimeError('Installed PBO hash mismatch')
        manifest['installed']=str(destination)
        helper_destination=GAME/'HipposConquest'
        helper_destination.mkdir(exist_ok=True)
        for helper_name in ('start_headless.ps1','server-headless.example.cfg','README.md'):
            helper_source=ROOT/'tools/headless'/helper_name
            helper_target=helper_destination/helper_name
            if helper_target.exists() and sha(helper_target)!=sha(helper_source):
                shutil.copy2(helper_target,out/stamp/('previous-'+helper_name))
            shutil.copy2(helper_source,helper_target)
        manifest['headless_tools']=str(helper_destination)
    manifest['compaction']={'report':str(compact_report),'report_sha256':sha(compact_report),**{k:compaction[k] for k in ('source_bytes','release_bytes','renamed_files')}}
    manifest_path=out/f'Hippos_Conquest.{map_name}.manifest.json'
    manifest_path.write_text(json.dumps(manifest,indent=2),encoding='utf-8')
    print(json.dumps({k:v for k,v in manifest.items() if k!='entries'},indent=2))
    if args.whitelist: print(f'WARNING: {pbo.name} contains the private access lists from {args.whitelist}. Do not upload it to the Workshop.')

if __name__=='__main__': main()
