"""Release-transform invariants, encoding safety and fail-closed boundaries."""
import json
import shutil
import tempfile
import unittest
from pathlib import Path
from mission_compact import compact_stage, LEAVES
from sqf_minify import minify, tokenize, minify_files

ROOT = Path(__file__).resolve().parents[1]


class CompactionTests(unittest.TestCase):
    def test_lexical_boundaries_and_literals(self):
        for source in [
            'private _a = 1; /* comment */ _a + +2; // end',
            'hint "// text /* data */ doubled ""quote""";',
            "hint 'single ''quote'''; _a / /* comment */ _b;",
            'private _x = .01; _x = _x - -1e-3; _x != 0;',
        ]:
            self.assertEqual(tokenize(source),tokenize(minify(source)))
        for source in ['#define A(x) #x\n hint A( x + y );\n','hint str __LINE__; // keep\n']:
            self.assertEqual(source,minify(source))

    def test_dynamic_rename_rejected(self):
        with self.assertRaises(ValueError):
            minify_files({'a':'private _thing=1; compile "_thing";'},rename_locals=['_thing'])
        with self.assertRaises(ValueError):
            minify_files({'a':'private _thing=1; hint "value _thing";'},rename_locals=['_thing'])

    def test_real_stage_determinism_and_encodings(self):
        with tempfile.TemporaryDirectory() as folder:
            work=Path(folder)
            original={p.relative_to(ROOT/'core.liberation').as_posix():p.read_bytes() for p in (ROOT/'core.liberation').rglob('*.sqf')}
            for name in ('a','b'):
                shutil.copytree(ROOT/'core.liberation',work/name)
                (work/name/'legacy.sqf').write_bytes(b'// comment\n hint "caf\xe9\x8f";')
                (work/name/'macro.sqf').write_bytes(b'#define S(x) #x\r\nhint S( a + b );\r\n')
            a=compact_stage(work/'a',work/'a.json')
            b=compact_stage(work/'b',work/'b.json')
            self.assertEqual(a,b)
            self.assertEqual(a['renamed_files'],len(LEAVES))
            self.assertLess(a['release_bytes'],a['source_bytes'])
            self.assertIn(b'caf\xe9\x8f',(work/'a/legacy.sqf').read_bytes())
            self.assertEqual((work/'a/macro.sqf').read_bytes(),b'#define S(x) #x\r\nhint S( a + b );\r\n')
            for name,data in original.items():
                self.assertEqual(data,(ROOT/'core.liberation'/name).read_bytes())
                self.assertEqual((work/'a'/name).read_bytes(),(work/'b'/name).read_bytes())
                if Path(name).name.lower() in {'classnames_west.sqf','classnames_east.sqf'}:
                    self.assertEqual(data,(work/'a'/name).read_bytes())
            p=work/'b/scripts/shared/functions/HPC_catalogType.sqf'
            p.write_text('params ["_class"]; private _cfg=1; [] call BIS_fnc_log;')
            with self.assertRaisesRegex(ValueError,'calls/exports'):
                compact_stage(work/'b',work/'bad.json')

    def test_source_guard(self):
        with self.assertRaises(ValueError):
            compact_stage(ROOT/'core.liberation',ROOT/'mybuild/never.json')


if __name__ == '__main__':
    unittest.main()
