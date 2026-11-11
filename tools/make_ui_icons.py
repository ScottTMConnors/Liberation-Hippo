"""Draw the mission's UI icons in one flat style and write them to core.liberation/res.

Reputation faces (res/rep/rep0-6), notification badges (res/notif/ui_notif_*) and
action icons (res/ui_*.paa). Resource icons live in make_resource_icons.py.
Needs Pillow and Arma 3 Tools (ARMA3_TOOLS_DIR) for ImageToPAA.
"""
import math
import os
import pathlib
import subprocess

from PIL import Image, ImageDraw, ImageFont

ROOT = pathlib.Path(__file__).resolve().parents[1]
RES = ROOT / "core.liberation" / "res"
OUT = ROOT / "mybuild" / "icons" / "new"
S = 1024
CLEAR = (0, 0, 0, 0)
DARK = (24, 31, 34, 255)
FONT = "C:/Windows/Fonts/bahnschrift.ttf"

# Theme colors (match ui/hippo_theme.hpp accents)
GREEN = (95, 201, 138, 255)
RED = (224, 103, 90, 255)
BLUE = (111, 168, 220, 255)
AMBER = (232, 190, 92, 255)
WHITE = (232, 236, 238, 255)


def canvas():
    im = Image.new("RGBA", (S, S), CLEAR)
    return im, ImageDraw.Draw(im)


def font(size):
    f = ImageFont.truetype(FONT, size)
    try:
        f.set_variation_by_name("Bold")
    except Exception:
        pass
    return f


def tint(col, k):
    return tuple(int(c * k) for c in col[:3]) + (255,)


# ---------------------------------------------------------------- reputation
REP = [  # color, mouth curve (-1 frown .. 1 smile)
    ((224, 103, 90, 255), -1.0),
    ((232, 147, 90, 255), -0.6),
    ((232, 190, 92, 255), -0.25),
    ((169, 180, 184, 255), 0.0),
    ((201, 212, 106, 255), 0.3),
    ((143, 208, 122, 255), 0.65),
    ((95, 201, 138, 255), 1.0),
]


def rep_face(col, curve):
    im, d = canvas()
    d.ellipse((64, 64, 960, 960), fill=col)
    feat = tint(col, 0.32)
    d.ellipse((318, 330, 418, 470), fill=feat)
    d.ellipse((606, 330, 706, 470), fill=feat)
    # mouth: quadratic curve
    pts = []
    for i in range(41):
        t = i / 40
        x = 300 + 424 * t
        y = 660 + curve * 130 * (1 - (2 * t - 1) ** 2)
        pts.append((x, y))
    d.line(pts, fill=feat, width=64, joint="curve")
    for x, y in (pts[0], pts[-1]):
        d.ellipse((x - 32, y - 32, x + 32, y + 32), fill=feat)
    return im


# ---------------------------------------------------------------- notifications
def badge(shape, col):
    im, d = canvas()
    if shape == "circle":
        d.ellipse((48, 48, 976, 976), fill=col)
    elif shape == "octagon":
        r, c = 470, 512
        pts = [(c + r * math.cos(math.radians(22.5 + 45 * i)), c + r * math.sin(math.radians(22.5 + 45 * i))) for i in range(8)]
        d.polygon(pts, fill=col)
    else:  # rounded warning triangle
        d.rounded_rectangle((48, 48, 976, 976), 200, fill=col)
    return im, d


def glyph_flag(d, col=DARK):
    d.rounded_rectangle((330, 240, 386, 800), 20, fill=col)
    d.polygon([(386, 250), (720, 360), (386, 500)], fill=col)


def glyph_text(d, text, size, col=DARK, y=512):
    f = font(size)
    d.text((512, y), text, font=f, fill=col, anchor="mm")


def glyph_lock(d, col, cx=512, cy=660, s=1.0):
    w, h = 300 * s, 230 * s
    d.rounded_rectangle((cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2), 30 * s, fill=col)
    d.arc((cx - 100 * s, cy - h / 2 - 170 * s, cx + 100 * s, cy - h / 2 + 30 * s), 180, 360, fill=col, width=int(44 * s))
    d.rectangle((cx - 100 * s - 22 * s, cy - h / 2 - 70 * s, cx - 100 * s + 22 * s, cy - h / 2), fill=col)
    d.rectangle((cx + 100 * s - 22 * s, cy - h / 2 - 70 * s, cx + 100 * s + 22 * s, cy - h / 2), fill=col)


def glyph_person(d, col=DARK):
    d.ellipse((450, 200, 574, 324), fill=col)
    d.line([(512, 350), (470, 580)], fill=col, width=90)
    d.line([(470, 580), (380, 800)], fill=col, width=80)
    d.line([(470, 580), (600, 700), (620, 810)], fill=col, width=80, joint="curve")
    d.line([(500, 420), (380, 500)], fill=col, width=64)
    d.line([(500, 420), (640, 470)], fill=col, width=64)


