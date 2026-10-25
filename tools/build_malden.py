"""Build Hippos Conquest for normal Arma 3 multiplayer hosting."""
import argparse
import hashlib
import json
import shutil
import subprocess
import re
import tempfile
from mission_compact import compact_stage
import xml.etree.ElementTree as ET
from datetime import datetime
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
GAME=Path('E:/SteamLibrary/steamapps/common/Arma 3')

def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()

def next_version(base_version, manifest_path):
    """Advance the patch number after every successful local build."""
    versions = [base_version]
    if manifest_path.exists():
        versions.append(json.loads(manifest_path.read_text(encoding='utf-8'))['version'])
    latest = max(tuple(map(int, value.split('+', 1)[0].split('.'))) for value in versions)
    if len(latest) != 3:
        raise ValueError('Expected a major.minor.patch mission version')
    return f'{latest[0]}.{latest[1]}.{latest[2] + 1}'

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
    # Malden's mission.sqm is binarized: never edit its offsets as raw bytes.
    converter=GAME.parent/'Arma 3 Tools/CfgConvert/CfgConvert.exe'
    with tempfile.TemporaryDirectory(prefix='Hippo-release-title-') as folder:
        decoded=Path(folder)/'mission.cpp'
        subprocess.run([str(converter),'-txt','-dst',str(decoded),str(stage/'mission.sqm')],check=True,capture_output=True)
        text=decoded.read_text(encoding='utf-8-sig')
        text,count=re.subn(r'\bbriefingName\s*=\s*"[^"]*";',lambda m:f'briefingName="{title}";',text)
        if count!=1: raise RuntimeError('Expected one Malden Intel briefingName')
        decoded.write_text(text,encoding='utf-8')
        subprocess.run([str(converter),'-bin','-dst',str(stage/'mission.sqm'),str(decoded)],check=True,capture_output=True)
        verified=Path(folder)/'verified.cpp'
        subprocess.run([str(converter),'-txt','-dst',str(verified),str(stage/'mission.sqm')],check=True,capture_output=True)
        if f'briefingName="{title}";' not in verified.read_text(encoding='utf-8-sig'):
            raise RuntimeError('Native mission title round-trip verification failed')
    return title

def main():
    parser=argparse.ArgumentParser()
    deployment=parser.add_mutually_exclusive_group()
    deployment.add_argument('--install',dest='install',action='store_true',help='Install into the game MPMissions folder (default).')
    deployment.add_argument('--build-only',dest='install',action='store_false',help='Build without replacing the installed mission.')
    parser.set_defaults(install=True)
    args=parser.parse_args()
    dirty=subprocess.check_output(['git','status','--porcelain','--','core.liberation','maps/Liberation_RX.Malden'],cwd=ROOT).decode().strip()
    if dirty: raise RuntimeError('Commit mission source before producing a release candidate.\n'+dirty)
    revision=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT).decode().strip()
    upstream_tag=subprocess.check_output(['git','describe','--tags','upstream/master'],cwd=ROOT).decode().strip()
    version=next(k.findtext('Original') for k in ET.parse(ROOT/'core.liberation/stringtable.xml').getroot().iter('Key') if k.attrib.get('ID')=='STR_MISSION_VERSION')
    stamp=datetime.now().strftime('%Y%m%d-%H%M%S')
    out=ROOT/'mybuild'/'releases'
    out.mkdir(parents=True,exist_ok=True)
    release_version=next_version(version,out/'Hippos_Conquest.Malden.manifest.json')
    stage=out/stamp/'Hippos_Conquest.Malden'
    shutil.copytree(ROOT/'core.liberation',stage)
    shutil.copytree(ROOT/'maps/Liberation_RX.Malden',stage,dirs_exist_ok=True)
    for name in ['CREDITS.md','COPYING.md']: shutil.copy2(ROOT/name,stage/name)
    title=stamp_identity(stage,release_version)
    (stage/'build_info.sqf').write_text(f'// Hippos Conquest release provenance\nGRLIB_build_date="{stamp}";\nGRLIB_build_time="{datetime.now().strftime("%H:%M:%S")}";\nGRLIB_build_version="{release_version}";\n',encoding='utf-8')
    compact_report=out/stamp/'compaction.json'
    compaction=compact_stage(stage,compact_report)
    pbo=out/'Hippos_Conquest.Malden.pbo'
    if pbo.exists(): shutil.copy2(pbo,out/stamp/('previous-'+pbo.name))
    pack=subprocess.run([str(ROOT/'build/bin/PBOConsole.exe'),'-pack',str(stage),str(pbo)],cwd=ROOT,capture_output=True,text=True)
    (out/stamp/'pack.log').write_text(pack.stdout+pack.stderr,encoding='utf-8')
    if pack.returncode or not pbo.exists() or pbo.stat().st_size==0: raise RuntimeError('PBO packaging failed')
    source_hash=hashlib.sha256()
    entries=[]
    for path in sorted(stage.rglob('*')):
        if path.is_file():
            name=str(path.relative_to(stage)).replace('\\','/')
            entries.append(name)
            source_hash.update(name.encode()); source_hash.update(bytes.fromhex(sha(path)))
    manifest={'mission':'Hippos Conquest','terrain':'Malden 2035','source_commit':revision,'upstream_base':subprocess.check_output(['git','rev-parse','upstream/master'],cwd=ROOT).decode().strip(),'package':str(pbo),'package_sha256':sha(pbo),'staged_source_sha256':source_hash.hexdigest(),'entries':entries,'built_at':stamp}
    manifest.update(version=release_version,base_version=version,title=title)
    if args.install:
        destination=GAME/'MPMissions'/pbo.name
        if destination.exists() and sha(destination)!=manifest['package_sha256']:
            backup=out/stamp/('installed-backup-'+pbo.name)
            shutil.copy2(destination,backup)
            manifest['previous_installed_backup']=str(backup)
        shutil.copy2(pbo,destination)
        if sha(destination)!=manifest['package_sha256']: raise RuntimeError('Installed PBO hash mismatch')
        manifest['installed']=str(destination)
    manifest['compaction']={'report':str(compact_report),'report_sha256':sha(compact_report),**{k:compaction[k] for k in ('source_bytes','release_bytes','renamed_files')}}
    manifest_path=out/'Hippos_Conquest.Malden.manifest.json'
    manifest_path.write_text(json.dumps(manifest,indent=2),encoding='utf-8')
    print(json.dumps({k:v for k,v in manifest.items() if k!='entries'},indent=2))

if __name__=='__main__': main()
