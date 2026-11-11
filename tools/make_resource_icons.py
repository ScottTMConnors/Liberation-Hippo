"""Draw the resource icons (manpower, ammo, fuel) as flat 128x128 glyphs and write
core.liberation/res/ui_*.paa. Needs Pillow and Arma 3 Tools (ARMA3_TOOLS_DIR)."""
from PIL import Image, ImageDraw
import os
import pathlib
import subprocess

S = 1024          # supersampled canvas
OUT = 128
ROOT = pathlib.Path(__file__).resolve().parents[1]
HERE = ROOT / "mybuild" / "icons"
RES = ROOT / "core.liberation" / "res"
CLEAR = (0, 0, 0, 0)


def canvas():
    im = Image.new("RGBA", (S, S), CLEAR)
    return im, ImageDraw.Draw(im)


def manpower(col):
    im, d = canvas()
    # shoulders
    d.ellipse((150, 610, 874, 1330), fill=col)
    d.rectangle((0, 950, S, S), fill=CLEAR)
    # gap around the head
    d.ellipse((300, 250, 724, 674), fill=CLEAR)
    # head and helmet
    d.ellipse((362, 330, 662, 630), fill=col)
    d.chord((318, 170, 706, 560), 180, 360, fill=col)
    d.rounded_rectangle((292, 352, 732, 412), 30, fill=col)
    return im


def ammo(col):
    im, d = canvas()
    for cx, lift in ((300, 0), (512, -70), (724, 0)):
        top = 190 + lift
        d.ellipse((cx - 86, top, cx + 86, top + 380), fill=col)        # tip
        d.rectangle((cx - 86, top + 190, cx + 86, 880), fill=col)     # case
        d.rectangle((cx - 86, top + 250, cx + 86, top + 276), fill=CLEAR)  # crimp groove
        d.rounded_rectangle((cx - 98, 880, cx + 98, 930), 12, fill=col)   # rim
    return im


def fuel(col):
    im, d = canvas()
    d.rounded_rectangle((240, 300, 800, 940), 80, fill=col)            # body
    d.rounded_rectangle((240, 160, 600, 330), 50, fill=col)            # handle bar
    d.rounded_rectangle((292, 200, 548, 278), 30, fill=CLEAR)          # handle hole
    d.polygon([(650, 300), (712, 150), (800, 182), (770, 300)], fill=col)  # spout
    # embossed X
    for a, b in (((360, 450), (680, 820)), ((680, 450), (360, 820))):
        d.line([a, b], fill=CLEAR, width=58)
    return im


ICONS = {
    "ui_manpo": (manpower, (95, 208, 138, 255)),
    "ui_ammo": (ammo, (239, 111, 92, 255)),
    "ui_fuel": (fuel, (242, 193, 78, 255)),
}

if __name__ == "__main__":
    HERE.mkdir(parents=True, exist_ok=True)
    tools = pathlib.Path(os.environ.get("ARMA3_TOOLS_DIR") or "C:/Program Files (x86)/Steam/steamapps/common/Arma 3 Tools")
    sheet = Image.new("RGBA", (3 * 136, 136), (30, 36, 38, 255))
    for k, (name, (fn, col)) in enumerate(ICONS.items()):
        icon = fn(col).resize((OUT, OUT), Image.LANCZOS)
        icon.save(HERE / f"{name}.png")
        sheet.alpha_composite(icon, (k * 136 + 4, 4))
    small = Image.new("RGBA", (3 * 40, 40), (30, 36, 38, 255))
    for k, name in enumerate(ICONS):
        small.alpha_composite(Image.open(HERE / f"{name}.png").resize((32, 32), Image.LANCZOS), (k * 40 + 4, 4))
    sheet.save(HERE / "new_sheet.png")
    small.resize((small.width * 3, small.height * 3), Image.NEAREST).save(HERE / "new_sheet_small.png")
    # Convert to the mission's .paa files (Arma 3 Tools ImageToPAA).
    for name in ICONS:
        subprocess.run([str(tools / "ImageToPAA" / "ImageToPAA.exe"), str(HERE / f"{name}.png"), str(RES / f"{name}.paa")], check=True, capture_output=True)
        print("wrote", RES / f"{name}.paa")
