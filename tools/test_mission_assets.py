"""Mission content checks: image references, unused images and player-facing text.

Run from tools/: python -m unittest test_mission_assets
"""
import pathlib
import re
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
MISSION = ROOT / 'core.liberation'
SOURCES = ('.sqf', '.hpp', '.ext', '.h', '.xml')
IMAGES = ('.paa', '.jpg', '.jpeg', '.png')
# Mission-relative image paths inside quotes, e.g. "res\ui_ammo.paa" or 'R3F_LOG\icons\x.paa'.
REF = re.compile(r'''["']([A-Za-z0-9_][A-Za-z0-9_ .\\/-]*\.(?:paa|jpg|jpeg|png))["']''', re.I)
BRITISH = re.compile(r'\b(colour|armour|centre|defence|organis|realis|recognis|metre|licence|favour|honour|neighbour|behaviour|'
                     r'manoeuvr|travell|grey|tyre|whilst|aeroplane|fuelling|modelling|labelled|catalogue|programme)', re.I)


def mission_text():
    out = {}
    for p in MISSION.rglob('*'):
        if p.is_file() and p.suffix.lower() in SOURCES:
            out[p] = p.read_text(encoding='utf-8', errors='replace')
    return out


class MissionAssets(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.texts = mission_text()
        cls.files = {str(p.relative_to(MISSION)).replace('/', '\\').lower() for p in MISSION.rglob('*') if p.is_file()}
        cls.images = [p for p in MISSION.rglob('*') if p.is_file() and p.suffix.lower() in IMAGES]

    def test_referenced_images_exist(self):
        missing = set()
        for path, text in self.texts.items():
            for ref in REF.findall(text):
                rel = ref.replace('/', '\\').lower()
                if rel.startswith(('a3\\', '\\')) or '%' in rel:
                    continue  # game data or a formatted name
                if rel.split('\\')[0] in ('res', 'r3f_log', 'addons', 'ui', 'greuh', 'scripts', 'mod_template') and rel not in self.files:
                    missing.add(f'{path.relative_to(MISSION)}: {ref}')
        self.assertEqual(sorted(missing), [])

    def test_no_unused_images(self):
        corpus = '\n'.join(self.texts.values()).lower()
        unused = []
        for img in self.images:
            stem, name = img.stem.lower(), img.name.lower()
            if name in corpus or f'"{stem}"' in corpus or f'\\{stem}"' in corpus or f'\\{stem}' in corpus or f'/{stem}' in corpus:
                continue
            m = re.match(r'(.*?)(\d+)$', stem)
            if m and (m.group(1) + '%') in corpus:
                continue  # e.g. rep%1.paa
            unused.append(str(img.relative_to(MISSION)))
        self.assertEqual(unused, [])

    def test_english_text_is_american(self):
        st = (MISSION / 'stringtable.xml').read_text(encoding='utf-8')
        bad = [m.group(1) for m in re.finditer(r'<Key ID="([^"]+)">\s*<Original>([^<]*)</Original>', st) if BRITISH.search(m.group(2))]
        self.assertEqual(bad, [])

    def test_stringtable_placeholders_balanced(self):
        """Every translation keeps the same %N placeholders as the English text."""
        st = (MISSION / 'stringtable.xml').read_text(encoding='utf-8')
        bad = []
        for key in re.finditer(r'<Key ID="([^"]+)">(.*?)</Key>', st, re.S):
            orig = re.search(r'<Original>([^<]*)</Original>', key.group(2))
            if not orig:
                continue
            want = set(re.findall(r'%\d', orig.group(1)))
            if not want:
                continue
            for lang, val in re.findall(r'<(English)>([^<]*)</\1>', key.group(2)):
                if set(re.findall(r'%\d', val)) - want:
                    bad.append(key.group(1))
        self.assertEqual(bad, [])

    def test_action_labels(self):
        st = (MISSION / 'stringtable.xml').read_text(encoding='utf-8')
        def orig(k):
            return re.search(r'<Key ID="%s">\s*<Original>([^<]*)</Original>' % k, st).group(1)
        self.assertEqual(orig('STR_CLEAR_FORTIFICATION'), 'Remove fortifications')
        self.assertEqual(orig('STR_BUILD_FORTIFICATION'), 'Build fortifications')
        self.assertIn('Player permissions', orig('STR_COMMANDER_ACTION'))


if __name__ == '__main__':
    unittest.main()
