"""Offline SQF checks against the arma3-wiki-mcp cache.

Checks every tracked .sqf file for lexical errors (unbalanced brackets,
unterminated strings/comments, trailing commas, assignment inside `if`),
cross-references every script command against the wiki (unknown event
handler names, server-only commands, commands newer than the target game
version, commands with wiki problem notes) and lists global identifiers that
are read but never defined anywhere in the project (likely typos).

Usage: python tools/sqf_wiki_check.py [--wiki DIR] [--game-version 2.22]
       [--report FILE] [--inventory FILE]
Exit code 1 when lexical errors or unknown event handlers are found.
"""
import argparse
import collections
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_WIKI = Path(os.environ.get('LOCALAPPDATA', '')) / 'arma3-wiki-mcp' / 'wiki'
KEYWORDS = {
    'if', 'then', 'else', 'exitwith', 'while', 'do', 'for', 'from', 'to', 'step', 'foreach', 'foreachreversed',
    'switch', 'case', 'default', 'true', 'false', 'nil', 'private', 'params', 'call', 'spawn', 'with', 'try',
    'catch', 'throw', 'and', 'or', 'not', 'this', 'thislist', 'thistrigger', 'waituntil', 'count', 'select',
    'apply', 'findif', 'isnil', 'execvm', 'compile', 'compilefinal', 'missionnamespace', 'uinamespace',
    'profilenamespace', 'parsingnamespace', 'servernamespace', 'missionprofilenamespace', 'localnamespace',
}
PREPROC = re.compile(r'^\s*#')
IDENT = re.compile(r'[A-Za-z_][A-Za-z0-9_]*')
EH_COMMANDS = {
    'addeventhandler': ('standard',), 'addmpeventhandler': ('multiplayer',),
    'addmissioneventhandler': ('mission',), 'addmusiceventhandler': ('music',),
    'ctrladdeventhandler': ('user_interface',), 'displayaddeventhandler': ('user_interface',),
    'adduseractioneventhandler': ('user_action',),
}


def load_wiki(wiki):
    """Return {lowercase name: info} for commands and {category: set(lowercase events)}."""
    cmds = {}
    for f in (wiki / 'commands').glob('*.yml'):
        t = f.read_text(encoding='utf8', errors='replace')
        name = re.search(r'^name: (.+)$', t, re.M).group(1).strip().strip("'\"")
        a3 = re.search(r'^since:\n(?:  .+\n)*?  arma_3:\n    major: (\d+)\n    minor: (\d+)', t, re.M)
        cmds[name.lower()] = {
            'name': name,
            'arg': (re.search(r'^argument_loc: (\S+)', t, re.M) or [None, '?'])[1],
            'eff': (re.search(r'^effect_loc: (\S+)', t, re.M) or [None, '?'])[1],
            'server': bool(re.search(r'^server_exec: true', t, re.M)),
            'problem': bool(re.search(r'^problem_notes:', t, re.M)),
            'since': (int(a3.group(1)), int(a3.group(2))) if a3 else None,
        }
    events = collections.defaultdict(set)
    for f in (wiki / 'events').glob('*/*.yml'):
        events[f.parent.name].add(f.stem.lower())
    return cmds, events


