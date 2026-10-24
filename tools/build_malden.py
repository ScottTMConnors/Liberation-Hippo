"""Build Hippos Conquest for normal Arma 3 multiplayer hosting."""
import argparse
import hashlib
import json
import shutil
import subprocess
from datetime import datetime
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
GAME=Path('E:/SteamLibrary/steamapps/common/Arma 3')

def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--install', action='store_true', help='Copy the built PBO into the installed game MPMissions folder.')
    args=parser.parse_args()
    dirty=subprocess.check_output(['git','status','--porcelain','--','core.liberation','maps/Liberation_RX.Malden'],cwd=ROOT).decode().strip()
    if dirty: raise RuntimeError('Commit mission source before producing a release candidate.\n'+dirty)
    revision=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT).decode().strip()
    stamp=datetime.now().strftime('%Y%m%d-%H%M%S')
    out=ROOT/'mybuild'/'releases'
    out.mkdir(parents=True,exist_ok=True)
    stage=out/stamp/'Hippos_Conquest.Malden'
    shutil.copytree(ROOT/'core.liberation',stage)
    shutil.copytree(ROOT/'maps/Liberation_RX.Malden',stage,dirs_exist_ok=True)
    for name in ['CREDITS.md','COPYING.md']: shutil.copy2(ROOT/name,stage/name)
    (stage/'build_info.sqf').write_text(f'// Hippos Conquest release provenance\nGRLIB_build_date="{stamp}";\nGRLIB_build_time="{datetime.now().strftime("%H:%M:%S")}";\nGRLIB_build_version="1.1.0-{revision[:8]}";\n',encoding='utf-8')
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
    if args.install:
        destination=GAME/'MPMissions'/pbo.name
        if destination.exists() and sha(destination)!=manifest['package_sha256']:
            backup=out/stamp/('installed-backup-'+pbo.name)
            shutil.copy2(destination,backup)
            manifest['previous_installed_backup']=str(backup)
        shutil.copy2(pbo,destination)
        if sha(destination)!=manifest['package_sha256']: raise RuntimeError('Installed PBO hash mismatch')
        manifest['installed']=str(destination)
    manifest_path=out/'Hippos_Conquest.Malden.manifest.json'
    manifest_path.write_text(json.dumps(manifest,indent=2),encoding='utf-8')
    print(json.dumps({k:v for k,v in manifest.items() if k!='entries'},indent=2))

if __name__=='__main__': main()
