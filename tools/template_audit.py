"""Audit (and optionally repair) the faction templates' build lists.

Every template's classnames_west.sqf (an entry of core.liberation/mod_template.sqf) lists buildable entries as
[CLASSNAME, MANPOWER, AMMO, FUEL, RANK(, DESC)]. This checks them offline:

  duplicate   the same class listed twice in one template
  static-fuel a static weapon that costs fuel (statics never use fuel)
  rank        an unlock rank that is not a defined GRLIB_perm_* value
  conflict    a base-game class priced differently from the A3_* templates
  fuel-van    an extra fuel vehicle not priced like the fuel van (60 fuel)
  legacy rank a vehicle on an old coarse unlock tier (GRLIB_perm_inf..max)
  index       the HPC_templateIndex section of mod_template.sqf out of date

--fix rewrites mod_template.sqf: static fuel to 0, later duplicates removed, extra fuel
vehicles to the van price, and conflicts to the canonical price (the base-game
A3_* templates' price; mod-only classes keep each author's own price scale).
Exit status 1 while problems remain (without --fix).
"""
import argparse
import collections
import pathlib
import re
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import template_pack  # noqa: E402

ROOT = pathlib.Path(__file__).resolve().parents[1] / 'core.liberation'
LISTS = ('infantry_units_west', 'light_vehicles', 'heavy_vehicles', 'air_vehicles',
         'static_vehicles', 'support_vehicles_west', 'buildings_west')
VEHICLE_LISTS = LISTS[1:6]
FUEL_VAN = ('5', '120', '60', 'GRLIB_perm_sgt')
ENTRY = re.compile(r'\[\s*("[^"]+"|\w+)\s*,\s*([^,\]]+?)\s*,\s*([^,\]]+?)\s*,\s*([^,\]]+?)\s*,\s*([^,\]]+?)\s*(,[^\]]*)?\]')
SKIP_FUEL = re.compile(r'sling|pod|canister|barrel|jerry|box|drum|container|bladder|tank_?(?:er)?$', re.I)


def defined_ranks():
    text = (ROOT / 'scripts/shared/fetch_params.sqf').read_text(encoding='utf-8', errors='replace')
    names = set(re.findall(r'^(GRLIB_perm_\w+)\s*=', text, re.M))
    return names | {'GRLIB_perm_hidden'}


def list_bodies(text):
    for m in re.finditer(r'^(\w+)\s*=\s*\[(.*?)^\];', text, re.M | re.S):
        if m.group(1) in LISTS:
            yield m.group(1), m.start(2), m.group(2)


def parse(text):
    rows = []
    for name, base, body in list_bodies(text):
        offset = 0
        for line in body.splitlines(keepends=True):
            code = line.split('//', 1)[0]
            m = ENTRY.search(code)
            if m:
                cls = m.group(1).strip('"')
                rows.append(dict(list=name, cls=cls, quoted=m.group(1).startswith('"'),
                                 vals=tuple(x.strip() for x in m.group(2, 3, 4, 5)),
                                 start=base + offset + m.start(), end=base + offset + m.end(),
                                 line_start=base + offset, line_end=base + offset + len(line),
                                 text=m.group(0), tail=m.group(6) or ''))
            offset += len(line)
    return text, rows


def templates(files):
    for name, parts in sorted(template_pack.templates(files).items(), key=lambda x: x[0].lower()):
        if 'classnames_west.sqf' in parts:
            yield name, parts['classnames_west.sqf']


def canonical(prices):
    """prices: {template: vals}. The base-game price wins."""
    for t in ('A3_BLU', 'A3_BLU_PAC', 'A3_BLU_LT', 'A3_IND', 'A3_OPF', 'A3_OPF_PAC', 'A3_OPF_LT'):
        if t in prices:
            return prices[t]
    # templates that price vehicles in fuel only (ammo 0) do not set the price for others
    priced = {t: v for t, v in prices.items() if ammo_of(v) > 0} or prices
    counts = collections.Counter(priced.values())
    best = max(counts.values())
    return max((v for v, n in counts.items() if n == best), key=lambda v: (ammo_of(v), v))


