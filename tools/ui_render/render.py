#!/usr/bin/env python3
"""Offline renderer for Arma 3 mission UI dialogs (description.ext + includes).

    python tools/ui_render/render.py liberation_deploy -o out.png
    python tools/ui_render/render.py --list
    python tools/ui_render/render.py --all -o outdir
See README.md.
"""
import argparse
import json
import os
import re
import sys

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import assets as A  # noqa: E402
import config as C  # noqa: E402
import preproc as P  # noqa: E402
from expr import Env, try_eval  # noqa: E402

# ---------------------------------------------------------------- constants
CT = dict(STATIC=0, BUTTON=1, EDIT=2, SLIDER=3, COMBO=4, LISTBOX=5, TOOLBOX=6, CHECKBOXES=7,
          PROGRESS=8, HTML=9, STATIC_SKEW=10, ACTIVETEXT=11, TREE=12, STRUCTURED_TEXT=13,
          CONTEXT_MENU=14, CONTROLS_GROUP=15, SHORTCUTBUTTON=16, XKEYDESC=40, XBUTTON=41,
          XLISTBOX=42, XSLIDER=43, XCOMBO=44, ANIMATED_TEXTURE=45, CHECKBOX=77, OBJECT=80,
          OBJECT_ZOOM=81, OBJECT_CONTAINER=82, OBJECT_CONT_ANIM=83, USER=99, MAP=100,
          MAP_MAIN=101, LISTNBOX=102, ITEMSLOT=103, LISTNBOX_CHECKABLE=104, CONTROLS_TABLE=19)
ST_POS, ST_LEFT, ST_RIGHT, ST_CENTER = 0x0F, 0, 1, 2
ST_TYPE = 0xF0
ST_MULTI, ST_TITLE_BAR, ST_PICTURE, ST_FRAME, ST_BACKGROUND = 16, 32, 48, 64, 80
ST_GROUP_BOX, ST_GROUP_BOX2, ST_HUD_BACKGROUND, ST_TILE_PICTURE = 96, 112, 128, 144
ST_WITH_RECT, ST_LINE, ST_UPPERCASE, ST_LOWERCASE = 160, 176, 0xC0, 0xD0
ST_KEEP_ASPECT_RATIO = 0x800

FONT_DIR = r"C:\Windows\Fonts"
BAHN = os.path.join(FONT_DIR, "bahnschrift.ttf")
# Arma font -> (file, Bahnschrift (weight, width) axes, cap-height as fraction of sizeEx)
# cap fractions calibrated against 1920x1080 captures (see README).
FONTS = {
    "puristamedium": (BAHN, (400, 100), 0.53),
    "puristasemibold": (BAHN, (600, 100), 0.53),
    "puristabold": (BAHN, (700, 100), 0.53),
    "puristalight": (BAHN, (300, 100), 0.53),
    "robotocondensed": (BAHN, (400, 85), 0.57),
    "robotocondensedlight": (BAHN, (300, 85), 0.57),
    "robotocondensedbold": (BAHN, (650, 85), 0.57),
    "etelkanarrowmediumpro": (BAHN, (400, 90), 0.55),
    "etelkamonospacepro": (os.path.join(FONT_DIR, "consola.ttf"), None, 0.50),
    "etelkamonospaceprobold": (os.path.join(FONT_DIR, "consolab.ttf"), None, 0.50),
    "lucidaconsoleb": (os.path.join(FONT_DIR, "consolab.ttf"), None, 0.50),
    "tahomab": (os.path.join(FONT_DIR, "tahomabd.ttf"), None, 0.55),
}
_font_cache = {}
# Structured text glyphs render ~0.89x the size of CT_STATIC text with the same
# size value (measured on the redeploy info box, 1920x1080).
ST_TEXT_SCALE = 0.89


def get_font(name, px):
    """Return (font, cap_px) for an Arma font name and a sizeEx in pixels."""
    key = (str(name).lower(), round(px, 1))
    if key in _font_cache:
        return _font_cache[key]
    path, var, cap = FONTS.get(str(name).lower(), FONTS["puristamedium"])
    if not os.path.exists(path):
        path, var = BAHN, (400, 100)
    # find em size so the cap height equals cap * px
    probe = ImageFont.truetype(path, 100)
    if var:
        try:
            probe.set_variation_by_axes(list(var))
        except (OSError, ValueError):
            pass
    bb = probe.getbbox("H", anchor="ls")
    cap100 = max(1, -bb[1])
    em = max(4, int(round(100 * cap * px / cap100)))
    f = ImageFont.truetype(path, em)
    if var:
        try:
            f.set_variation_by_axes(list(var))
        except (OSError, ValueError):
            pass
    res = (f, cap * px)
    _font_cache[key] = res
    return res


def to_rgba(c, alpha_mul=1.0):
    r, g, b, a = (list(c) + [1, 1, 1, 1])[:4]
    cl = lambda v: max(0, min(255, int(round(v * 255))))  # noqa: E731
    return (cl(r), cl(g), cl(b), cl(a * alpha_mul))


def hex_color(s):
    s = s.strip().lstrip("#")
    try:
        if len(s) == 6:
            return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), 255)
        if len(s) == 8:  # Arma #AARRGGBB
            return (int(s[2:4], 16), int(s[4:6], 16), int(s[6:8], 16), int(s[0:2], 16))
    except ValueError:
        pass
    return (255, 255, 255, 255)


def fill(surface, box, color):
    x0, y0, x1, y1 = [int(round(v)) for v in box]
    if x1 <= x0 or y1 <= y0 or color[3] == 0:
        return
    layer = Image.new("RGBA", (x1 - x0, y1 - y0), color)
    paste(surface, layer, x0, y0)


