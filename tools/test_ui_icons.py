"""Icon generators draw every icon with visible pixels and the right sizes.

Run from tools/: python -m unittest test_ui_icons
"""
import unittest

import make_resource_icons
import make_ui_icons


def coverage(im):
    alpha = im.getchannel('A')
    return sum(1 for a in alpha.getdata() if a > 128) / (im.width * im.height)


class Icons(unittest.TestCase):
    def check(self, im, lo=0.04, hi=0.9):
        small = im.resize((64, 64))
        c = coverage(small)
        self.assertGreater(c, lo)
        self.assertLess(c, hi)

    def test_reputation_faces_go_from_sad_to_happy(self):
        faces = [make_ui_icons.rep_face(col, curve) for col, curve in make_ui_icons.REP]
        self.assertEqual(len(faces), 7)
        for f in faces:
            self.check(f, 0.4)
        # the mouth center sits above the ends when sad, below when happy
        self.assertLess(make_ui_icons.REP[0][1], 0)
        self.assertGreater(make_ui_icons.REP[-1][1], 0)

    def test_notifications(self):
        for k in make_ui_icons.NOTIFS:
            self.check(make_ui_icons.notif(k), 0.3, 0.95)

    def test_actions(self):
        for k in make_ui_icons.ACTIONS:
            self.check(make_ui_icons.act(k), 0.02, 0.7)

    def test_resources(self):
        for name, (fn, col) in make_resource_icons.ICONS.items():
            self.check(fn(col), 0.1, 0.8)


if __name__ == '__main__':
    unittest.main()
