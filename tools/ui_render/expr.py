"""Numeric expression evaluator for UI configs, plus the Arma safezone model.

Safezone formula (verified against diag_log of getResolution/safezone* in
mybuild/hippo_tests/*/client1/*.rpt, e.g. 1280x720 uiScale 1 ->
safezoneX=-0.166667 W=1.33333 H=1; 840x360 (21:9) -> X=-0.375 W=1.75 H=1):

    safezoneH = 1 / uiScale
    safezoneW = safezoneH * aspect * 3/4          (aspect = screenW / screenH)
    safezoneX = (1 - safezoneW) / 2 ;  safezoneY = (1 - safezoneH) / 2
    pixelW = safezoneW / screenW ; pixelH = safezoneH / screenH

uiScale per Interface Size option: very small 0.47, small 0.55, normal 0.7,
large 0.85, very large 1.0.  The capture harness profiles run "very large".
Screen mapping: px = (x - safezoneX) / safezoneW * screenW (same for y).
"""
import re

UI_SCALES = {"verysmall": 0.47, "small": 0.55, "normal": 0.7, "large": 0.85, "verylarge": 1.0}


class Env:
    def __init__(self, width=1920, height=1080, uisize="verylarge"):
        self.width, self.height = width, height
        scale = UI_SCALES.get(str(uisize).lower().replace(" ", "").replace("_", ""))
        if scale is None:
            scale = float(uisize)
        self.uiscale = scale
        self.szH = 1.0 / scale
        self.szW = self.szH * (width / height) * 0.75
        self.szX = (1 - self.szW) / 2
        self.szY = (1 - self.szH) / 2
        self.vars = {
            "safezonex": self.szX, "safezoney": self.szY,
            "safezonew": self.szW, "safezoneh": self.szH,
            "safezonexabs": self.szX, "safezonewabs": self.szW,
            "pixelw": self.szW / width, "pixelh": self.szH / height,
            "pixelgrid": 4.0, "pixelgridbase": 4.0, "pixelgridnouiscale": 4.0 / scale,
            "pi": 3.141592653589793, "true": 1.0, "false": 0.0,
        }

    def px(self, x, y):
        return ((x - self.szX) / self.szW * self.width, (y - self.szY) / self.szH * self.height)

    def sx(self, w):
        return w / self.szW * self.width

    def sy(self, h):
        return h / self.szH * self.height


class EvalError(Exception):
    pass


TOK = re.compile(r"\s*(?:(0x[0-9a-fA-F]+)|(\d+\.?\d*(?:[eE][-+]?\d+)?|\.\d+(?:[eE][-+]?\d+)?)|([A-Za-z_]\w*)|(.))")


def _unwrap_getvariable(s):
    """Replace `xxx getVariable [name, default]` by `(default)`."""
    low = s.lower()
    while True:
        k = low.find("getvariable")
        if k < 0:
            return s
        b = s.find("[", k)
        if b < 0:
            return s
        depth, j, comma = 0, b, -1
        while j < len(s):
            c = s[j]
            if c in "[(":
                depth += 1
            elif c in "])":
                depth -= 1
                if depth == 0:
                    break
            elif c == "," and depth == 1 and comma < 0:
                comma = j
            j += 1
        default = s[comma + 1:j] if comma >= 0 else "0"
        # start of receiver word (profilenamespace / uinamespace / missionnamespace)
        m = re.search(r"([A-Za-z_]\w*)\s*$", s[:k])
        st = m.start() if m else k
        s = s[:st] + "(" + default + ")" + s[j + 1:]
        low = s.lower()


def evaluate(expr, env):
    if isinstance(expr, (int, float)):
        return float(expr)
    s = str(expr).strip()
    if not s:
        raise EvalError("empty")
    s = s.replace("__EVAL", "")
    s = _unwrap_getvariable(s)
    toks = []
    for m in TOK.finditer(s):
        h, num, ident, other = m.groups()
        if h:
            toks.append(("n", float(int(h, 16))))
        elif num:
            toks.append(("n", float(num)))
        elif ident:
            toks.append(("i", ident.lower()))
        elif other and not other.isspace():
            toks.append(("o", other))
    toks.append(("e", None))
    pos = [0]

    def peek():
        return toks[pos[0]]

    def take():
        t = toks[pos[0]]; pos[0] += 1; return t

    def primary():
        t = take()
        if t[0] == "n":
            return t[1]
        if t[0] == "o" and t[1] in "([":
            v = add()
            take()
            return v
        if t[0] == "o" and t[1] == "-":
            return -primary()
        if t[0] == "o" and t[1] == "+":
            return primary()
        if t[0] == "i":
            name = t[1]
            if name in ("min", "max", "abs", "floor", "ceil", "round", "sqrt"):
                import math
                if name in ("min", "max"):
                    # SQF infix: a min b ; also allow min(a,b)
                    if peek() == ("o", "("):
                        take(); a = add()
                        if peek() == ("o", ","):
                            take(); b = add(); take()
                            return min(a, b) if name == "min" else max(a, b)
                        take(); return a
                    raise EvalError("min/max needs args")
                v = primary()
                return {"abs": abs, "floor": math.floor, "ceil": math.ceil,
                        "round": round, "sqrt": math.sqrt}[name](v)
            if name in env.vars:
                return env.vars[name]
            raise EvalError(f"unknown identifier {name}")
        raise EvalError(f"unexpected {t[1]!r}")

    def mul():
        v = primary()
        while True:
            t = peek()
            if t == ("o", "*"):
                take(); v *= primary()
            elif t == ("o", "/"):
                take(); d = primary(); v = v / d if d else 0.0
            elif t == ("o", "%"):
                take(); d = primary(); v = v % d if d else 0.0
            else:
                return v

    def add():
        v = mul()
        while True:
            t = peek()
            if t == ("o", "+"):
                take(); v += mul()
            elif t == ("o", "-"):
                take(); v -= mul()
            elif t == ("i", "min"):
                take(); v = min(v, mul())
            elif t == ("i", "max"):
                take(); v = max(v, mul())
            else:
                return v

    v = add()
    if peek()[0] != "e":
        raise EvalError(f"trailing tokens in {s!r}")
    return v


def try_eval(expr, env, default=0.0, warn=None):
    try:
        return evaluate(expr, env)
    except (EvalError, ZeroDivisionError, ValueError, IndexError, TypeError) as e:
        if warn is not None:
            warn(f"cannot evaluate {expr!r}: {e}")
        return default