def paste(surface, layer, x, y):
    """alpha_composite with clipping (handles negative offsets)."""
    x, y = int(round(x)), int(round(y))
    W, H = surface.size
    w, h = layer.size
    sx0, sy0 = max(0, -x), max(0, -y)
    sx1, sy1 = min(w, W - x), min(h, H - y)
    if sx1 <= sx0 or sy1 <= sy0:
        return
    if (sx0, sy0, sx1, sy1) != (0, 0, w, h):
        layer = layer.crop((sx0, sy0, sx1, sy1))
    surface.alpha_composite(layer, (x + sx0, y + sy0))


def outline(surface, box, color, width=1):
    x0, y0, x1, y1 = box
    fill(surface, (x0, y0, x1, y0 + width), color)
    fill(surface, (x0, y1 - width, x1, y1), color)
    fill(surface, (x0, y0, x0 + width, y1), color)
    fill(surface, (x1 - width, y0, x1, y1), color)


def tint(img, color):
    if color[:4] == (255, 255, 255, 255):
        return img
    r, g, b, a = img.split()
    f = [c / 255 for c in color]
    r = r.point(lambda v: int(v * f[0])); g = g.point(lambda v: int(v * f[1]))
    b = b.point(lambda v: int(v * f[2])); a = a.point(lambda v: int(v * f[3]))
    return Image.merge("RGBA", (r, g, b, a))


def draw_text_line(surface, box, text, font, cap, color, align="left", valign="center", pad=0, clip=True):
    """Draw one line; caps are vertically centred in the box (Arma behaviour)."""
    if not text or color[3] == 0:
        return
    x0, y0, x1, y1 = box
    w = max(1, int(round(x1 - x0))); h = max(1, int(round(y1 - y0)))
    tw = font.getlength(text)
    if align == "center":
        tx = (w - tw) / 2
    elif align == "right":
        tx = w - tw - pad
    else:
        tx = pad
    if valign == "top":
        base = cap / 0.56 * 0.78
    else:
        base = h / 2 + cap / 2
    if clip:
        layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        ImageDraw.Draw(layer).text((tx, base), text, font=font, fill=color, anchor="ls")
        paste(surface, layer, x0, y0)
    else:
        extra = int(cap * 2)
        layer = Image.new("RGBA", (int(tw + 2 * extra + w), h + 2 * extra), (0, 0, 0, 0))
        ImageDraw.Draw(layer).text((tx + extra, base + extra), text, font=font, fill=color, anchor="ls")
        paste(surface, layer, x0 - extra, y0 - extra)


def wrap(text, font, width):
    lines = []
    for para in text.split("\n"):
        cur = ""
        for word in para.split(" "):
            t = (cur + " " + word) if cur else word
            if font.getlength(t) <= width or not cur:
                cur = t
            else:
                lines.append(cur); cur = word
        lines.append(cur)
    return lines


# ---------------------------------------------------------------- mission
class Mission:
    def __init__(self, description, warn):
        self.warn = warn
        pp = P.Preprocessor()
        text = pp.process_file(description)
        for w in pp.warnings:
            warn("preprocessor: " + w)
        self.root, pw = C.parse(text)
        for w in pw:
            warn("parser: " + w)
        self.strings = A.load_stringtable(os.path.join(os.path.dirname(description), "stringtable.xml"))

    def dialogs(self):
        out = []
        for c in self.root.classes():
            if c.has("idd") and (c.has("controls") or c.has("controlsBackground") or c.has("objects")):
                out.append(("dialog", c))
        rt = self.root.get("RscTitles")
        if isinstance(rt, C.ConfigClass):
            for c in rt.classes():
                if c.has("controls") or c.has("controlsBackground"):
                    out.append(("title", c))
        return out

    def find(self, name):
        for kind, c in self.dialogs():
            if c.name.lower() == name.lower():
                return c
        c = self.root.get(name)
        return c if isinstance(c, C.ConfigClass) else None

    def localize(self, s):
        if isinstance(s, str) and s.startswith("$STR"):
            return self.strings.get(s[1:].lower(), s)
        return s


