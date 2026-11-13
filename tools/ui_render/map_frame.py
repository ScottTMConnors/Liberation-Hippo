#!/usr/bin/env python3
"""Replay a map frame recorded in game on its clean background, to check map_render offline.

The UI-shot fixture (tools/hippo_testing/ui_shots.sqf) records, for each map shot, every
drawIcon / drawLine / drawEllipse / drawRectangle call of HPC_fnc_mapWorldDraw and
HPC_fnc_mapDraw in screen space (HPC_MAPFRAME lines in the client RPT), and takes the
same view again with the layers hidden (<shot>_clean.png). This draws the recorded frame
on the clean shot with map_render's primitives, so the result can be compared with the
real <shot>.png (pass --compare to write a side-by-side and print the mean difference).

    python tools/ui_render/map_frame.py mybuild/hippo_tests/<run> 47_map_world -o out.png --compare
"""
import argparse
import glob
import os
import re
import sys

from PIL import Image, ImageChops, ImageDraw, ImageStat

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import assets as A  # noqa: E402
import render as R  # noqa: E402

# Calibration against in-game shots (see README): drawIcon width/height are screen pixels
# at 1080p scaled with the resolution; textSize is a fraction of the screen height.
ICON_SCALE = 1.2         # drawIcon size 20 draws about 24 px at 1080p
HALO_ALPHA = 0.5         # the soft halo shows about half as strong in game
TEXT_SCALE = 0.55


def parse_sqf(s, i=0):
    """Parse one SQF value as printed by diag_log; returns (value, next index)."""
    while s[i] in " ,":
        i += 1
    c = s[i]
    if c == "[":
        out, i = [], i + 1
        while True:
            while s[i] in " ,":
                i += 1
            if s[i] == "]":
                return out, i + 1
            v, i = parse_sqf(s, i)
            out.append(v)
    if c == '"':
        j, buf = i + 1, []
        while True:
            if s[j] == '"':
                if j + 1 < len(s) and s[j + 1] == '"':
                    buf.append('"'); j += 2; continue
                return "".join(buf), j + 1
            buf.append(s[j]); j += 1
    m = re.match(r"-?[\d.]+(e[-+]?\d+)?", s[i:])
    if m:
        return float(m.group(0)), i + len(m.group(0))
    m = re.match(r"\w+", s[i:])
    word = m.group(0)
    return {"true": True, "false": False}.get(word, word), i + len(word)


def read_frame(run, shot):
    rpts = glob.glob(os.path.join(run, "client1", "*.rpt"))
    if not rpts:
        raise SystemExit("no client RPT in " + run)
    head, items = None, []
    for line in open(rpts[0], encoding="utf-8", errors="replace"):
        k = line.find('["HPC_MAPFRAME')
        if k < 0:
            continue
        v, _ = parse_sqf(line.strip(), k)
        if v[1] != shot:
            continue
        if v[0] == "HPC_MAPFRAME_BEGIN":
            head, items = v, []
        elif v[0] == "HPC_MAPFRAME" and head:
            items.append(v[2])
    if not head:
        raise SystemExit(f"no recorded frame for {shot}")
    return head, items


def fill_color(tex):
    m = re.search(r"color\(([^)]*)\)", tex or "")
    return [float(x) for x in m.group(1).split(",")] if m else None


def texture_path(tex):
    t = tex.replace("/", "\\")
    k = t.lower().find("\\res\\map\\")
    if k >= 0:
        return "res/map/" + t[k + 9:]
    return tex


def draw(run, shot, out, compare=False):
    head, items = read_frame(run, shot)
    szx, szy, szw, szh = head[2]
    res = head[3]
    W, H = int(res[0]), int(res[1])
    bg = os.path.join(run, "shots", shot + "_clean.png")
    surface = Image.open(bg).convert("RGBA").resize((W, H))
    px = lambda p: ((p[0] - szx) / szw * W, (p[1] - szy) / szh * H)
    warnings = []
    assets = A.Assets(warn=warnings.append)
    k = H / 1080.0 * ICON_SCALE
    for it in items:
        kind = it[0]
        layer = Image.new("RGBA", surface.size, (0, 0, 0, 0))
        d = ImageDraw.Draw(layer)
        if kind == "line":
            d.line([px(it[1]), px(it[2])], fill=R.to_rgba(it[3]), width=max(1, round(H / 1080)))
        elif kind == "poly":
            col = fill_color(it[2])
            if col:
                d.polygon([px(p) for p in it[1]], fill=R.to_rgba(col))
        elif kind == "ellipse":
            c = px(it[1]); r = it[2] / szw * W
            col = fill_color(it[4])
            if col:
                d.ellipse([c[0] - r, c[1] - r, c[0] + r, c[1] + r], fill=R.to_rgba(col))
            else:
                d.ellipse([c[0] - r, c[1] - r, c[0] + r, c[1] + r], outline=R.to_rgba(it[3]), width=max(1, round(H / 1080)))
        elif kind == "icon":
            at = px(it[1])
            a = it[2]
            tex, color, w_, h_, angle = a[0], a[1], a[3], a[4], a[5]
            text = a[6] if len(a) > 6 else ""
            size = a[8] if len(a) > 8 else 0.032
            font = (a[9] if len(a) > 9 else "RobotoCondensed").lower()
            if w_ >= 2 and not tex.startswith("#("):
                img = assets.image(texture_path(tex))
                if img is not None:
                    img = img.resize((max(1, round(w_ * k)), max(1, round(h_ * k))), Image.LANCZOS)
                    if "halo" in tex:
                        color = list(color[:3]) + [color[3] * HALO_ALPHA]
                    img = R.tint(img, R.to_rgba(color))
                    if angle:
                        img = img.rotate(-angle, resample=Image.BICUBIC, expand=True)
                    layer.alpha_composite(img, (int(at[0] - img.width / 2), int(at[1] - img.height / 2)))
            if text:
                f, _ = R.get_font(font, size * TEXT_SCALE * H)
                rgba = R.to_rgba(color)
                d.text((at[0] + w_ * k / 2 + 2, at[1]), text, font=f, fill=rgba, anchor="lm",
                       stroke_width=max(1, round(1.4 * H / 1080)), stroke_fill=(0, 0, 0, int(rgba[3] * 0.85)))
        surface.alpha_composite(layer)
    surface.convert("RGB").save(out)
    print(f"wrote {out} ({len(items)} primitives)")
    for w in sorted(set(warnings))[:20]:
        print("  " + w, file=sys.stderr)
    if compare:
        real = Image.open(os.path.join(run, "shots", shot + ".png")).convert("RGB").resize((W, H))
        mine = Image.open(out).convert("RGB")
        diff = ImageChops.difference(real, mine)
        print("mean abs difference per channel:", [round(x, 2) for x in ImageStat.Stat(diff).mean])
        side = Image.new("RGB", (W * 2, H))
        side.paste(real, (0, 0)); side.paste(mine, (W, 0))
        side.save(out[:-4] + "_vs_game.png")
        print("wrote", out[:-4] + "_vs_game.png", "(left: game, right: offline)")


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("run")
    ap.add_argument("shot")
    ap.add_argument("-o", "--output", default="map_frame.png")
    ap.add_argument("--compare", action="store_true")
    args = ap.parse_args(argv)
    draw(args.run, args.shot, args.output, args.compare)
    return 0


if __name__ == "__main__":
    sys.exit(main())
