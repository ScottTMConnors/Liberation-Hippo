import pathlib
import tempfile
import unittest

import template_audit as ta
import template_pack as tp


def make_root(tmp, templates):
    """A temporary mission root holding mod_template.sqf built from {"NAME\\file.sqf": code}."""
    root = pathlib.Path(tmp)
    (root / 'scripts/shared').mkdir(parents=True)
    (root / 'scripts/shared/fetch_params.sqf').write_text(
        (ta.ROOT / 'scripts/shared/fetch_params.sqf').read_text(encoding='utf-8'), encoding='utf-8')
    tp.write_pack(root, 'GRLIB_mod_list_west = [];\n', '', templates)
    return root


class TemplateAuditTest(unittest.TestCase):
    def test_repository_templates_are_clean(self):
        self.assertEqual(ta.audit(), [])

    def test_pack_round_trips(self):
        head, index, files = tp.read_pack(ta.ROOT)
        with tempfile.TemporaryDirectory() as tmp:
            tp.write_pack(tmp, head, index, files)
            self.assertEqual(tp.read_pack(tmp), (head, index, files))

    def test_legacy_tier_spreads_over_its_band_by_price(self):
        entries = [('a', ['5', '100', '10', 'GRLIB_perm_tank']),
                   ('b', ['5', '900', '10', 'GRLIB_perm_tank']),
                   ('c', ['5', '400', '10', 'GRLIB_perm_tank'])]
        self.assertEqual(ta.band_ranks(entries),
                         {'a': 'GRLIB_perm_sgm', 'c': 'GRLIB_perm_1lt', 'b': 'GRLIB_perm_cpt'})

    def test_missing_comma_is_reported(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = make_root(tmp, {'MOD_X\\classnames_west.sqf':
                                   'light_vehicles = [\n\t["X_a",1,10,1,0]\n\t// ["X_old",1,1,1,0],\n\t["X_b",1,10,1,0]\n];'})
            self.assertTrue(any('missing comma' in p for p in ta.audit(root)))

    def test_fix_repairs_a_template(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = make_root(tmp, {
                'A3_BLU\\classnames_west.sqf': 'light_vehicles = [\n\t["B_Quadbike_01_F",1,5,1,0]\n];',
                'MOD_X\\classnames_west.sqf': (
                    'fuel_truck_typename = "X_fuel_truck";\n'
                    'infantry_units_west = [\n\t["X_rifleman",1,0,0,0]\n];\n'
                    'light_vehicles = [\n\t["B_Quadbike_01_F",1,50,1,GRLIB_perm_inf],\n'
                    '\t["X_car",1,10,1,GRLIB_perm_inf],\n\t["X_car",1,10,1,GRLIB_perm_inf]\n];\n'
                    'static_vehicles = [\n\t["X_gun",0,20,3,GRLIB_perm_log]\n];\n'
                    'support_vehicles_west = [\n\t["X_Van_fuel",5,15,20,GRLIB_perm_inf]\n];'),
            })
            self.assertTrue(ta.audit(root, fix=True))
            self.assertEqual(ta.audit(root), [])
            head, index, files = tp.read_pack(root)
            text = files['MOD_X\\classnames_west.sqf']
            self.assertIn('["B_Quadbike_01_F",1,5,1,0]', text)
            self.assertEqual(text.count('"X_car"'), 1)
            self.assertIn('["X_gun",0,20,0,GRLIB_perm_sgt]', text)
            self.assertIn('["X_Van_fuel",5,120,60,GRLIB_perm_sgt]', text)
            self.assertNotIn(',\n];', text)
            self.assertIn('["mod_x", [["X_rifleman"], []]]', index)


if __name__ == '__main__':
    unittest.main()
