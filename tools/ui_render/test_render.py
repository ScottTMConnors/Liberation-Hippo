"""Unit tests: python -m unittest test_render (from tools/ui_render)."""
import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import config as C  # noqa: E402
import preproc as P  # noqa: E402
from expr import Env, evaluate  # noqa: E402


class PreprocTest(unittest.TestCase):
    def pp(self, text):
        return P.Preprocessor().process_text(text)

    def test_object_and_function_macros(self):
        out = self.pp("#define A 2\n#define ADD(x,y) (x + y)\nv = ADD(A, 3);")
        self.assertIn("v = (2 + 3);", out)

    def test_nested_parens_in_args_and_strings_untouched(self):
        out = self.pp('#define A 9\n#define F(x) x*2\nv = F((1,2)); s = "A";')
        self.assertIn("(1,2)*2", out)
        self.assertIn('"A"', out)

    def test_conditionals_undef_continuation_comments(self):
        src = ("#define X\n#ifdef X\na=1;\n#else\na=2;\n#endif\n#undef X\n#ifndef X\nb=1;\n#endif\n"
               "#define LONG 1 + \\\n 2\nc = LONG; // comment\n/* block\n comment */d=1;")
        out = self.pp(src)
        self.assertIn("a=1;", out)
        self.assertNotIn("a=2;", out)
        self.assertIn("b=1;", out)
        self.assertIn("c = 1 +   2;", out)
        self.assertNotIn("comment", out)

    def test_stringize_and_concat(self):
        out = self.pp('#define S(x) #x\n#define CAT(a,b) a##b\nv = S(hello); w = CAT(foo,bar);')
        self.assertIn('v = "hello";', out)
        self.assertIn("w = foobar;", out)

    def test_include_backslash(self):
        with tempfile.TemporaryDirectory() as d:
            os.makedirs(os.path.join(d, "sub"))
            with open(os.path.join(d, "sub", "inc.hpp"), "w") as f:
                f.write("#define FROM_INC 5\n")
            with open(os.path.join(d, "main.ext"), "w") as f:
                f.write('#include "sub\\inc.hpp"\nv = FROM_INC;\n#include "missing.hpp"\n')
            p = P.Preprocessor()
            out = p.process_file(os.path.join(d, "main.ext"))
            self.assertIn("v = 5;", out)
            self.assertTrue(any("missing.hpp" in w for w in p.warnings))


class ConfigTest(unittest.TestCase):
    def test_inheritance_and_scope(self):
        root, warns = C.parse('''
            class Base { a = 1; class Inner { q = 3; }; };
            class D : Base { b = "x ""y"""; arr[] = {1, {2, 3}, "s"}; arr[] += {4}; };
            class Dlg { class controls { class Ctl : Base { c = 2; }; class Ctl2 : Ctl {}; }; };
            class Fwd;
        ''')
        self.assertEqual(warns, [])
        d = root.get("d")
        self.assertEqual(d.get("a"), "1")
        self.assertEqual(d.get("b"), 'x "y"')
        self.assertIsInstance(d.get("b"), C.Str)
        self.assertEqual(d.get("arr"), ["1", ["2", "3"], "s", "4"])
        self.assertEqual(d.get("Inner").get("q"), "3")
        ctl2 = root.get("Dlg").get("controls").get("Ctl2")
        self.assertEqual(ctl2.get("c"), "2")   # base found in enclosing scope
        self.assertEqual(ctl2.get("a"), "1")   # then root
        self.assertEqual([c.name for c in root.get("Dlg").get("controls").classes()], ["Ctl", "Ctl2"])

    def test_same_name_override_resolves_outer(self):
        root, _ = C.parse("class T { v = 1; }; class Dlg { class T : T { w = 2; }; };")
        t = root.get("Dlg").get("T")
        self.assertEqual((t.get("v"), t.get("w")), ("1", "2"))

    def test_bad_entry_is_skipped(self):
        root, warns = C.parse("class A { = broken; x = 1; };")
        self.assertTrue(warns)
        self.assertEqual(root.get("A").get("x"), "1")


class ExprTest(unittest.TestCase):
    def test_safezone_1080_verylarge(self):
        e = Env(1920, 1080, "verylarge")
        self.assertAlmostEqual(e.szH, 1.0)
        self.assertAlmostEqual(e.szW, 4 / 3, places=5)
        self.assertAlmostEqual(e.szX, -1 / 6, places=5)
        self.assertEqual(e.px(e.szX, e.szY), (0.0, 0.0))

    def test_safezone_ultrawide_matches_rpt(self):
        e = Env(840, 360, 1.0)  # logged: X=-0.375 W=1.75 H=1
        self.assertAlmostEqual(e.szX, -0.375)
        self.assertAlmostEqual(e.szW, 1.75)

    def test_arithmetic(self):
        e = Env(1920, 1080, "normal")
        self.assertAlmostEqual(evaluate("safezoneY + 4 * (safezoneH / 54)", e), e.szY + 4 * e.szH / 54)
        self.assertAlmostEqual(evaluate("-(1 + 2) * 3 / 2", e), -4.5)
        self.assertAlmostEqual(evaluate("0.5 min 0.2", e), 0.2)
        self.assertAlmostEqual(evaluate("max(1, 3)", e), 3)
        self.assertAlmostEqual(evaluate("0x800", e), 2048)
        self.assertAlmostEqual(evaluate("pixelH * 2", e), 2 * e.szH / 1080)

    def test_profile_getvariable_default(self):
        e = Env()
        v = evaluate("(profilenamespace getvariable ['GUI_BCG_RGB_R',0.13])", e)
        self.assertAlmostEqual(v, 0.13)
        v = evaluate("profileNamespace getVariable ['IGUI_GRID_X', (safezoneX + 0.5)] + 1", e)
        self.assertAlmostEqual(v, e.szX + 1.5)


if __name__ == "__main__":
    unittest.main()