def glyph_target(d, col=DARK):
    d.ellipse((262, 262, 762, 762), outline=col, width=64)
    d.ellipse((452, 452, 572, 572), fill=col)
    for a, b in (((512, 170), (512, 330)), ((512, 694), (512, 854)), ((170, 512), (330, 512)), ((694, 512), (854, 512))):
        d.line([a, b], fill=col, width=64)


def glyph_tank(d, col=DARK):
    d.rounded_rectangle((220, 560, 804, 720), 70, fill=col)
    d.rounded_rectangle((360, 440, 640, 580), 40, fill=col)
    d.rectangle((620, 480, 840, 520), fill=col)
    d.ellipse((440, 160, 584, 304), fill=col)       # warning dot
    d.rectangle((488, 300, 536, 400), fill=col)


def notif(kind):
    shape, col, draw = {
        "sec_cap": ("circle", GREEN, lambda d: glyph_flag(d)),
        "sec_los": ("octagon", RED, lambda d: glyph_flag(d)),
        "sec_saf": ("circle", BLUE, lambda d: glyph_flag(d)),
        "sec_una": ("rounded", AMBER, lambda d: glyph_flag(d)),
        "fob_new": ("circle", BLUE, lambda d: (glyph_text(d, "FOB", 300, y=470), d.polygon([(512, 640), (420, 760), (604, 760)], fill=DARK))),
        "fob_sec": ("circle", BLUE, lambda d: glyph_text(d, "FOB", 320)),
        "fob_und": ("rounded", AMBER, lambda d: (glyph_text(d, "FOB", 290, y=400), glyph_lock(d, DARK, cy=700, s=0.8))),
        "fob_los": ("octagon", RED, lambda d: (glyph_text(d, "FOB", 290, y=400), glyph_lock(d, DARK, cy=700, s=0.8))),
        "int": ("circle", BLUE, lambda d: glyph_text(d, "INTEL", 210)),
        "ref": ("rounded", AMBER, lambda d: glyph_person(d)),
        "sob": ("octagon", RED, lambda d: glyph_target(d)),
        "bgp": ("octagon", RED, lambda d: glyph_tank(d)),
    }[kind]
    im, d = badge(shape, col)
    draw(d)
    return im


