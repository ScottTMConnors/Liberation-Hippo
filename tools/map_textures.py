"""Generate the map overlay marker textures (core.liberation/res/map/*.paa).

White shapes on transparency, tinted in game by drawIcon's colour. Run after
changing a shape; needs Pillow and Arma 3 Tools (ARMA3_TOOLS_DIR) for ImageToPAA.

    python tools/map_textures.py            # PNG + PAA
    python tools/map_textures.py --png-only # PNG previews only
"""
import math
import os
import subprocess
import sys

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "core.liberation", "res", "map")
N = 128          # texture size (power of two)
SS = 4           # supersampling for clean edges


def canvas():
    return Image.new("L", (N * SS, N * SS), 0)


def finish(mask, blur=0):
    mask = mask.resize((N, N), Image.LANCZOS)
    if blur:
        mask = mask.filter(ImageFilter.GaussianBlur(blur))
    img = Image.new("RGBA", (N, N), (255, 255, 255, 0))
    img.putalpha(mask)
    return img


def ring(radius=0.42, width=0.07, dashes=0, gap=0.45):
    m = canvas()
    d = ImageDraw.Draw(m)
    c = N * SS / 2
    r = radius * N * SS
    w = int(width * N * SS)
    box = [c - r, c - r, c + r, c + r]
    if dashes:
        step = 360 / dashes
        for i in range(dashes):
            a = i * step - 90
            d.arc(box, a, a + step * (1 - gap), fill=255, width=w)
    else:
        d.ellipse(box, outline=255, width=w)
    return m


def halo():
    # soft disc: opaque centre fading out; used dark behind icons for contrast
    m = Image.new("L", (N, N), 0)
    px = m.load()
    c = (N - 1) / 2
    for y in range(N):
        for x in range(N):
            t = math.hypot(x - c, y - c) / (N / 2)
            a = 1.0 if t < 0.45 else max(0.0, 1 - (t - 0.45) / 0.55)
            px[x, y] = int(255 * a ** 1.6)
    img = Image.new("RGBA", (N, N), (255, 255, 255, 0))
    img.putalpha(m)
    return img


def brackets():
    m = canvas()
    d = ImageDraw.Draw(m)
    s = N * SS
    p = int(0.1 * s)      # inset
    L = int(0.26 * s)     # arm length
    w = int(0.07 * s)     # thickness
    for sx, sy in ((0, 0), (1, 0), (0, 1), (1, 1)):
        x = p if sx == 0 else s - p - w
        y = p if sy == 0 else s - p - w
        hx = p if sx == 0 else s - p - L
        vy = p if sy == 0 else s - p - L
        d.rectangle([hx, y, hx + L, y + w], fill=255)
        d.rectangle([x, vy, x + w, vy + L], fill=255)
    return m


def cross():
    m = canvas()
    d = ImageDraw.Draw(m)
    s = N * SS
    p = int(0.2 * s)
    w = int(0.11 * s)
    d.line([p, p, s - p, s - p], fill=255, width=w)
    d.line([s - p, p, p, s - p], fill=255, width=w)
    return m


TEXTURES = {
    "halo": lambda: halo(),
    "ring": lambda: finish(ring()),
    "ring_thin": lambda: finish(ring(width=0.04)),
    "ring_dash": lambda: finish(ring(width=0.06, dashes=10)),
    "ring_soft": lambda: finish(ring(width=0.1), blur=2.5),
    "brackets": lambda: finish(brackets()),
    "cross": lambda: finish(cross()),
}


def main(argv):
    png_only = "--png-only" in argv
    os.makedirs(OUT, exist_ok=True)
    pngs = []
    for name, make in TEXTURES.items():
        path = os.path.join(OUT, name + ".png")
        make().save(path)
        pngs.append(path)
    if png_only:
        print("wrote", len(pngs), "PNGs to", OUT)
        return 0
    tools = os.environ.get("ARMA3_TOOLS_DIR", r"C:\Program Files (x86)\Steam\steamapps\common\Arma 3 Tools")
    exe = os.path.join(tools, "ImageToPAA", "ImageToPAA.exe")
    if not os.path.exists(exe):
        print("ImageToPAA not found; set ARMA3_TOOLS_DIR", file=sys.stderr)
        return 1
    for png in pngs:
        subprocess.run([exe, png, png[:-4] + ".paa"], check=True, capture_output=True)
        os.remove(png)
    print("wrote", len(pngs), "PAAs to", OUT)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