# ---------------------------------------------------------------- renderer
class Renderer:
    def __init__(self, mission, env, assets, data=None, debug=False, warn=print):
        self.m, self.env, self.assets = mission, env, assets
        self.data = data or {}
        self.hide = {int(x) for x in self.data.get("hide", [])}
        self.show = {int(x) for x in self.data.get("show", [])}
        self.debug = debug
        self.warn = warn
        self.debug_boxes = []
        self.xform = None
        self.font_scale = 1.0

    def fpx(self, size, ctype=0):
        """Font size (config units) -> pixels, incl. HPC_fnc_scaleDialog font scaling."""
        if self.xform:
            size = max(size * self.font_scale, 0.022 * self.env.szH)
            if ctype == 102:
                size = min(size, 0.022 * self.env.szH)
        return self.env.sy(size)

    def setup_scale_dialog(self, dialog, mode):
        onload = str(dialog.get("onLoad") or "")
        if mode == "off" or (mode == "auto" and "hpc_fnc_scaledialog" not in onload.lower()):
            return
        e = self.env
        boxes = []
        for key in ("controlsBackground", "controls"):
            for c in self.control_list(dialog, key):
                x, y, w, h = (self.num(c, k) for k in "xywh")
                if not (w >= 0.95 * e.szW and h >= 0.95 * e.szH):
                    boxes.append((x, y, x + w, y + h))
        if not boxes:
            return
        l = min(b[0] for b in boxes); t = min(b[1] for b in boxes)
        r = max(b[2] for b in boxes); bt = max(b[3] for b in boxes)
        k = min(1.45, 0.92 * e.szW / max(r - l, 0.01), 0.9 * e.szH / max(bt - t, 0.01))
        self.xform = (k, (l + r) / 2, (t + bt) / 2)
        self.font_scale = k

    # -- value helpers
    def num(self, cls, name, default=0.0):
        v = cls.get(name)
        if v is None:
            return default
        if isinstance(v, list):
            v = v[0] if v else default
        return try_eval(v, self.env, default, lambda m: self.warn(f"{cls.path()}.{name}: {m}"))

    def color(self, cls, name, default=(0, 0, 0, 0)):
        v = cls.get(name)
        if isinstance(v, str) and v.strip().startswith("#"):
            return hex_color(v)
        if not isinstance(v, list) or len(v) < 3:
            return default
        vals = []
        for e in v[:4]:
            if isinstance(e, list):
                return default
            vals.append(try_eval(e, self.env, 1.0, lambda m: self.warn(f"{cls.path()}.{name}: {m}")))
        return to_rgba(vals)

    def text(self, cls, name="text"):
        v = cls.get(name)
        if v is None or isinstance(v, (list, C.ConfigClass)):
            return ""
        return self.m.localize(str(v))

    def ctrl_data(self, cls):
        idc = int(self.num(cls, "idc", -1))
        return idc, self.data.get(str(idc), {}) if idc >= 0 else {}

    # -- dialog
    def control_list(self, dialog, key):
        v = dialog.get(key)
        out = []
        if isinstance(v, C.ConfigClass):
            return v.classes()
        if isinstance(v, list):
            for name in v:
                if isinstance(name, list):
                    continue
                c = dialog.get(str(name))
                if not isinstance(c, C.ConfigClass):
                    c = self.m.root.get(str(name))
                if isinstance(c, C.ConfigClass):
                    out.append(c)
                else:
                    self.warn(f"{dialog.name}: control {name} not found")
        return out

    def render(self, dialog, background=None, scale_dialog="auto"):
        self.setup_scale_dialog(dialog, scale_dialog)
        W, H = self.env.width, self.env.height
        if background:
            bg = Image.open(background).convert("RGBA")
            if bg.size != (W, H):
                bg = bg.resize((W, H), Image.LANCZOS)
            surface = bg
        else:
            surface = Image.new("RGBA", (W, H), (58, 66, 60, 255))
            # subtle checker so transparent panels are visible
            d = ImageDraw.Draw(surface)
            step = 60
            for yy in range(0, H, step):
                for xx in range(0, W, step):
                    if (xx // step + yy // step) % 2:
                        d.rectangle((xx, yy, xx + step - 1, yy + step - 1), fill=(66, 74, 68, 255))
        for key in ("controlsBackground", "controls"):
            for c in self.control_list(dialog, key):
                self.draw_control(surface, c, None)
        if self.debug:
            f, cap = get_font("etelkamonospacepro", 14)
            for box, label in self.debug_boxes:
                outline(surface, box, (255, 0, 255, 220))
                fill(surface, (box[0], box[1], box[0] + f.getlength(label) + 4, box[1] + 14), (0, 0, 0, 170))
                draw_text_line(surface, (box[0] + 2, box[1], box[0] + 600, box[1] + 14), label, f, cap,
                               (255, 255, 0, 255), clip=False)
        return surface

    def rect(self, cls, origin):
        x, y = self.num(cls, "x"), self.num(cls, "y")
        w, h = self.num(cls, "w"), self.num(cls, "h")
        _, d = self.ctrl_data(cls)
        if "pos" in d:  # like ctrlSetPosition; numbers or config expressions
            x, y, w, h = [try_eval(v, self.env, 0, self.warn) for v in d["pos"]]
        if "offset" in d:  # [dx, dy, dw, dh] added to the config position
            dx, dy, dw, dh = ([try_eval(v, self.env, 0, self.warn) for v in d["offset"]] + [0, 0, 0, 0])[:4]
            x, y, w, h = x + dx, y + dy, w + dw, h + dh
        if origin is None:
            if self.xform:  # emulate HPC_fnc_scaleDialog (ctrlSetPosition of top-level controls)
                k, cx, cy = self.xform
                e = self.env
                if not (w >= 0.95 * e.szW and h >= 0.95 * e.szH):
                    x, y = e.szX + e.szW / 2 + (x - cx) * k, e.szY + e.szH / 2 + (y - cy) * k
                    w, h = w * k, h * k
            px, py = self.env.px(x, y)
        else:
            px, py = origin[0] + self.env.sx(x), origin[1] + self.env.sy(y)
        return (px, py, px + self.env.sx(w), py + self.env.sy(h))

    def visible(self, cls):
        idc, _ = self.ctrl_data(cls)
        if idc in self.show:
            return True
        if idc in self.hide:
            return False
        if self.num(cls, "show", 1) == 0:
            return False
        if self.num(cls, "fade", 0) >= 1:
            return False
        return True

    def draw_control(self, surface, cls, origin):
        if not self.visible(cls):
            return
        box = self.rect(cls, origin)
        t = int(self.num(cls, "type", 0))
        idc, d = self.ctrl_data(cls)
        if self.debug:
            self.debug_boxes.append((tuple(int(v) for v in box), f"{idc} {cls.name}"))
        try:
            if t in (CT["CONTROLS_GROUP"], 98) or (cls.has("controls") and isinstance(cls.get("controls"), C.ConfigClass) and t not in (CT["MAP"], CT["MAP_MAIN"])):
                self.draw_group(surface, cls, box)
            elif t in (CT["STATIC"], CT["STATIC_SKEW"], CT["HTML"]):
                self.draw_static(surface, cls, box, d)
            elif t in (CT["BUTTON"], CT["XBUTTON"]):
                self.draw_button(surface, cls, box, d)
            elif t == CT["SHORTCUTBUTTON"]:
                self.draw_shortcut(surface, cls, box, d)
            elif t == CT["ACTIVETEXT"]:
                self.draw_activetext(surface, cls, box, d)
            elif t == CT["STRUCTURED_TEXT"]:
                self.draw_structured(surface, cls, box, d)
            elif t in (CT["LISTBOX"], CT["XLISTBOX"], CT["LISTNBOX"], CT["LISTNBOX_CHECKABLE"]):
                self.draw_list(surface, cls, box, d, nbox=t in (CT["LISTNBOX"], CT["LISTNBOX_CHECKABLE"]))
            elif t in (CT["COMBO"], CT["XCOMBO"]):
                self.draw_combo(surface, cls, box, d)
            elif t == CT["EDIT"]:
                self.draw_edit(surface, cls, box, d)
            elif t == CT["PROGRESS"]:
                self.draw_progress(surface, cls, box, d)
            elif t in (CT["MAP"], CT["MAP_MAIN"]):
                self.draw_map(surface, cls, box)
            elif t in (CT["SLIDER"], CT["XSLIDER"]):
                self.draw_slider(surface, cls, box, d)
            elif t in (CT["CHECKBOX"], CT["CHECKBOXES"], CT["TOOLBOX"]):
                self.draw_toolbox(surface, cls, box, d, t)
            elif t == CT["TREE"]:
                self.draw_placeholder(surface, cls, box, "TREE")
            elif t in (CT["OBJECT"], CT["OBJECT_ZOOM"], CT["OBJECT_CONTAINER"], CT["OBJECT_CONT_ANIM"]):
                pass
            else:
                self.draw_placeholder(surface, cls, box, f"type {t}")
        except Exception as e:  # noqa: BLE001 - keep rendering the rest
            self.warn(f"{cls.path()}: draw failed: {e!r}")

    # -- primitives
    def picture(self, surface, box, path, color, keep_aspect):
        path = path.strip()
        x0, y0, x1, y1 = box
        w, h = int(round(x1 - x0)), int(round(y1 - y0))
        if w <= 0 or h <= 0 or not path:
            return
        m = re.match(r"#\(\w+,\d+,\d+,\d+\)color\(([^)]*)\)", path, re.I)
        if m:
            vals = [try_eval(v, self.env, 1) for v in m.group(1).split(",")[:4]]
            c = to_rgba(vals)
            c = tuple(int(a * b / 255) for a, b in zip(c, color))
            fill(surface, box, c)
            return
        if path.startswith("#"):
            return
        img = self.assets.image(path)
        if img is None:
            fill(surface, box, (110, 110, 110, 160))
            outline(surface, box, (200, 200, 200, 200))
            f, cap = get_font("robotocondensed", max(8, min(14, h * 0.5)))
            draw_text_line(surface, box, os.path.basename(path.replace("\\", "/")), f, cap, (240, 240, 240, 255), "center")
            return
        if keep_aspect:
            s = min(w / img.width, h / img.height)
            nw, nh = max(1, int(img.width * s)), max(1, int(img.height * s))
            im = img.resize((nw, nh), Image.LANCZOS)
            paste(surface, tint(im, color), x0 + (w - nw) / 2, y0 + (h - nh) / 2)
        else:
            paste(surface, tint(img.resize((w, h), Image.LANCZOS), color), x0, y0)

    def font_for(self, cls, size_key="sizeEx"):
        size = self.num(cls, size_key, 0) or self.num(cls, "size", 0.03) or 0.03
        return get_font(self.text(cls, "font") or "PuristaMedium", self.fpx(size))

    @staticmethod
    def align_of(style):
        p = style & 0x03
        return {ST_RIGHT: "right", ST_CENTER: "center"}.get(p, "left")

    def apply_case(self, s, style):
        if style & 0xF0 == ST_UPPERCASE:
            return s.upper()
        return s

    # -- control types
    def draw_static(self, surface, cls, box, d):
        style = int(self.num(cls, "style", 0))
        st = style & ST_TYPE
        fill(surface, box, self.color(cls, "colorBackground"))
        text = d.get("text", self.text(cls))
        col = self.color(cls, "colorText", (255, 255, 255, 255))
        if "color" in d:
            col = to_rgba(d["color"])
        if st in (ST_PICTURE, ST_TILE_PICTURE) or "image" in d:
            self.picture(surface, box, d.get("image", text), col, bool(style & ST_KEEP_ASPECT_RATIO))
            return
        if st == ST_LINE:
            dr = ImageDraw.Draw(surface)
            dr.line([box[0], box[1], box[2], box[3]], fill=col, width=1)
            return
        font, cap = self.font_for(cls)
        if st in (ST_FRAME, ST_GROUP_BOX, ST_GROUP_BOX2, ST_WITH_RECT):
            outline(surface, box, col)
            if text:
                draw_text_line(surface, (box[0] + 4, box[1] - cap, box[2], box[1] + cap), text, font, cap, col)
            return
        if st in (ST_BACKGROUND, ST_HUD_BACKGROUND):
            return
        text = self.apply_case(text, style)
        pad = self.env.sx(0.004)
        if st == ST_MULTI or "\n" in text:
            self.draw_multiline(surface, cls, box, text, font, cap, col, self.align_of(style), pad)
        else:
            draw_text_line(surface, box, text, font, cap, col, self.align_of(style), pad=pad)

    def draw_multiline(self, surface, cls, box, text, font, cap, col, align, pad):
        size_px = self.fpx(self.num(cls, "sizeEx", 0.03))
        ls = self.num(cls, "lineSpacing", 1) or 1
        lines = wrap(text.replace("\\n", "\n"), font, box[2] - box[0] - 2 * pad)
        y = box[1]
        for ln in lines:
            draw_text_line(surface, (box[0], y, box[2], y + size_px), ln, font, cap, col, align, pad=pad)
            y += size_px * ls
            if y > box[3]:
                break

    def draw_button(self, surface, cls, box, d):
        style = int(self.num(cls, "style", 2))
        fill(surface, box, self.color(cls, "colorBackground"))
        bs = self.color(cls, "colorBorder")
        if self.num(cls, "borderSize", 0) > 0:
            fill(surface, (box[0] - self.env.sx(self.num(cls, "borderSize")), box[1], box[0], box[3]), bs)
        text = d.get("text", self.text(cls))
        col = self.color(cls, "colorText", (255, 255, 255, 255))
        if style & ST_TYPE == ST_PICTURE:
            self.picture(surface, box, text, col, bool(style & ST_KEEP_ASPECT_RATIO))
            return
        font, cap = self.font_for(cls)
        draw_text_line(surface, box, self.apply_case(text, style), font, cap, col, self.align_of(style), pad=self.env.sx(0.004))

    def draw_activetext(self, surface, cls, box, d):
        style = int(self.num(cls, "style", 2))
        col = self.color(cls, "color", None) or self.color(cls, "colorText", (255, 255, 255, 255))
        text = d.get("text", self.text(cls))
        if style & ST_TYPE == ST_PICTURE or (style & 0xF0) == 0x30:
            self.picture(surface, box, text, col, bool(style & ST_KEEP_ASPECT_RATIO))
            return
        font, cap = self.font_for(cls)
        draw_text_line(surface, box, text, font, cap, col, self.align_of(style))

    def draw_shortcut(self, surface, cls, box, d):
        bgc = self.color(cls, "colorBackground", (0, 0, 0, 0))
        tex = self.text(cls, "animTextureNormal")
        if tex and not tex.startswith("#"):
            self.picture(surface, box, tex, bgc, False)
        else:
            fill(surface, box, bgc)
        text = d.get("text", self.text(cls))
        col = self.color(cls, "color", (255, 255, 255, 255))
        size = self.num(cls, "size", 0) or self.num(cls, "sizeEx", 0.03)
        attrs = cls.get("Attributes")
        fname = self.text(cls, "font") or "PuristaMedium"
        align = "left"
        if isinstance(attrs, C.ConfigClass):
            fname = self.text(attrs, "font") or fname
            align = self.text(attrs, "align") or "left"
        font, cap = get_font(fname, self.fpx(size))
        tp = cls.get("TextPos")
        left = top = 0
        if isinstance(tp, C.ConfigClass):
            left, top = self.env.sx(self.num(tp, "left")), self.env.sy(self.num(tp, "top"))
        icon = self.text(cls, "textureNoShortcut")
        if icon and not icon.startswith("#"):
            pass
        h = self.fpx(size)
        draw_text_line(surface, (box[0] + left, box[1] + top, box[2] - left, box[1] + top + h),
                       self.apply_case(text, 0), font, cap, col, align)

    def draw_edit(self, surface, cls, box, d):
        fill(surface, box, self.color(cls, "colorBackground"))
        col = self.color(cls, "colorText", (255, 255, 255, 255))
        bc = self.color(cls, "colorBorder", None) or (col[0], col[1], col[2], col[3] // 2)
        outline(surface, box, bc)
        font, cap = self.font_for(cls)
        style = int(self.num(cls, "style", 0))
        text = d.get("text", self.text(cls))
        pad = self.env.sx(0.006)
        if style & ST_MULTI:
            self.draw_multiline(surface, cls, box, text, font, cap, col, "left", pad)
        else:
            draw_text_line(surface, box, text, font, cap, col, self.align_of(style), pad=pad)

    def draw_progress(self, surface, cls, box, d):
        bar = self.color(cls, "colorBar", (255, 255, 255, 255))
        frame = self.color(cls, "colorFrame", (0, 0, 0, 0))
        v = float(d.get("value", 0.6))
        style = int(self.num(cls, "style", 0))
        if style & 1:  # ST_VERTICAL
            fill(surface, (box[0], box[3] - (box[3] - box[1]) * v, box[2], box[3]), bar)
        else:
            fill(surface, (box[0], box[1], box[0] + (box[2] - box[0]) * v, box[3]), bar)
        outline(surface, box, frame)

    def draw_map(self, surface, cls, box):
        bg = self.color(cls, "colorBackground", (220, 220, 210, 255))
        if bg[3] == 0:
            bg = (220, 220, 210, 255)
        fill(surface, box, (bg[0], bg[1], bg[2], 255))
        x0, y0, x1, y1 = [int(v) for v in box]
        layer = Image.new("RGBA", (max(1, x1 - x0), max(1, y1 - y0)), (0, 0, 0, 0))
        dr = ImageDraw.Draw(layer)
        step = 40
        for gx in range(0, x1 - x0, step):
            dr.line([gx, 0, gx, y1 - y0], fill=(120, 120, 110, 90))
        for gy in range(0, y1 - y0, step):
            dr.line([0, gy, x1 - x0, gy], fill=(120, 120, 110, 90))
        paste(surface, layer, x0, y0)
        f, cap = get_font("puristamedium", 18)
        draw_text_line(surface, box, "MAP", f, cap, (90, 90, 80, 200), "center")

    def draw_slider(self, surface, cls, box, d):
        col = self.color(cls, "color", (255, 255, 255, 200))
        cy = (box[1] + box[3]) / 2
        fill(surface, (box[0], cy - 1, box[2], cy + 1), col)
        v = float(d.get("value", 0.5))
        tx = box[0] + (box[2] - box[0]) * v
        th = (box[3] - box[1])
        fill(surface, (tx - th * 0.25, box[1], tx + th * 0.25, box[3]), self.color(cls, "colorActive", col))

    def draw_toolbox(self, surface, cls, box, d, t):
        strings = cls.get("strings")
        if t == CT["CHECKBOX"] or not isinstance(strings, list):
            checked = bool(d.get("checked", False))
            tex = self.text(cls, "textureChecked" if checked else "textureUnchecked")
            col = self.color(cls, "color", (255, 255, 255, 255))
            if tex:
                self.picture(surface, box, tex, col, True)
            else:
                outline(surface, box, col, 2)
            return
        n = max(1, len(strings))
        rows = max(1, int(self.num(cls, "rows", 1)))
        cols = max(1, int(self.num(cls, "columns", n)))
        font, cap = self.font_for(cls)
        cw, ch = (box[2] - box[0]) / cols, (box[3] - box[1]) / rows
        sel = int(d.get("sel", 0))
        for i, s in enumerate(strings):
            r, c = divmod(i, cols)
            b = (box[0] + c * cw, box[1] + r * ch, box[0] + (c + 1) * cw, box[1] + (r + 1) * ch)
            fill(surface, b, self.color(cls, "colorSelectedBg" if i == sel else "colorBackground"))
            col = self.color(cls, "colorTextSelect" if i == sel else "colorText", (255, 255, 255, 255))
            draw_text_line(surface, b, self.m.localize(str(s)), font, cap, col, "center")

    def draw_placeholder(self, surface, cls, box, label):
        fill(surface, box, (40, 40, 40, 120))
        outline(surface, box, (160, 160, 160, 160))
        f, cap = get_font("robotocondensed", 14)
        draw_text_line(surface, box, f"{label} {cls.name}", f, cap, (220, 220, 220, 220), "center")

    def list_rows(self, cls, d, nrows):
        rows = d.get("rows")
        if rows is None:
            rows = [[f"Item {i + 1}"] for i in range(min(nrows, 4))]
        return [[r] if isinstance(r, str) else r for r in rows]  # dict rows: LISTNBOX only

    def draw_combo(self, surface, cls, box, d):
        fill(surface, box, self.color(cls, "colorBackground", (0, 0, 0, 200)))
        font, cap = self.font_for(cls)
        col = self.color(cls, "colorText", (255, 255, 255, 255))
        rows = self.list_rows(cls, d, 1)
        sel = int(d.get("sel", 0))
        txt = rows[sel][0] if rows and sel < len(rows) else ""
        pad = self.env.sx(0.006)
        h = box[3] - box[1]
        draw_text_line(surface, (box[0], box[1], box[2] - h, box[3]), txt, font, cap, col, "left", pad=pad)
        # arrow
        ax = box[2] - h / 2; ay = (box[1] + box[3]) / 2; s = h * 0.15
        ImageDraw.Draw(surface).polygon([(ax - s, ay - s / 2), (ax + s, ay - s / 2), (ax, ay + s / 2)], fill=col)

    def draw_list(self, surface, cls, box, d, nbox=False):
        fill(surface, box, self.color(cls, "colorBackground", (0, 0, 0, 0)))
        font, cap = self.font_for(cls)
        size_px = self.fpx(self.num(cls, "sizeEx", 0.03), 102 if nbox else 0)
        rh = self.env.sy(self.num(cls, "rowHeight", 0)) or size_px
        rh = max(rh, size_px)
        nrows = max(1, int((box[3] - box[1]) // max(1, rh)))
        rows = self.list_rows(cls, d, nrows)
        sel = d.get("sel", 0 if rows and "rows" not in d else None)
        col = self.color(cls, "colorText", (255, 255, 255, 255))
        colsel = self.color(cls, "colorSelect", col)
        selbg = self.color(cls, "colorSelectBackground", (255, 255, 255, 60))
        colr = self.color(cls, "colorTextRight", col)
        colrs = self.color(cls, "colorSelectRight", colr)
        pad = self.env.sx(0.006)
        columns = cls.get("columns") if nbox else None
        colpos = [try_eval(c, self.env, 0) for c in columns] if isinstance(columns, list) else None
        layer = Image.new("RGBA", (max(1, int(box[2] - box[0])), max(1, int(box[3] - box[1]))), (0, 0, 0, 0))
        w = layer.width
        y = 0.0
        for i, row in enumerate(rows):
            if y >= layer.height:
                break
            rb = (0, y, w, y + rh)
            selected = sel is not None and i == int(sel)
            if selected:
                fill(layer, rb, selbg)
            tc = colsel if selected else col
            if nbox and colpos:
                # Row: list of cells, or {"cells", "icon", "iconColor", "iconRight", "iconRightColor", "color"}
                # (lnbSetPicture on column 0, lnbSetPictureRight at the row end, lnbSetColor).
                spec = row if isinstance(row, dict) else {"cells": row}
                cells = spec.get("cells", [])
                if not selected and spec.get("color"):
                    tc = to_rgba(spec["color"])
                isz = rh * 0.86
                if spec.get("iconRight"):
                    rc = to_rgba(spec["iconRightColor"]) if spec.get("iconRightColor") else (255, 255, 255, 255)
                    self.picture(layer, (w - pad - isz, y + (rh - isz) / 2, w - pad, y + (rh + isz) / 2), spec["iconRight"], rc, True)
                for ci, cell in enumerate(cells):
                    if ci >= len(colpos):
                        break
                    cx0 = colpos[ci] * w
                    cx1 = colpos[ci + 1] * w if ci + 1 < len(colpos) else w
                    if ci == 0 and spec.get("icon"):
                        self.picture(layer, (cx0 + pad, y + (rh - isz) / 2, cx0 + pad + isz, y + (rh + isz) / 2), spec["icon"], to_rgba(spec["iconColor"]) if spec.get("iconColor") else (255, 255, 255, 255), True)
                        cx0 += isz + pad
                    draw_text_line(layer, (cx0, y, cx1, y + rh), str(cell), font, cap, tc, "left", pad=pad)
                y += rh
                continue
            text = str(row[0]) if row else ""
            icon = row[1] if len(row) > 1 and row[1] else None
            right = str(row[2]) if len(row) > 2 and row[2] is not None else ""
            tx = pad
            if icon:
                isz = rh
                pc = self.color(cls, "colorPictureSelected" if selected else "colorPicture", (255, 255, 255, 255))
                if len(row) > 3 and isinstance(row[3], list) and not selected:
                    pc = to_rgba(row[3])
                self.picture(layer, (pad, y + (rh - isz * 0.86) / 2, pad + isz, y + (rh + isz * 0.86) / 2), icon, pc, True)
                tx = pad + isz + pad
            draw_text_line(layer, (tx, y, w, y + rh), text, font, cap, tc, "left")
            if right:
                draw_text_line(layer, (0, y, w, y + rh), right, font, cap, colrs if selected else colr, "right", pad=pad * 2)
            y += rh
        paste(surface, layer, box[0], box[1])

    def draw_group(self, surface, cls, box):
        w, h = int(round(box[2] - box[0])), int(round(box[3] - box[1]))
        if w <= 0 or h <= 0:
            return
        layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        fill(layer, (0, 0, w, h), self.color(cls, "colorBackground"))
        dbg_start = len(self.debug_boxes)
        kids = cls.get("controls")
        kids = kids.classes() if isinstance(kids, C.ConfigClass) else self.control_list(cls, "controls")
        for k in kids:
            self.draw_control(layer, k, (0.0, 0.0))
        for i in range(dbg_start, len(self.debug_boxes)):
            b, lab = self.debug_boxes[i]
            self.debug_boxes[i] = ((b[0] + int(box[0]), b[1] + int(box[1]), b[2] + int(box[0]), b[3] + int(box[1])), lab)
        paste(surface, layer, box[0], box[1])

    # -- structured text
    def draw_structured(self, surface, cls, box, d):
        fill(surface, box, self.color(cls, "colorBackground"))
        text = d.get("text", self.text(cls))
        if not text:
            return
        attrs = cls.get("Attributes")
        base = {"font": "RobotoCondensed", "color": "#ffffff", "align": "left", "valign": "top", "size": 1.0}
        if isinstance(attrs, C.ConfigClass):
            for k in ("font", "color", "align", "valign"):
                v = self.text(attrs, k)
                if v:
                    base[k] = v
            if attrs.has("size"):
                base["size"] = self.num(attrs, "size", 1)
        size_px = self.fpx(self.num(cls, "size", 0) or self.num(cls, "sizeEx", 0.03))
        layout = StructuredLayout(self, size_px, box[2] - box[0])
        lines = layout.run(text, base)
        total = sum(ln["h"] for ln in lines)
        layer = Image.new("RGBA", (max(1, int(box[2] - box[0])), max(1, int(box[3] - box[1]))), (0, 0, 0, 0))
        y = 0.0
        if base["valign"] == "middle" and len(lines) == 1:
            y = (layer.height - total) / 2
        for ln in lines:
            lw = sum(it["w"] for it in ln["items"])
            x = {"center": (layer.width - lw) / 2, "right": layer.width - lw}.get(ln["align"], 0)
            for it in ln["items"]:
                ih = ln["h"]
                if it["kind"] == "text":
                    f, cap = it["font"]
                    draw_text_line(layer, (x, y + ih - it["lh"], x + it["w"] + 2, y + ih), it["text"], f, cap,
                                   it["color"], "left", clip=False)
                else:
                    self.picture(layer, (x, y + ih - it["lh"], x + it["w"], y + ih), it["image"], it["color"], True)
                x += it["w"]
            y += ln["h"]
        paste(surface, layer, box[0], box[1])


TAG = re.compile(r"<(/?)(\w+)((?:\s+\w+\s*=\s*(?:'[^']*'|\"[^\"]*\"|[^\s/>]+))*)\s*(/?)>")
ATTR = re.compile(r"(\w+)\s*=\s*(?:'([^']*)'|\"([^\"]*)\"|([^\s/>]+))")


class StructuredLayout:
    def __init__(self, r, size_px, width):
        self.r, self.size_px, self.width = r, size_px, width

    def run(self, text, base):
        stack = [dict(base)]
        lines = [{"items": [], "h": 0, "align": base["align"]}]
        x = [0.0]

        def cur():
            return lines[-1]

        def newline(st):
            if cur()["h"] == 0:
                cur()["h"] = self.size_px * float(st["size"])
            lines.append({"items": [], "h": 0, "align": st["align"]})
            x[0] = 0.0

        def add_text(s, st):
            lh = self.size_px * float(st["size"])
            font = get_font(st["font"], lh * ST_TEXT_SCALE)
            col = hex_color(st["color"]) if str(st["color"]).startswith("#") else (255, 255, 255, 255)
            parts = re.split(r"(\s+)", s)
            for p in parts:
                if not p:
                    continue
                wpx = font[0].getlength(p)
                if x[0] + wpx > self.width and x[0] > 0 and not p.isspace():
                    newline(st)
                if p.isspace() and x[0] == 0:
                    continue
                if not cur()["items"]:
                    cur()["align"] = st["align"]
                cur()["items"].append({"kind": "text", "text": p, "w": wpx, "lh": lh, "font": font, "color": col})
                cur()["h"] = max(cur()["h"], lh)
                x[0] += wpx

        pos = 0
        text = text.replace("&lt;", "\0lt").replace("&gt;", "\0gt")
        for m in TAG.finditer(text):
            seg = text[pos:m.start()]
            if seg:
                add_text(self.unescape(seg), stack[-1])
            pos = m.end()
            closing, tag, attrs, selfclose = m.group(1), m.group(2).lower(), m.group(3), m.group(4)
            a = {am.group(1).lower(): am.group(2) if am.group(2) is not None else (am.group(3) if am.group(3) is not None else am.group(4))
                 for am in ATTR.finditer(attrs or "")}
            if tag == "br":
                newline(stack[-1])
            elif tag == "img":
                st = dict(stack[-1]); st.update({k: v for k, v in a.items() if k in ("size", "color")})
                lh = self.size_px * float(st["size"])
                col = hex_color(st["color"]) if str(st["color"]).startswith("#") else (255, 255, 255, 255)
                img = a.get("image", "")
                if x[0] + lh > self.width and x[0] > 0:
                    newline(st)
                cur()["items"].append({"kind": "img", "image": img, "w": lh, "lh": lh, "color": col})
                cur()["h"] = max(cur()["h"], lh)
                x[0] += lh
            elif tag in ("t", "a"):
                if closing:
                    if len(stack) > 1:
                        stack.pop()
                else:
                    st = dict(stack[-1])
                    for k, v in a.items():
                        if k == "size":
                            try:
                                st["size"] = float(v)
                            except ValueError:
                                pass
                        elif k in ("color", "font", "align", "valign"):
                            st[k] = v
                    if "align" in a and x[0] > 0:
                        newline(st)
                    if not selfclose:
                        stack.append(st)
        if pos < len(text):
            add_text(self.unescape(text[pos:]), stack[-1])
        if cur()["h"] == 0:
            if not cur()["items"]:
                lines.pop() if len(lines) > 1 else None
        return [ln for ln in lines if ln["h"] > 0 or ln["items"]] or []

    @staticmethod
    def unescape(s):
        return s.replace("\0lt", "<").replace("\0gt", ">").replace("&amp;", "&").replace("&quot;", '"').replace("&apos;", "'")


# ---------------------------------------------------------------- CLI
def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("classname", nargs="?")
    ap.add_argument("--description", default=os.path.join(A.MISSION, "description.ext"))
    ap.add_argument("--size", default="1920x1080")
    ap.add_argument("--uisize", default="verylarge",
                    help="verysmall|small|normal|large|verylarge or a number (uiScale). Default verylarge = capture profile")
    ap.add_argument("--background")
    ap.add_argument("--data", help="JSON file (or inline JSON) filling controls by idc")
    ap.add_argument("--debug", action="store_true", help="draw control rects, idc and class names")
    ap.add_argument("--scale-dialog", choices=["auto", "on", "off"], default="auto",
                    help="emulate HPC_fnc_scaleDialog (auto: when the dialog onLoad calls it)")
    ap.add_argument("-o", "--output")
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--all", action="store_true")
    ap.add_argument("-v", "--verbose", action="store_true", help="print all warnings")
    args = ap.parse_args(argv)

    warnings = []
    warn = warnings.append
    mission = Mission(args.description, warn)
    if args.list:
        for kind, c in mission.dialogs():
            print(f"{kind:6} {c.name}")
        return 0
    W, H = (int(v) for v in args.size.lower().split("x"))
    env = Env(W, H, args.uisize)
    data = {}
    if args.data:
        data = json.loads(args.data) if args.data.strip().startswith("{") else json.load(open(args.data, encoding="utf-8"))
    assets = A.Assets(warn=warn)
    if args.all:
        out = args.output or "ui_render_out"
        os.makedirs(out, exist_ok=True)
        for kind, c in mission.dialogs():
            r = Renderer(mission, env, assets, data.get(c.name, {}), args.debug, warn)
            img = r.render(c, args.background, args.scale_dialog)
            img.convert("RGB").save(os.path.join(out, c.name + ".png"))
            print("rendered", c.name)
    else:
        if not args.classname:
            ap.error("class name required (or --list / --all)")
        c = mission.find(args.classname)
        if c is None:
            print(f"class {args.classname} not found", file=sys.stderr)
            return 2
        r = Renderer(mission, env, assets, data, args.debug, warn)
        img = r.render(c, args.background, args.scale_dialog)
        out = args.output or (c.name + ".png")
        img.convert("RGB").save(out)
        print("wrote", out)
    shown = warnings if args.verbose else warnings[:25]
    if shown:
        print(f"{len(warnings)} warning(s):", file=sys.stderr)
        for w in shown:
            print("  " + w, file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