# ---------------------------------------------------------------- action icons
def act(name):
    im, d = canvas()
    w = WHITE
    if name == "confirm":
        d.line([(220, 540), (420, 740), (820, 300)], fill=(143, 224, 168, 255), width=130, joint="curve")
    elif name == "cancel":
        c = (240, 154, 143, 255)
        d.ellipse((170, 170, 854, 854), outline=c, width=100)
        d.line([(300, 724), (724, 300)], fill=c, width=100)
    elif name == "build":
        c = (242, 204, 107, 255)
        d.line([(250, 820), (600, 470)], fill=c, width=110)              # handle
        # head: a block across the handle end
        cx, cy, ux, uy = 640, 430, 0.7071, 0.7071                       # along the head
        vx, vy = 0.7071, -0.7071                                         # along the handle
        L, W = 230, 95
        d.polygon([(cx - ux * L - vx * W, cy - uy * L - vy * W), (cx + ux * L - vx * W, cy + uy * L - vy * W),
                   (cx + ux * L + vx * W, cy + uy * L + vy * W), (cx - ux * L + vx * W, cy - uy * L + vy * W)], fill=c)
    elif name == "arsenal":
        d.rounded_rectangle((140, 430, 760, 530), 30, fill=w)            # receiver
        d.rectangle((760, 455, 900, 495), fill=w)                        # barrel
        d.polygon([(140, 430), (140, 620), (230, 620), (300, 530)], fill=w)   # stock
        d.polygon([(420, 530), (500, 530), (470, 700), (390, 700)], fill=w)   # grip
        d.rectangle((560, 530, 620, 680), fill=w)                        # magazine
    elif name == "deployfob":
        c = (158, 227, 211, 255)
        d.rounded_rectangle((200, 700, 824, 800), 30, fill=c)
        d.rounded_rectangle((470, 200, 520, 720), 16, fill=c)
        d.polygon([(520, 210), (800, 300), (520, 400)], fill=c)
    elif name == "flipveh":
        d.rounded_rectangle((230, 500, 794, 680), 50, fill=w)
        d.polygon([(330, 500), (420, 380), (640, 380), (720, 500)], fill=w)
        d.ellipse((280, 640, 420, 780), fill=w)
        d.ellipse((604, 640, 744, 780), fill=w)
        d.arc((150, 150, 874, 874), 200, 330, fill=w, width=70)
        d.polygon([(760, 190), (860, 330), (700, 330)], fill=w)
    elif name == "veh":
        d.rounded_rectangle((180, 480, 844, 700), 60, fill=w)
        d.polygon([(290, 480), (380, 300), (644, 300), (734, 480)], fill=w)
        d.polygon([(350, 470), (420, 340), (604, 340), (674, 470)], fill=DARK)
        d.ellipse((240, 640, 400, 800), fill=w)
        d.ellipse((624, 640, 784, 800), fill=w)
    elif name in ("load", "unload"):
        d.line([(200, 600), (200, 820), (824, 820), (824, 600)], fill=w, width=80, joint="curve")
        if name == "load":
            d.rectangle((472, 160, 552, 560), fill=w)
            d.polygon([(330, 500), (694, 500), (512, 700)], fill=w)
        else:
            d.rectangle((472, 360, 552, 720), fill=w)
            d.polygon([(330, 400), (694, 400), (512, 180)], fill=w)
    elif name == "redeploy":
        c = (142, 194, 245, 255)
        d.ellipse((560, 170, 840, 450), fill=c)
        d.polygon([(590, 380), (810, 380), (700, 600)], fill=c)
        d.ellipse((650, 260, 750, 360), fill=CLEAR)
        d.arc((170, 300, 700, 860), 90, 200, fill=c, width=70)
        d.line([(430, 860), (700, 860)], fill=c, width=70)
    elif name == "recycle":
        c = (158, 227, 211, 255)
        for k in range(3):
            a = math.radians(-90 + 120 * k)
            d.arc((190, 190, 834, 834), -90 + 120 * k + 15, -90 + 120 * k + 95, fill=c, width=90)
            e = math.radians(-90 + 120 * k + 100)
            x, y = 512 + 322 * math.cos(e), 512 + 322 * math.sin(e)
            nx, ny = -math.sin(e), math.cos(e)
            d.polygon([(x + 110 * math.cos(e), y + 110 * math.sin(e)), (x - 110 * math.cos(e), y - 110 * math.sin(e)), (x + 120 * nx, y + 120 * ny)], fill=c)
    elif name == "rotation":
        d.arc((190, 190, 834, 834), 30, 330, fill=w, width=90)
        e = math.radians(30)
        x, y = 512 + 322 * math.cos(e), 512 + 322 * math.sin(e)
        d.polygon([(x - 120, y - 30), (x + 120, y - 30), (x, y + 130)], fill=w)
    elif name == "wfuel":
        c = (242, 193, 78, 255)
        d.polygon([(512, 150), (760, 560), (264, 560)], fill=c)
        d.ellipse((264, 400, 760, 896), fill=c)
    return im


ACTIONS = ["confirm", "cancel", "build", "arsenal", "deployfob", "flipveh", "veh", "load", "unload", "redeploy", "recycle", "rotation", "wfuel"]
NOTIFS = ["sec_cap", "sec_los", "sec_saf", "sec_una", "fob_new", "fob_sec", "fob_und", "fob_los", "int", "ref", "sob", "bgp"]


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    tools = pathlib.Path(os.environ.get("ARMA3_TOOLS_DIR") or "C:/Program Files (x86)/Steam/steamapps/common/Arma 3 Tools")
    jobs = []
    for i, (col, curve) in enumerate(REP):
        jobs.append((rep_face(col, curve), 128, RES / "rep" / f"rep{i}.paa"))
    for k in NOTIFS:
        jobs.append((notif(k), 128, RES / "notif" / f"ui_notif_{k}.paa"))
    for k in ACTIONS:
        jobs.append((act(k), 64, RES / f"ui_{k}.paa"))
    sheet = Image.new("RGBA", (10 * 140, ((len(jobs) + 9) // 10) * 140), (30, 36, 38, 255))
    for n, (im, size, dst) in enumerate(jobs):
        small = im.resize((size, size), Image.LANCZOS)
        png = OUT / (dst.stem + ".png")
        small.save(png)
        tile = small.resize((96, 96), Image.LANCZOS) if size != 96 else small
        sheet.alpha_composite(tile, ((n % 10) * 140 + 22, (n // 10) * 140 + 22))
        subprocess.run([str(tools / "ImageToPAA" / "ImageToPAA.exe"), str(png), str(dst)], check=True, capture_output=True)
    sheet.save(OUT.parent / "new_all.png")
    # small-size check: how they read at HUD/action-menu size
    small = Image.new("RGBA", (len(jobs) * 36, 36), (30, 36, 38, 255))
    for n, (im, size, dst) in enumerate(jobs):
        small.alpha_composite(im.resize((32, 32), Image.LANCZOS), (n * 36 + 2, 2))
    small.resize((small.width * 2, small.height * 2), Image.NEAREST).save(OUT.parent / "new_small.png")
    print(len(jobs), "icons written")


if __name__ == "__main__":
    main()
