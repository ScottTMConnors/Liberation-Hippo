#!/usr/bin/env python3
"""Offline renderer for the map overlay (scripts/client/markers/HPC_mapOverlay.sqf).

Draws a map background, the overlay markers in the same style as HPC_fnc_mapDraw
(halo, icon, outlined label, rings, last known / destroyed states, hover brackets,
order lines) and then the overlay controls of ui/hippo_map.hpp through the dialog
renderer (class HPC_MapOverlayPreview, filled with --data like render.py).

    python tools/ui_render/map_render.py --markers tools/ui_render/samples/map_markers.json \
        --data tools/ui_render/samples/map_overlay.json -o mybuild/ui_render_out/map.png

Marker JSON: {"markers": [...], "lines": [...], "background": {...}}
  marker: {"icon": "b_inf" | "<texture path>", "color": [r,g,b,a], "at": [x, y] (0-1 of the
           screen), "size": 24, "text": "label", "state": "live|mine|ghost|dead|vehicle",
           "combat": 0-1 (pulse phase) | null, "disabled": bool, "hover": bool, "selected": bool,
           "ordered_to": [x, y]}
  line:   {"from": [x, y], "to": [x, y], "color": [r,g,b,a]}
Positions are screen fractions so a sample does not depend on the map scale.
Keep the style constants below in step with HPC_fnc_mapDraw.
"""
import argparse
import json
import math
import os
import random
import sys
import tempfile

from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import assets as A  # noqa: E402
import render as R  # noqa: E402
from expr import Env  # noqa: E402

NATO = r"\A3\ui_f\data\map\markers\nato\{}.paa"
MARKERS = {
    "mil_dot": r"\A3\ui_f\data\map\markers\military\dot_CA.paa",
    "mil_unknown": r"\A3\ui_f\data\map\markers\military\unknown_CA.paa",
    "mil_circle": r"\A3\ui_f\data\map\markers\military\circle_CA.paa",
}
TEX = "res/map/{}.paa"
MIL = r"\A3\ui_f\data\map\markers\military\{}_CA.paa"
LOC = r"\A3\ui_f\data\map\mapcontrol\{}_CA.paa"
CFG_MARKERS = {   # CfgMarkers classes the world layer uses -> icon texture
    "mil_pickup": MIL.format("pickup"), "mil_warning": MIL.format("warning"), "mil_objective": MIL.format("objective"),
    "mil_triangle": MIL.format("triangle"), "mil_arrow2": MIL.format("arrow2"), "mil_flag": MIL.format("flag"),
    "loc_Fuelstation": LOC.format("fuelstation"), "loc_Transmitter": LOC.format("transmitter"),
    "loc_defend": r"\A3\ui_f\data\map\locationtypes\defend_CA.paa",
}   # mission textures from tools/map_textures.py

# --- style (HPC_fnc_mapDraw)
HALO_SCALE = 1.45
HALO_ALPHA = 0.15   # 0.3 in game, which shows about half as strong (map_frame.py)
LABEL_SIZE = 0.032        # drawIcon textSize: about 0.7 x screen height in sizeEx terms (not UI-scaled)
LABEL_FONT = "robotocondensedbold"
GHOST = (0.95, 0.42, 0.36)
DEAD = (0.58, 0.61, 0.63)


def icon_path(name):
    if "\\" in name or "/" in name:
        return name
    if name in CFG_MARKERS:
        return CFG_MARKERS[name]
    if name in MARKERS:
        return MARKERS[name]
    return NATO.format(name)


