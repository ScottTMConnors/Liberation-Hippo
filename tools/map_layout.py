"""Check (or fix) the Hippos Conquest layout rules in every maps/*/mission.sqm.

Rules the shared mission code cannot apply by itself, because they live in each
map's own layout:
- exactly one playable Commander group (GRLIB_is_Commander), listed first so
  it is the first slot in the lobby.

    python tools/map_layout.py            # check all maps, exit 1 on a problem
    python tools/map_layout.py --fix      # rewrite maps that break a rule
    python tools/map_layout.py Malden     # only these maps
"""
import argparse
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAPS_DIR = ROOT / 'maps'


def converter(game):
    return Path(game).parent / 'Arma 3 Tools/CfgConvert/CfgConvert.exe'


def _block_end(text, open_brace):
    depth = 0
    for i in range(open_brace, len(text)):
        if text[i] == '{':
            depth += 1
        elif text[i] == '}':
            depth -= 1
            if depth == 0:
                return i
    raise ValueError('unbalanced braces in mission.sqm')


def mission_items(text):
    """Return (body_start, body_end, [(start, end), ...]) for Mission > Entities items."""
    mission = re.search(r'(?m)^class Mission\s*\{', text)
    if not mission:
        raise ValueError('no class Mission')
    m_start = mission.end() - 1
    m_end = _block_end(text, m_start)
    entities = re.search(r'(?m)^\tclass Entities\s*\{', text[m_start:m_end])
    if not entities:
        raise ValueError('no Mission Entities')
    e_start = m_start + entities.end() - 1
    e_end = _block_end(text, e_start)
    body = text[e_start + 1:e_end]
    items = []
    for item in re.finditer(r'(?m)^\t\tclass Item\d+\s*\{', body):
        end = _block_end(body, item.end() - 1)
        items.append((item.start(), body.index(';', end) + 1))
    return e_start + 1, e_end, items


def commander_index(text):
    start, end, items = mission_items(text)
    body = text[start:end]
    found = [i for i, (s, e) in enumerate(items)
             if 'GRLIB_is_Commander' in body[s:e] and 'dataType="Group"' in body[s:e]]
    return found, items


def problems(text):
    found, _ = commander_index(text)
    if len(found) != 1:
        return [f'expected one Commander group, found {len(found)}']
    if found[0] != 0:
        return [f'Commander group is Item{found[0]}, must be Item0 (first lobby slot)']
    return []


def fix(text):
    found, items = commander_index(text)
    if len(found) != 1:
        raise ValueError(f'expected one Commander group, found {len(found)}')
    i = found[0]
    if i == 0:
        return text
    start, end, _ = mission_items(text)
    body = text[start:end]
    texts = [body[s:e] for s, e in items]
    order = [texts[i]] + texts[:i] + texts[i + 1:]
    order = [re.sub(r'^\t\tclass Item\d+', f'\t\tclass Item{n}', x, count=1) for n, x in enumerate(order)]
    body = body[:items[0][0]] + '\n'.join(order) + body[items[-1][1]:]
    return text[:start] + body + text[end:]


def decode(cc, sqm, folder):
    out = Path(folder) / (sqm.parent.name + '.cpp')
    subprocess.run([str(cc), '-txt', '-dst', str(out), str(sqm)], check=True, capture_output=True)
    return out


def check_maps(names, game, apply_fix=False):
    """Return {map: [problem, ...]} for maps that still break a rule."""
    cc = converter(game)
    bad = {}
    with tempfile.TemporaryDirectory(prefix='Hippo-map-layout-') as folder:
        for name in names:
            sqm = MAPS_DIR / f'Liberation_RX.{name}' / 'mission.sqm'
            cpp = decode(cc, sqm, folder)
            text = cpp.read_text(encoding='utf-8-sig')
            issues = problems(text)
            if issues and apply_fix:
                cpp.write_text(fix(text), encoding='utf-8')
                subprocess.run([str(cc), '-bin', '-dst', str(sqm), str(cpp)], check=True, capture_output=True)
                issues = problems(decode(cc, sqm, folder).read_text(encoding='utf-8-sig'))
                print(f'{name}: fixed' if not issues else f'{name}: fix failed')
            if issues:
                bad[name] = issues
    return bad


def all_maps():
    return sorted(p.name.split('.', 1)[1] for p in MAPS_DIR.glob('Liberation_RX.*') if (p / 'mission.sqm').exists())


def main():
    import os
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('maps', nargs='*', help='Map folder suffixes (default: all).')
    parser.add_argument('--fix', action='store_true')
    parser.add_argument('--game-directory', default=os.environ.get('ARMA3_DIR', 'C:/Program Files (x86)/Steam/steamapps/common/Arma 3'))
    args = parser.parse_args()
    names = args.maps or all_maps()
    bad = check_maps(names, args.game_directory, args.fix)
    for name, issues in bad.items():
        for issue in issues:
            print(f'{name}: {issue}')
    if not bad:
        print(f'{len(names)} map(s) OK')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