# Old Liberation RX templates unlock on five coarse tiers. The rank ladder has a step per
# rank, so each tier becomes a band of ladder ranks and the template's vehicles of one list
# and tier spread over it by ammo price, cheapest first. Authors price on their own scales,
# so the tier, not the price, decides how far up the ladder a vehicle sits.
LEGACY_BANDS = {
    'GRLIB_perm_inf': ['pfc', 'cpl', 'sgt'],
    'GRLIB_perm_log': ['sgt', 'ssg', 'sfc', 'msg'],
    'GRLIB_perm_tank': ['sgm', '2lt', '1lt', 'cpt'],
    'GRLIB_perm_air': ['cpt', 'maj', 'ltc'],
    'GRLIB_perm_max': ['ltc', 'col'],
}
RANKED_LISTS = ('light_vehicles', 'heavy_vehicles', 'air_vehicles', 'static_vehicles')


def ammo_of(vals):
    try:
        return float(vals[1])
    except ValueError:
        return 0.0


def band_ranks(entries):
    """entries: [(key, vals)] of one template, list and legacy tier -> {key: rank}."""
    out = {}
    if not entries:
        return out
    band = LEGACY_BANDS[entries[0][1][3]]
    prices = sorted({ammo_of(v) for _, v in entries})
    for key, vals in entries:
        i = prices.index(ammo_of(vals))
        step = 0 if len(prices) == 1 else round(i * (len(band) - 1) / (len(prices) - 1))
        out[key] = 'GRLIB_perm_' + band[step]
    return out


def fuel_vehicle(row, core_fuel_truck):
    return (row['list'] in ('support_vehicles_west', 'light_vehicles') and row['quoted']
            and 'fuel' in row['cls'].lower() and not SKIP_FUEL.search(row['cls'])
            and row['cls'].lower() != core_fuel_truck)


def audit(root=ROOT, fix=False):
    ranks = defined_ranks()
    problems = []
    head, index, files = template_pack.read_pack(root)
    changed = False
    data = {}
    for name, path in templates(files):
        text = files[path]
        _, rows = parse(text)
        m = re.search(r'^fuel_truck_typename\s*=\s*"([^"]+)"', text, re.M)
        data[name] = (path, text, rows, (m.group(1).lower() if m else ''))
    prices = collections.defaultdict(dict)
    for name, (_, _, rows, _) in data.items():
        for r in rows:
            if r['quoted'] and r['list'] in VEHICLE_LISTS:
                prices[r['cls'].lower()].setdefault(name, r['vals'])
    for name, (path, text, rows, fuel_truck) in data.items():
        code = re.sub(r'/\*.*?\*/', '', re.sub(r'//[^\n]*', '', text), flags=re.S)
        if re.search(r'\]\s*\[', re.sub(r'"[^"\n]*"', '""', code)):
            problems.append(f'{name}: missing comma between two list entries (fix by hand)')
        edits = []  # (start, end, replacement)
        seen = {}
        tiered = collections.defaultdict(list)
        pending = {}
        for r in rows:
            key = (r['cls'].lower(), r['list'] == 'infantry_units_west')
            vals = list(r['vals'])
            if key in seen:
                problems.append(f'{name}: duplicate {r["cls"]} ({seen[key]} and {r["list"]})')
                edits.append((r['line_start'], r['line_end'], None))
                continue
            seen[key] = r['list']
            rank = vals[3]
            if not (re.fullmatch(r'\d+', rank) or rank in ranks):
                problems.append(f'{name}: {r["cls"]} unknown rank {rank}')
            if r['list'] == 'static_vehicles' and vals[2] not in ('0',):
                problems.append(f'{name}: static {r["cls"]} costs fuel {vals[2]}')
                vals[2] = '0'
            if r['quoted'] and r['list'] in VEHICLE_LISTS:
                if fuel_vehicle(r, fuel_truck) and tuple(vals) != FUEL_VAN:
                    problems.append(f'{name}: fuel vehicle {r["cls"]} priced {",".join(vals)}, van price is {",".join(FUEL_VAN)}')
                    vals = list(FUEL_VAN)
                elif any(t.startswith('A3_') for t in prices[r['cls'].lower()]):
                    # base-game classes cost the same everywhere; mod-only classes keep their
                    # template's price, since each author prices on their own scale
                    want = canonical(prices[r['cls'].lower()])
                    if tuple(vals) != want:
                        problems.append(f'{name}: {r["cls"]} {",".join(vals)} vs canonical {",".join(want)}')
                        vals = list(want)
            if r['list'] in RANKED_LISTS and vals[3] in LEGACY_BANDS:
                tiered[(r['list'], vals[3])].append((id(r), list(vals)))
            pending[id(r)] = (r, vals)
        for entries in tiered.values():
            for key, rank in band_ranks(entries).items():
                pending[key][1][3] = rank
        for r, vals in pending.values():
            if tuple(vals[:3]) == r['vals'][:3] and vals[3] != r['vals'][3] and r['vals'][3] in LEGACY_BANDS:
                problems.append(f'{name}: {r["cls"]} unlock {r["vals"][3]} -> {vals[3]}')
            if tuple(vals) != r['vals']:
                cls = f'"{r["cls"]}"' if r['quoted'] else r['cls']
                edits.append((r['start'], r['end'], f'[{cls},{",".join(vals)}{r["tail"]}]'))
        if fix and edits:
            out = text
            for start, end, rep in sorted(edits, reverse=True):
                out = out[:start] + ('' if rep is None else rep) + out[end:]
            # a removed last entry can leave a trailing comma before the closing bracket
            out = re.sub(r',(\s*\r?\n\];)', r'\1', out)
            files[path] = out
            changed = True
    want = index_text(files).strip('\n')
    if index != want:
        problems.append('HPC_templateIndex section of mod_template.sqf out of date')
        index = want
        changed = True
    if fix and changed:
        template_pack.write_pack(root, head, index, files)
    return problems


