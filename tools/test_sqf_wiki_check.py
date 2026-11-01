"""Offline SQF checker: seeded errors are reported, valid SQF is not."""
import collections
import tempfile
import unittest
from pathlib import Path
from sqf_wiki_check import check_file, DEFAULT_WIKI, load_wiki

CMDS = {
    'hint': {'name': 'hint', 'server': False, 'problem': False, 'since': (0, 50)},
    'addeventhandler': {'name': 'addEventHandler', 'server': False, 'problem': False, 'since': (0, 50)},
    'remoteexec': {'name': 'remoteExec', 'server': False, 'problem': False, 'since': (1, 50)},
    'newthing': {'name': 'newThing', 'server': False, 'problem': False, 'since': (2, 24)},
}
EVENTS = {'standard': {'killed', 'handledamage'}}


def run(source):
    with tempfile.TemporaryDirectory() as tmp:
        path = Path(tmp) / 'case.sqf'
        path.write_text(source, encoding='utf8')
        report = collections.defaultdict(list)
        usage, defined, reads = collections.defaultdict(list), set(), collections.defaultdict(list)
        check_file(path, 'case.sqf', CMDS, EVENTS, (2, 22), report, usage, defined, reads)
        return report, defined, reads


class CheckerTests(unittest.TestCase):
    def test_valid_sqf_is_clean(self):
        report, defined, reads = run(
            '#define TAG(x) x\n'
            'TAG_value = [1, (2 + 3), {hint "a ""quoted"" ]"}];\n'
            "hint 'single '']'' quote'; /* ] */ // ]\n"
            'player addEventHandler ["Killed", {}];\n'
            'if (_a == 1) then {};\n'
            '["x"] remoteExec ["hint", 0];\n')
        self.assertEqual(report['lexical'], [])
        self.assertEqual(report['unknown_eh'], [])
        self.assertIn('tag_value', defined)
        self.assertEqual(report['remote_targets'], [('hint', 'case.sqf:6')])

    def test_seeded_errors(self):
        report, _, _ = run('private _a = [1,2,];\nif (_a = 3) then {};\n'
                           'player addEventHandler ["Killedd", {}];\nnewThing;\n')
        lexical = '\n'.join(report['lexical'])
        self.assertIn('case.sqf:1: trailing comma before ]', lexical)
        self.assertIn('case.sqf:2: assignment inside if condition', lexical)
        self.assertEqual(report['unknown_eh'], ['case.sqf:3: addEventHandler "Killedd"'])
        self.assertEqual(len(report['too_new']), 1)

    def test_unbalanced_and_unterminated(self):
        self.assertIn('case.sqf:2: unexpected ] (open ( from line 2)', run('x = 1;\n_b = [(2];\n')[0]['lexical'])
        self.assertIn('case.sqf:1: unterminated string', run('x = "open;\n')[0]['lexical'])
        self.assertIn('case.sqf:1: unclosed {', run('x = {\n')[0]['lexical'])

    @unittest.skipUnless((DEFAULT_WIKI / 'commands').is_dir(), 'arma3-wiki-mcp cache not present')
    def test_wiki_cache_loads(self):
        cmds, events = load_wiki(DEFAULT_WIKI)
        self.assertEqual(cmds['setdamage']['eff'], 'Global')
        self.assertIn('killed', events['standard'])


if __name__ == '__main__':
    unittest.main()
