import os
import unittest
from pathlib import Path

import map_layout

SQM = '''version=54;
class Mission
{
	class Entities
	{
		items=2;
		class Item0
		{
			dataType="Group";
			side="West";
		};
		class Item1
		{
			dataType="Group";
			class Entities
			{
				class Item0
				{
					init="this setVariable [""GRLIB_is_Commander"", true, true];";
				};
			};
		};
	};
};
'''


class MapLayoutTest(unittest.TestCase):
    def test_fix_moves_commander_first(self):
        self.assertTrue(map_layout.problems(SQM))
        fixed = map_layout.fix(SQM)
        self.assertEqual(map_layout.problems(fixed), [])
        self.assertLess(fixed.index('GRLIB_is_Commander'), fixed.index('side="West"'))
        self.assertEqual(fixed.count('\n\t\tclass Item0'), 1)
        self.assertEqual(fixed.count('\n\t\tclass Item1'), 1)

    def test_missing_commander_is_reported(self):
        self.assertTrue(map_layout.problems(SQM.replace('GRLIB_is_Commander', 'x')))

    @unittest.skipUnless(map_layout.converter(os.environ.get('ARMA3_DIR', '')).exists(), 'needs ARMA3_DIR with Arma 3 Tools')
    def test_every_map_is_up_to_date(self):
        self.assertEqual(map_layout.check_maps(map_layout.all_maps(), os.environ['ARMA3_DIR']), {})


if __name__ == '__main__':
    unittest.main()