PETS = {'Alsatian_Random_F', 'Fin_random_F'}


def template_refs(text, role):
    """Up to three infantry classes that must exist for the template's mod to be loaded."""
    if text is None:
        return []
    refs = []
    if role == 'west':
        m = re.search(r'^infantry_units_west\s*=\s*\[(.*?)^\];', text, re.M | re.S)
        for line in (m.group(1).splitlines() if m else []):
            q = re.search(r'"([^"]+)"', line.split('//', 1)[0])
            if q and q.group(1) not in PETS and q.group(1) not in refs:
                refs.append(q.group(1))
    else:
        for var in ('opfor_rifleman', 'opfor_sentry', 'opfor_squad_leader'):
            q = re.search(r'^' + var + r'\s*=\s*"([^"]+)"', text, re.M)
            if q and q.group(1) not in refs:
                refs.append(q.group(1))
    return refs[:3]


def index_text(files):
    rows = []
    for name, parts in sorted(template_pack.templates(files).items(), key=lambda x: x[0].lower()):
        west = template_refs(files.get(parts.get('classnames_west.sqf')), 'west')
        east = template_refs(files.get(parts.get('classnames_east.sqf')), 'east')
        q = lambda refs: '[' + ','.join(f'"{r}"' for r in refs) + ']'
        rows.append(f'\t["{name.lower()}", [{q(west)}, {q(east)}]]')
    return ('// Generated by tools/template_audit.py --fix; do not edit.\n'
            '// Template name (lower case) -> [west classes, east classes]: infantry that exists\n'
            "// only when the template's mod is loaded. An empty list means no such role.\n"
            'HPC_templateIndex = createHashMapFromArray [\n' + ',\n'.join(rows) + '\n];\n')


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument('--fix', action='store_true', help='rewrite the templates')
    args = ap.parse_args(argv)
    problems = audit(fix=args.fix)
    for p in problems:
        print(p)
    print(f'{len(problems)} problem(s){" fixed" if args.fix else ""}')
    return 0 if args.fix or not problems else 1


if __name__ == '__main__':
    sys.exit(main())