def lex(text):
    """Yield (kind, value, line) tokens; kinds: ident, str, punct, num. Errors go to the 'err' kind."""
    i, n, line = 0, len(text), 1
    while i < n:
        c = text[i]
        if c == '\n':
            line += 1
            i += 1
            # Preprocessor directives (with line continuations) are skipped.
            j = i
            while j < n and text[j] in ' \t':
                j += 1
            if j < n and text[j] == '#':
                while i < n and text[i] != '\n':
                    if text[i] == '\\' and i + 1 < n and text[i + 1] == '\n':
                        line += 1
                        i += 1
                    i += 1
            continue
        if c in ' \t\r':
            i += 1
        elif text.startswith('//', i):
            while i < n and text[i] != '\n':
                i += 1
        elif text.startswith('/*', i):
            end = text.find('*/', i + 2)
            if end < 0:
                yield 'err', 'unterminated block comment', line
                return
            line += text.count('\n', i, end)
            i = end + 2
        elif c in '"\'':
            j, start = i + 1, line
            while True:
                if j >= n:
                    yield 'err', 'unterminated string', start
                    return
                if text[j] == c:
                    if j + 1 < n and text[j + 1] == c:
                        j += 2
                        continue
                    break
                j += 1
            value = text[i + 1:j]
            line += value.count('\n')
            yield 'str', value, start
            i = j + 1
        elif (c.isascii() and c.isalpha()) or c == '_':
            m = IDENT.match(text, i)
            yield 'ident', m.group(0), line
            i = m.end()
        elif c.isdigit() or (c == '.' and i + 1 < n and text[i + 1].isdigit()):
            m = re.compile(r'0x[0-9A-Fa-f]+|\$[0-9A-Fa-f]+|\d*\.?\d+(?:[eE][+-]?\d+)?').match(text, i)
            yield 'num', m.group(0), line
            i = m.end()
        else:
            two = text[i:i + 2]
            if two in ('==', '!=', '>=', '<=', '&&', '||', '>>'):
                yield 'punct', two, line
                i += 2
            else:
                yield 'punct', c, line
                i += 1


def check_file(path, rel, cmds, events, game_version, report, usage, defined, read_globals):
    text = path.read_text(encoding='utf8', errors='replace').replace('\r\n', '\n')
    if text.startswith('﻿'):
        text = text[1:]
    if PREPROC.match(text):
        text = '\n' + text  # let the lexer skip a directive on line 1
        offset = -1
    else:
        offset = 0
    toks = list(lex(text))
    stack = []
    pairs = {')': '(', ']': '[', '}': '{'}
    prev = [None, None, None]
    skip_str = set()
    for idx, (kind, val, line) in enumerate(toks):
        line += offset
        if kind == 'err':
            report['lexical'].append(f'{rel}:{line}: {val}')
            continue
        if kind == 'punct':
            if val in '([{':
                stack.append((val, line))
            elif val in ')]}':
                if not stack or stack[-1][0] != pairs[val]:
                    opened = f' (open {stack[-1][0]} from line {stack[-1][1]})' if stack else ''
                    report['lexical'].append(f'{rel}:{line}: unexpected {val}{opened}')
                    if not any(o == pairs[val] for o, _ in stack):
                        prev = [(kind, val), prev[0], prev[1]]
                        continue  # stray closer: keep checking the rest of the file
                    while stack[-1][0] != pairs[val]:
                        stack.pop()
                stack.pop()
                if prev[0] and prev[0][0] == 'punct' and prev[0][1] == ',' and val in ')]':
                    report['lexical'].append(f'{rel}:{line}: trailing comma before {val}')
        elif kind == 'ident':
            low = val.lower()
            nxt = toks[idx + 1] if idx + 1 < len(toks) else ('', '', 0)
            nxt2 = toks[idx + 2] if idx + 2 < len(toks) else ('', '', 0)
            # sleep 5 + random 10 parses as (sleep 5) + random 10: no delay, then a script error
            if low in ('sleep', 'uisleep') and nxt[0] in ('num', 'ident') and nxt2[0] == 'punct' and nxt2[1] in '+-*/':
                report['bugs'].append(f'{rel}:{line}: {val} {nxt[1]} {nxt2[1]} ... needs parentheses: {val} ({nxt[1]} {nxt2[1]} ...)')
            # { deleteVehicle _x } forEach crew ...: leaves ghost crew (use deleteVehicleCrew)
            if low == 'deletevehicle' and nxt[1].lower() == '_x':
                j = idx + 2
                if j < len(toks) and toks[j][1] == ';':
                    j += 1
                tail = [t[1].lower() for t in toks[j:j + 4]]
                if tail[:2] == ['}', 'foreach'] and 'crew' in tail[2:4]:
                    report['bugs'].append(f'{rel}:{line}: deleteVehicle on crew members leaves ghost crew; use deleteVehicleCrew')
            is_local = val.startswith('_')
            if low in cmds and not is_local:
                usage[low].append(f'{rel}:{line}')
                info = cmds[low]
                if info['since'] and game_version and info['since'] > game_version:
                    report['too_new'].append(f'{rel}:{line}: {info["name"]} needs Arma 3 {info["since"][0]}.{info["since"][1]:02d}')
                # Event handler name check: CMD [..., "Name", ...] or obj CMD ["Name", ...]
                if low in ('remoteexec', 'remoteexeccall') and nxt[1] == '[' and idx + 2 < len(toks)                         and toks[idx + 2][0] == 'str':
                    skip_str.add(idx + 2)
                    report['remote_targets'].append((toks[idx + 2][1], f'{rel}:{line}'))
                if low in EH_COMMANDS and nxt[1] == '[':
                    j = idx + 2
                    if j < len(toks) and toks[j][0] == 'str':
                        cats = EH_COMMANDS[low]
                        name = toks[j][1].lower()
                        known = any(name in events.get(c, ()) for c in cats)
                        if low == 'addeventhandler':
                            known = known or any(name in s for s in events.values())
                        if not known:
                            report['unknown_eh'].append(f'{rel}:{line}: {val} "{toks[j][1]}"')
            elif not is_local and low not in KEYWORDS:
                if nxt[1] == '=' and (prev[0] is None or prev[0][1] in (';', '{', '}') or prev[0][1].lower() == 'private'):
                    defined.add(low)
                else:
                    read_globals[low].append(f'{rel}:{line}')
        elif kind == 'str':
            # Strings naming globals: publicVariable "x", setVariable ["x", ...], function names.
            if IDENT.fullmatch(val) and idx not in skip_str:
                defined.add(val.lower())
        prev = [(kind, val), prev[0], prev[1]]
    # Assignment inside an if condition: if (a = b)
    for m in re.finditer(r'\bif\s*\(([^()]*)\)', text, re.I):
        if re.search(r'(?<![=!<>])=(?!=)', m.group(1)):
            report['lexical'].append(f'{rel}:{text.count(chr(10), 0, m.start()) + 1 + offset}: assignment inside if condition')
    for open_, line in stack:
        report['lexical'].append(f'{rel}:{line + offset}: unclosed {open_}')