class MapPainter:
    def __init__(self, env, assets, warn):
        self.env, self.assets, self.warn = env, assets, warn
        # drawIcon sizes are screen pixels at 1080p-ish; scale with the output height
        self.k = env.height / 1080.0 * 1.2   # drawIcon size 20 draws about 24 px at 1080p (calibrated with map_frame.py)

    def tex(self, path, color, size, angle=0):
        img = self.assets.image(path)
        if img is None:
            return None
        px = max(2, int(round(size * self.k)))
        img = img.resize((px, px), Image.LANCZOS)
        img = R.tint(img, R.to_rgba(color))
        if angle:
            img = img.rotate(-angle, resample=Image.BICUBIC, expand=False)
        return img

    def icon(self, surface, path, color, at, size, angle=0):
        img = self.tex(path, color, size, angle)
        if img is None:
            return
        x, y = at
        surface.alpha_composite(img, (int(x - img.width / 2), int(y - img.height / 2)))

    def label(self, surface, text, color, at, size):
        if not text:
            return
        px = LABEL_SIZE * 0.55 * self.env.height
        font, cap = R.get_font(LABEL_FONT, px)
        x = at[0] + size * self.k / 2 + 2
        y = at[1]
        layer = Image.new("RGBA", surface.size, (0, 0, 0, 0))
        d = ImageDraw.Draw(layer)
        rgba = R.to_rgba(color)
        d.text((x, y), text, font=font, fill=rgba, anchor="lm", stroke_width=max(1, int(1.6 * self.k)),
               stroke_fill=(0, 0, 0, int(rgba[3] * 0.85)))
        surface.alpha_composite(layer)

    def mark(self, surface, icon, color, at, size, text, angle=0):
        a = color[3] if len(color) > 3 else 1
        self.icon(surface, TEX.format("halo"), [0.02, 0.03, 0.035, HALO_ALPHA * a], at, size * HALO_SCALE)
        self.icon(surface, icon_path(icon), color, at, size, angle)
        self.label(surface, text, color, at, size)

    def marker(self, surface, m):
        W, H = surface.size
        at = (m["at"][0] * W, m["at"][1] * H)
        size = m.get("size", 24)
        color = list(m.get("color", [0.3, 0.62, 1, 1]))
        state = m.get("state", "live")
        text = m.get("text", "")
        if "ordered_to" in m:
            to = (m["ordered_to"][0] * W, m["ordered_to"][1] * H)
            gold = [1, 0.82, 0.3, 0.9]
            self.line(surface, at, to, gold)
            self.icon(surface, TEX.format("ring"), gold, to, 22)
        if m.get("combat") is not None:
            p = float(m["combat"])
            ring = size * (1.6 + 0.5 * p)
            col = [1, 0.32, 0.24, 0.9 - 0.5 * p] if state != "enemy" else [1, 0.55, 0.2, 0.85 - 0.5 * p]
            self.icon(surface, TEX.format("ring_soft"), col, at, ring)
        if state == "mine":
            self.icon(surface, TEX.format("ring_thin"), color[:3] + [0.7], at, size * 1.45)
        if state == "vehicle_mine":
            self.icon(surface, TEX.format("ring_thin"), color[:3] + [0.85], at, 34)
        if m.get("disabled"):
            self.icon(surface, TEX.format("ring_dash"), [1, 0.6, 0.25, 0.95], at, 30)
        if state == "sector":
            # HPC_fnc_mapWorldDraw: owner ring, active zone and pulse, commander choice ring
            if m.get("active"):
                self.zone(surface, at, m.get("zone_px", 70), [1, 0.45, 0.25, 1])
                p = float(m.get("pulse", 0.5))
                self.icon(surface, TEX.format("ring_soft"), [1, 0.5, 0.25, 0.9 - 0.5 * p], at, size * (1.7 + 0.5 * p))
            if m.get("choice"):
                col = [0.4, 0.9, 0.45, 1] if m.get("my_vote") else [1, 0.82, 0.3, 0.95]
                self.icon(surface, TEX.format("ring_dash"), col, at, size * 1.9, 15)
            self.icon(surface, TEX.format("ring_thin"), color[:3] + [0.75], at, size * 1.45)
            self.mark(surface, m["icon"], color, at, size, text)
            if m.get("hover"):
                self.icon(surface, TEX.format("brackets"), [1, 1, 1, 0.9], at, 48)
            return
        if state == "player":
            self.mark(surface, m["icon"], color, at, size, text, m.get("dir", 0))
            return
        if state == "alert":
            self.icon(surface, TEX.format("ring_soft"), [1, 0.3, 0.2, 0.7], at, 50)
            self.mark(surface, "\\A3\\ui_f\\data\\map\\markers\\military\\warning_CA.paa", [1, 0.35, 0.25, 1], at, 24, text)
            return
        if state == "select":
            self.icon(surface, TEX.format("brackets"), [0.46, 0.8, 0.72, 0.9], at, 40)
            self.mark(surface, TEX.format("ring"), [0.46, 0.8, 0.72, 1], at, 18, text)
            return
        if m.get("zone_px"):
            self.zone(surface, at, m["zone_px"], color)
        if state == "ghost":
            a = m.get("alpha", 0.8)
            color = list(GHOST) + [a]
            self.icon(surface, TEX.format("ring_dash"), color, at, size * 1.7, m.get("angle", 20))
            self.mark(surface, m["icon"], color, at, size, text or "?")
        elif state == "dead":
            a = m.get("alpha", 0.85)
            self.mark(surface, m["icon"], list(DEAD) + [a], at, size, text)
            self.icon(surface, TEX.format("cross"), [0.86, 0.88, 0.89, a], at, size * 1.15)
        else:
            self.mark(surface, m["icon"], color, at, size, text)
        if m.get("hover"):
            self.icon(surface, TEX.format("brackets"), [1, 1, 1, 0.9], at, 44)
        if m.get("selected"):
            self.icon(surface, TEX.format("ring"), [1, 0.85, 0.3, 0.8], at, 46)

    def zone(self, surface, at, r, color):
        """drawEllipse: 13% fill and a 75% outline."""
        layer = Image.new("RGBA", surface.size, (0, 0, 0, 0))
        c = R.to_rgba(color[:3] + [0.13])
        o = R.to_rgba(color[:3] + [0.75])
        r = r * self.k
        ImageDraw.Draw(layer).ellipse([at[0] - r, at[1] - r, at[0] + r, at[1] + r], fill=c, outline=o, width=max(1, int(self.k)))
        surface.alpha_composite(layer)

    def line(self, surface, a, b, color):
        layer = Image.new("RGBA", surface.size, (0, 0, 0, 0))
        ImageDraw.Draw(layer).line([a, b], fill=R.to_rgba(color), width=max(1, int(1.2 * self.k)))
        surface.alpha_composite(layer)


