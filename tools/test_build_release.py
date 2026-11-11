"""Release build helpers: ScenarioData stamping for the server browser.

Run from tools/: python -m unittest test_build_release
"""
import unittest

import build_malden

SQM = '''version=54;
class EditorData
{
	author="someone";
};
class ScenarioData
{
	author="pSiKO";
	briefing=0;
	class Header
	{
		gameType="CTI";
	};
};
class Mission
{
	class Intel
	{
		briefingName="Hippos Conquest";
	};
};
'''


class ScenarioData(unittest.TestCase):
    def test_adds_browser_fields(self):
        out = build_malden.stamp_scenario_data(SQM, 'Hippos Conquest v9.9.9')
        block = out[out.index('class ScenarioData'):out.index('class Mission')]
        self.assertIn('overviewPicture="res\\overview.paa";', block)
        self.assertIn('overviewText="' + build_malden.OVERVIEW_TEXT + '";', block)
        self.assertIn('author="TheHungryHippo";', block)
        self.assertIn('onLoadName="Hippos Conquest v9.9.9";', block)
        self.assertNotIn('pSiKO', block)
        self.assertIn('class Header', block)

    def test_leaves_other_classes_alone(self):
        out = build_malden.stamp_scenario_data(SQM, 't')
        self.assertIn('class EditorData\n{\n\tauthor="someone";', out)
        self.assertIn('briefingName="Hippos Conquest";', out)

    def test_idempotent(self):
        once = build_malden.stamp_scenario_data(SQM, 't')
        self.assertEqual(build_malden.stamp_scenario_data(once, 't'), once)

    def test_crlf(self):
        out = build_malden.stamp_scenario_data(SQM.replace('\n', '\r\n'), 't')
        self.assertEqual(out.count('overviewPicture='), 1)

    def test_overview_text_is_safe(self):
        self.assertNotIn('"', build_malden.OVERVIEW_TEXT)
        self.assertLess(len(build_malden.OVERVIEW_TEXT), 400)


if __name__ == '__main__':
    unittest.main()
