"""Print a release note from docs/release-notes as Steam change-note markup.

Usage: python tools/release_notes.py VERSION [MAP]
Uses VERSION-MAP.md when it exists, otherwise VERSION.md.
"""
import pathlib
import sys

NOTES = pathlib.Path(__file__).resolve().parent.parent / 'docs' / 'release-notes'


def to_steam(markdown):
    out, in_list = [], False
    for line in markdown.splitlines():
        if line.startswith('- '):
            if not in_list:
                out.append('[list]')
                in_list = True
            out.append('[*]' + line[2:])
            continue
        if in_list:
            out.append('[/list]')
            in_list = False
        if line.startswith('## '):
            out.append(f'[h2]{line[3:]}[/h2]')
        elif line.startswith('# '):
            out.append(f'[h1]{line[2:]}[/h1]')
        else:
            out.append(line)
    if in_list:
        out.append('[/list]')
    return '\n'.join(out).strip() + '\n'


def note_path(version, map_name=None):
    if map_name:
        specific = NOTES / f'{version}-{map_name}.md'
        if specific.exists():
            return specific
    return NOTES / f'{version}.md'


if __name__ == '__main__':
    sys.stdout.reconfigure(encoding='utf-8')
    path = note_path(*sys.argv[1:3])
    print(to_steam(path.read_text(encoding='utf-8')), end='')