def terrain(W, H, seed=7):
    """A stand-in for the Arma map: sea, an island with contours, grid, roads."""
    rnd = random.Random(seed)
    sea = Image.new("RGBA", (W, H), (126, 160, 190, 255))
    mask = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(mask)
    cx, cy = W * 0.42, H * 0.52
    pts = []
    for i in range(64):
        a = i / 64 * 2 * math.pi
        r = (0.30 + 0.08 * math.sin(3 * a) + 0.05 * math.sin(7 * a + 1) + rnd.uniform(-0.015, 0.015)) * H
        pts.append((cx + 1.55 * r * math.cos(a), cy + r * math.sin(a)))
    d.polygon(pts, fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(3))
    land = Image.new("RGBA", (W, H), (214, 207, 184, 255))
    # forest patches
    fd = ImageDraw.Draw(land)
    for _ in range(140):
        x, y = rnd.uniform(0.15, 0.75) * W, rnd.uniform(0.25, 0.8) * H
        r = rnd.uniform(6, 26) * W / 1920
        fd.ellipse([x - r, y - r * 0.7, x + r, y + r * 0.7], fill=(171, 196, 141, 255))
    land = land.filter(ImageFilter.GaussianBlur(1.2))
    sea.paste(land, (0, 0), mask)
    g = ImageDraw.Draw(sea)
    # contour lines
    for k in range(1, 6):
        s = 1 - k * 0.14
        ring = [(cx + (x - cx) * s, cy + (y - cy) * s) for x, y in pts]
        g.line(ring + [ring[0]], fill=(176, 150, 112, 110), width=1)
    # roads and towns
    for _ in range(9):
        x0, y0 = rnd.uniform(0.2, 0.7) * W, rnd.uniform(0.3, 0.75) * H
        g.line([(x0, y0), (x0 + rnd.uniform(-260, 260), y0 + rnd.uniform(-160, 160))], fill=(232, 168, 92, 255), width=3)
    for _ in range(10):
        x, y = rnd.uniform(0.2, 0.7) * W, rnd.uniform(0.3, 0.75) * H
        for _ in range(14):
            bx, by = x + rnd.uniform(-30, 30), y + rnd.uniform(-20, 20)
            g.rectangle([bx, by, bx + 5, by + 4], fill=(90, 90, 90, 255))
    # grid
    step = W / 8
    for i in range(1, 8):
        g.line([(i * step, 0), (i * step, H)], fill=(40, 40, 40, 70), width=1)
    for i in range(1, 6):
        g.line([(0, i * H / 5.5), (W, i * H / 5.5)], fill=(40, 40, 40, 70), width=1)
    # the map's top bar
    g.rectangle([0, 0, W, int(0.058 * H)], fill=(18, 20, 21, 235))
    return sea


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--markers", required=True)
    ap.add_argument("--data", help="control data for HPC_MapOverlayPreview (see render.py)")
    ap.add_argument("--background", help="a map screenshot instead of the generated terrain")
    ap.add_argument("--dialog", default="HPC_MapOverlayPreview")
    ap.add_argument("--size", default="1920x1080")
    ap.add_argument("--uisize", default="verylarge")
    ap.add_argument("-o", "--output", default="map_overlay.png")
    args = ap.parse_args(argv)

    warnings = []
    W, H = (int(v) for v in args.size.lower().split("x"))
    env = Env(W, H, args.uisize)
    assets = A.Assets(warn=warnings.append)
    spec = json.load(open(args.markers, encoding="utf-8"))
    if args.background:
        surface = Image.open(args.background).convert("RGBA").resize((W, H), Image.LANCZOS)
    else:
        surface = terrain(W, H)
    painter = MapPainter(env, assets, warnings.append)
    for ln in spec.get("lines", []):
        painter.line(surface, (ln["from"][0] * W, ln["from"][1] * H), (ln["to"][0] * W, ln["to"][1] * H), ln["color"])
    for m in spec.get("markers", []):
        painter.marker(surface, m)

    mission = R.Mission(os.path.join(A.MISSION, "description.ext"), warnings.append)
    dialog = mission.find(args.dialog)
    if dialog is None:
        print(f"class {args.dialog} not found", file=sys.stderr)
        return 2
    data = json.load(open(args.data, encoding="utf-8")) if args.data else {}
    tmp = os.path.join(tempfile.gettempdir(), "hpc_map_bg.png")
    surface.save(tmp)
    r = R.Renderer(mission, env, assets, data, False, warnings.append)
    img = r.render(dialog, tmp, "off")
    img.convert("RGB").save(args.output)
    print("wrote", args.output)
    for w in warnings[:25]:
        print("  " + w, file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
