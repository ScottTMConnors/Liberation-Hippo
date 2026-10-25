"""Compact staged SQF, preserving public interfaces and readable source.

Only reviewed call-free leaves participate in local renaming. Never concatenate
scripts: file scopes, loading order and scheduling remain meaningful.
"""
import hashlib
import argparse
import json
import re
from pathlib import Path
from sqf_minify import minify, minify_files, tokenize, _WORD

LEAVES = {
    'HPC_catalogType.sqf': '_class _cfg',
    'HPC_applyEasyAI.sqf': '_unit _side _skills _backup _value',
    'HPC_createBuilding.sqf': '_class _position _local _functional _simple _object',
    'F_getVehicleDamage.sqf': '_vehicle _vehicle_hitpoints _current_hitpoints _vehicle_damage',
    'F_secondsToTimer.sqf': '_timer _minutes _seconds _minutes_zero _seconds_zero _retstr',
    'F_getNearestBlufor.sqf': '_startpos _radius _blufor_selected',
    'F_nearestPosition.sqf': '_list _pos _sorted_list',
    'F_itemIsInClass.sqf': '_item _list _ret',
    'F_getObjectPrice.sqf': '_class _list _ret',
    'F_getRandomPos.sqf': '_start_pos _radius _oldZ _pos',
}
FORBIDDEN = {'call','spawn','execvm','exec','execfsm','compile','compilefinal',
             'compilescript','callextension','remoteexec','remoteexeccall',
             'addeventhandler','addmpeventhandler','addmissioneventhandler',
             'addaction','oneachframe'}


def compact_stage(stage, report_path):
    stage = Path(stage).resolve()
    root = Path(__file__).resolve().parents[1]
    if stage == root or any(stage == root / n or root / n in stage.parents for n in ('core.liberation','maps')):
        raise ValueError('Compaction requires a separate staged mission')
    documents, raw, encodings = {}, {}, {}
    reserved = set()
    for path in sorted(stage.rglob('*')):
        if not path.is_file() or path.suffix.lower() not in {'.sqf','.hpp','.ext','.sqm','.cpp','.inc','.fsm','.xml'}:
            continue
        data = path.read_bytes()
        try:
            text, encoding = data.decode('utf-8-sig'), 'utf-8'
        except UnicodeDecodeError:
            # Byte-preserving view of legacy/mixed encodings. Non-ASCII bytes
            # inside literals round-trip unchanged; identifiers remain ASCII.
            text, encoding = data.decode('latin-1'), 'latin-1'
        reserved.update(w.casefold() for w in _WORD.findall(text))
        if path.suffix.lower() == '.sqf':
            name = path.relative_to(stage).as_posix()
            documents[name], raw[name], encodings[name] = text, data, encoding
    prefix = '_h'
    while any(n.startswith(prefix) for n in reserved):
        prefix += 'h'
    leaves, names = {}, set()
    for filename, locals_text in LEAVES.items():
        name = 'scripts/shared/functions/' + filename
        if name not in documents:
            raise ValueError('Missing reviewed leaf: ' + name)
        tokens = tokenize(documents[name])
        words = {t.text.casefold() for t in tokens if t.kind == 'word'}
        if words & FORBIDDEN or any(t.kind == 'directive' or '__LINE__' in t.text for t in tokens):
            raise ValueError('Reviewed leaf now calls/exports code or uses preprocessing: ' + name)
        selected = set(locals_text.casefold().split())
        for local in selected:
            declaration = re.search(r'\bprivate\s+' + re.escape(local) + r'\b', documents[name], re.I)
            literal = any(t.kind == 'string' and t.text[1:-1].casefold() == local for t in tokens)
            if not declaration and not literal:
                raise ValueError('Reviewed private declaration missing: ' + name + ':' + local)
        leaves[name] = documents[name]
        names.update(selected)
    renamed, rename_report = minify_files(leaves, rename_locals=names, rename_prefix=prefix)
    files, outputs = {}, {}
    for name, source in documents.items():
        # HPC_templateAvailable parses these as lines, including the position
        # of the first quoted classname. Lexical equivalence is insufficient.
        text_input = Path(name).name.lower() in {'classnames_west.sqf','classnames_east.sqf'}
        text = source if text_input else (renamed[name] if name in renamed else minify(source))
        passthrough = text_input or any(t.kind == 'directive' or '__LINE__' in t.text for t in tokenize(source))
        data = raw[name] if passthrough else text.encode(encodings[name])
        outputs[name] = data
        files[name] = {'source_bytes':len(raw[name]), 'release_bytes':len(data),
                       'source_sha256':hashlib.sha256(raw[name]).hexdigest(),
                       'release_sha256':hashlib.sha256(data).hexdigest(),
                       'encoding':encodings[name], 'passthrough':passthrough,
                       'line_parsed_template':text_input,
                       'renamed':name in renamed}
    # Validate every file before modifying the stage.
    for name, data in outputs.items():
        (stage / name).write_bytes(data)
    report = {'schema':1, 'mode':'reviewed-leaf-renaming-and-token-compaction',
              'tool_sha256':{n:hashlib.sha256((Path(__file__).parent/n).read_bytes()).hexdigest() for n in ('mission_compact.py','sqf_minify.py')},
              'renames':rename_report['renames'], 'files':files,
              'source_bytes':sum(v['source_bytes'] for v in files.values()),
              'release_bytes':sum(v['release_bytes'] for v in files.values()),
              'renamed_files':len(leaves)}
    Path(report_path).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('stage',type=Path)
    parser.add_argument('--report',required=True,type=Path)
    args = parser.parse_args()
    report = compact_stage(args.stage,args.report)
    print(json.dumps({k:v for k,v in report.items() if k not in ('files','renames')}))
