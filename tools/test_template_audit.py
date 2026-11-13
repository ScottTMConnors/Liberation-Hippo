import pathlib
import tempfile
import unittest

import template_audit as ta


class TemplateAuditTest(unittest.TestCase):
    def test_repository_templates_are_clean(self):
        self.assertEqual(ta.audit(), [])

    def test_legacy_tier_spreads_over_its_band_by_price(self):
        entries = [('a', ['5', '100', '10', 'GRLIB_perm_tank']),
                   ('b', ['5', '900', '10', 'GRLIB_perm_tank']),
                   ('c', ['5', '400', '10', 'GRLIB_perm_tank'])]
        self.assertEqual(ta.band_ranks(entries),
                         {'a': 'GRLIB_perm_sgm', 'c': 'GRLIB_perm_1lt', 'b': 'GRLIB_perm_cpt'})

    def test_missing_comma_is_reported(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = pathlib.Path(tmp)
            (root / 'scripts/shared').mkdir(parents=True)
            (root / 'scripts/shared/fetch_params.sqf').write_text('', encoding='utf-8')
            (root / 'mod_template/MOD_X').mkdir(parents=True)
            (root / 'mod_template/MOD_X/classnames_west.sqf').write_text(
                'light_vehicles = [\n\t["X_a",1,10,1,0]\n\t// ["X_old",1,1,1,0],\n\t["X_b",1,10,1,0]\n];\n', encoding='utf-8')
            self.assertTrue(any('missing comma' in p for p in ta.audit(root)))

    def test_fix_repairs_a_template(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = pathlib.Path(tmp)
            (root / 'scripts/shared').mkdir(parents=True)
            (root / 'scripts/shared/fetch_params.sqf').write_text(
                (ta.ROOT / 'scripts/shared/fetch_params.sqf').read_text(encoding='utf-8'), encoding='utf-8')
            for name, body in {
                'A3_BLU': 'light_vehicles = [\n\t["B_Quadbike_01_F",1,5,1,0]\n];\n',
                'MOD_X': ('fuel_truck_typename = "X_fuel_truck";\n'
                          'light_vehicles = [\n\t["B_Quadbike_01_F",1,50,1,GRLIB_perm_inf],\n'
                          '\t["X_car",1,10,1,GRLIB_perm_inf],\n\t["X_car",1,10,1,GRLIB_perm_inf]\n];\n'
                          'static_vehicles = [\n\t["X_gun",0,20,3,GRLIB_perm_log]\n];\n'
                          'support_vehicles_west = [\n\t["X_Van_fuel",5,15,20,GRLIB_perm_inf]\n];\n'),
            }.items():
                (root / 'mod_template' / name).mkdir(parents=True)
                (root / 'mod_template' / name / 'classnames_west.sqf').write_text(body, encoding='utf-8')
            self.assertTrue(ta.audit(root, fix=True))
            self.assertEqual(ta.audit(root), [])
            text = (root / 'mod_template/MOD_X/classnames_west.sqf').read_text(encoding='utf-8')
            self.assertIn('["B_Quadbike_01_F",1,5,1,0]', text)
            self.assertEqual(text.count('"X_car"'), 1)
            self.assertIn('["X_gun",0,20,0,GRLIB_perm_sgt]', text)
            self.assertIn('["X_Van_fuel",5,120,60,GRLIB_perm_sgt]', text)
            self.assertNotIn(',\n];', text)


if __name__ == '__main__':
    unittest.main()
