"""Stringtable, PBO extraction and .paa -> PNG conversion with an on-disk cache."""
import json
import os
import re
import struct
import subprocess
import xml.etree.ElementTree as ET

from PIL import Image

REPO = os.path.normpath(os.path.join(os.path.dirname(__file__), "..", ".."))
MISSION = os.path.join(REPO, "core.liberation")
CACHE = os.path.join(REPO, "mybuild", "ui_render_cache")
# Set ARMA3_DIR / ARMA3_TOOLS_DIR for non-default Steam libraries.
_STEAM = r"C:\Program Files (x86)\Steam\steamapps\common"
GAME_DIRS = [os.environ.get("ARMA3_DIR") or os.path.join(_STEAM, "Arma 3")]
IMAGETOPAA = [os.path.join(os.environ.get("ARMA3_TOOLS_DIR") or os.path.join(_STEAM, "Arma 3 Tools"), "ImageToPAA", "ImageToPAA.exe")]


def load_stringtable(path=os.path.join(MISSION, "stringtable.xml")):
    table = {}
    try:
        root = ET.parse(path).getroot()
    except (OSError, ET.ParseError):
        return table
    for key in root.iter("Key"):
        kid = key.get("ID", "").lower()
        en = key.find("English")
        orig = key.find("Original")
        node = en if en is not None and en.text else orig
        if node is not None and node.text is not None:
            table[kid] = node.text
    return table


def read_pbo_header(path):
    """Return (properties dict, [(name, offset, size)])."""
    entries, props = [], {}
    with open(path, "rb") as f:
        data = f.read(4 * 1024 * 1024)
        pos = 0

        def cstr():
            nonlocal pos, data
            while True:
                end = data.find(b"\0", pos)
                if end >= 0:
                    break
                more = f.read(4 * 1024 * 1024)
                if not more:
                    raise ValueError("truncated pbo header")
                data += more
            s = data[pos:end].decode("latin-1"); pos = end + 1
            return s

        def need(k):
            nonlocal data
            while len(data) < pos + k:
                more = f.read(4 * 1024 * 1024)
                if not more:
                    raise ValueError("truncated")
                data += more

        first = True
        raw = []
        while True:
            name = cstr()
            need(20)
            mime, osize, _r, _t, dsize = struct.unpack_from("<5I", data, pos); pos += 20
            if first and name == "" and mime == 0x56657273:  # 'Vers'
                while True:
                    k = cstr()
                    if not k:
                        break
                    props[k.lower()] = cstr()
                first = False
                continue
            first = False
            if name == "":
                break
            raw.append((name, dsize, mime))
        off = pos
        for name, size, mime in raw:
            entries.append((name.replace("/", "\\").lower(), off, size, mime))
            off += size
    return props, entries


class Assets:
    def __init__(self, mission=MISSION, cache=CACHE, game_dirs=None, warn=print):
        self.mission = mission
        self.cache = cache
        self.warn = warn
        self.game = next((d for d in (game_dirs or GAME_DIRS) if os.path.isdir(d)), None)
        self.tool = next((t for t in IMAGETOPAA if os.path.exists(t)), None)
        self._index = None
        self._img = {}
        os.makedirs(cache, exist_ok=True)

    # ---- PBO index ------------------------------------------------------
    def index(self):
        if self._index is not None:
            return self._index
        idx_path = os.path.join(self.cache, "pbo_index.json")
        if os.path.exists(idx_path):
            with open(idx_path, encoding="utf-8") as f:
                self._index = json.load(f)
            return self._index
        idx = {}
        if self.game:
            for dirpath, _dirs, files in os.walk(self.game):
                if "addons" not in dirpath.lower():
                    continue
                for fn in files:
                    if not fn.lower().endswith(".pbo"):
                        continue
                    p = os.path.join(dirpath, fn)
                    try:
                        props, _ = read_pbo_header(p)
                    except Exception as e:  # noqa: BLE001
                        self.warn(f"pbo {p}: {e}"); continue
                    prefix = props.get("prefix", os.path.splitext(fn)[0]).strip("\\").lower()
                    idx.setdefault(prefix, p)
        with open(idx_path, "w", encoding="utf-8") as f:
            json.dump(idx, f, indent=0)
        self._index = idx
        return idx

    def extract_game_file(self, path):
        """path like a3\\ui_f\\data\\x.paa -> local cached file or None."""
        p = path.replace("/", "\\").strip("\\").lower()
        out = os.path.join(self.cache, "files", p.replace("\\", os.sep))
        if os.path.exists(out):
            return out
        idx = self.index()
        best = None
        for prefix in idx:
            if p.startswith(prefix + "\\") and (best is None or len(prefix) > len(best)):
                best = prefix
        if best is None:
            return None
        pbo = idx[best]
        rel = p[len(best) + 1:]
        try:
            _props, entries = read_pbo_header(pbo)
        except Exception:  # noqa: BLE001
            return None
        for name, off, size, mime in entries:
            if name == rel:
                if mime == 0x43707273:  # 'Cprs' compressed - unsupported
                    self.warn(f"compressed pbo entry {p}"); return None
                with open(pbo, "rb") as f:
                    f.seek(off); data = f.read(size)
                os.makedirs(os.path.dirname(out), exist_ok=True)
                with open(out, "wb") as f:
                    f.write(data)
                return out
        return None

    def paa_to_png(self, src):
        dst = os.path.join(self.cache, "png", re.sub(r"[:\\/]+", "_", os.path.abspath(src)) + ".png")
        if os.path.exists(dst) and os.path.getmtime(dst) >= os.path.getmtime(src):
            return dst
        if not self.tool:
            return None
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        try:
            subprocess.run([self.tool, src, dst], capture_output=True, timeout=60)
        except (OSError, subprocess.TimeoutExpired):
            return None
        return dst if os.path.exists(dst) else None

    # ---- images -----------------------------------------------------------
    def resolve(self, path):
        p = path.strip().replace("/", "\\")
        cands = [p] if os.path.splitext(p)[1] else [p + ".paa", p + ".png", p + ".jpg"]
        for c in cands:
            if not c.startswith("\\"):
                local = os.path.join(self.mission, c.replace("\\", os.sep))
                if os.path.exists(local):
                    return local
            g = self.extract_game_file(c)
            if g:
                return g
        return None

    def image(self, path):
        """Return RGBA PIL image or None."""
        key = path.lower()
        if key in self._img:
            return self._img[key]
        img = None
        f = self.resolve(path)
        if f:
            if f.lower().endswith(".paa"):
                f = self.paa_to_png(f)
            if f:
                try:
                    img = Image.open(f).convert("RGBA")
                except OSError:
                    img = None
        if img is None:
            self.warn(f"image not found: {path}")
        self._img[key] = img
        return img