def config_names(files):
    """Names defined outside plain SQF assignments: macros, config classes/entries,
    editor object names in mission.sqm, and CfgFunctions tag_fnc_name for fn_name.sqf files."""
    names = set()
    fn_files = set()
    for path in files:
        if path.suffix.lower() == '.sqf' and path.stem.lower().startswith('fn_'):
            fn_files.add(path.stem.lower()[3:])
        if path.suffix.lower() == '.sqm':
            # Binarized or text: take every identifier-like string as a possible editor name.
            raw = path.read_bytes().decode('latin-1')
            names.update(m.group(0).lower() for m in re.finditer(r'[A-Za-z_][A-Za-z0-9_]{2,}', raw))
            continue
        if path.name.lower() == 'cba_settings.sqf':
            continue  # CBA settings syntax, not SQF
        text = path.read_text(encoding='utf8', errors='replace')
        for m in re.finditer(r'#define\s+(\w+)', text):
            names.add(m.group(1).lower())
        if path.suffix.lower() != '.sqf':
            for m in re.finditer(r'\bclass\s+(\w+)', text):
                names.add(m.group(1).lower())
            for m in re.finditer(r'\b(\w+)\s*=', text):
                names.add(m.group(1).lower())
    return names, fn_files


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--wiki', type=Path, default=DEFAULT_WIKI)
    ap.add_argument('--game-version', default='2.22')
    ap.add_argument('--report', type=Path)
    ap.add_argument('--inventory', type=Path, help='Write the command inventory (locality, usage count) as TSV.')
    ap.add_argument('paths', nargs='*', help='Limit to these files (default: all tracked .sqf files).')
    args = ap.parse_args()
    if not (args.wiki / 'commands').is_dir():
        sys.exit(f'wiki cache not found at {args.wiki}; run the arma3-wiki MCP once or pass --wiki')
    cmds, events = load_wiki(args.wiki)
    gv = tuple(int(x) for x in args.game_version.split('.')) if args.game_version else None
    all_sqf = subprocess.run(['git', 'ls-files', '*.sqf'], cwd=ROOT, capture_output=True,
                             text=True, check=True).stdout.split()
    files = [Path(p).resolve().relative_to(ROOT).as_posix() if Path(p).is_absolute() or Path(p).exists() else p
             for p in args.paths] or all_sqf
    report = collections.defaultdict(list)
    usage = collections.defaultdict(list)
    defined = set()
    read_globals = collections.defaultdict(list)
    for rel in files:
        if rel.lower().endswith('cba_settings.sqf'):
            continue  # CBA settings syntax, not SQF
        check_file(ROOT / rel, rel, cmds, events, gv, report, usage, defined, read_globals)
    if args.paths:
        # Subset mode: still collect definitions from every other file, so functions
        # compiled elsewhere are not reported as unknown remoteExec targets or globals.
        scratch = collections.defaultdict(list)
        for rel in set(all_sqf) - set(files):
            if not rel.lower().endswith('cba_settings.sqf'):
                check_file(ROOT / rel, rel, cmds, events, gv, collections.defaultdict(list),
                           collections.defaultdict(list), defined, scratch)
    tracked = subprocess.run(['git', 'ls-files', '*.sqf', '*.hpp', '*.ext', '*.h', '*.inc', '*.cpp', '*.sqm'],
                             cwd=ROOT, capture_output=True, text=True, check=True).stdout.split()
    cfg, fn_files = config_names([ROOT / f for f in tracked])
    defined |= cfg
    # Generated by build/build.sh and tools/hippo_testing/run.py (build_info.sqf).
    defined |= {'grlib_build_date', 'grlib_build_time', 'grlib_build_version'}
    # Mod-provided functions and engine UI defines from #include'd a3 headers.
    external = re.compile(r'^(bis_|bin_|ace_|cba_|acre_|tfar_|lambs_|grad_|zen_|achilles_|ares_|rhs_|cup_|a3_|life_|gvar|'
                          r'vn_|lrx_template_|dik_|idc_rscdisplay|idcs_|hpc_)', re.I)
    undefined = {k: v for k, v in read_globals.items()
                 if k not in defined and not external.match(k)
                 and not ('_fnc_' in k and k.split('_fnc_', 1)[1] in fn_files)}

    bad_targets = [f'{loc}: "{name}"' for name, loc in report['remote_targets']
                   if name and name.lower() not in cmds and name.lower() not in defined and not external.match(name)
                   and not ('_fnc_' in name.lower() and name.lower().split('_fnc_', 1)[1] in fn_files)]
    out = []
    def section(title, items):
        out.append(f'\n== {title} ({len(items)}) ==')
        out.extend(sorted(items))
    section('Lexical errors', report['lexical'])
    section('Likely bugs (sleep precedence, deleteVehicle on crew)', report['bugs'])
    section('Unknown event handler names', report['unknown_eh'])
    section('remoteExec targets that are neither commands nor defined functions', bad_targets)
    section(f'Commands newer than Arma 3 {args.game_version}', report['too_new'])
    section('Server-only commands (verify each runs on the server)',
            [f'{cmds[c]["name"]}: {", ".join(usage[c][:6])}{" ..." if len(usage[c]) > 6 else ""}'
             for c in usage if cmds[c]['server']])
    section('Commands with wiki problem notes (review usage)',
            [f'{cmds[c]["name"]} x{len(usage[c])}' for c in usage if cmds[c]['problem']])
    section('Globals read but never defined in the project (possible typos; external mods excluded)',
            [f'{k}: {", ".join(v)}' for k, v in undefined.items()])
    out.append(f'\n{len(files)} files, {len(usage)} distinct wiki commands used.')
    text = '\n'.join(out)
    print(text)
    if args.report:
        args.report.write_text(text, encoding='utf8')
    if args.inventory:
        rows = ['command\targument_loc\teffect_loc\tserver_exec\tproblem_notes\tuses']
        rows += [f'{cmds[c]["name"]}\t{cmds[c]["arg"]}\t{cmds[c]["eff"]}\t{cmds[c]["server"]}\t{cmds[c]["problem"]}\t{len(usage[c])}'
                 for c in sorted(usage)]
        args.inventory.write_text('\n'.join(rows), encoding='utf8')
    return 1 if report['lexical'] or report['unknown_eh'] or report['bugs'] or bad_targets else 0


if __name__ == '__main__':
    sys.exit(main())
