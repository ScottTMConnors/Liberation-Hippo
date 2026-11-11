"""Minimal Arma config preprocessor (#include/#define/#ifdef ..., macro expansion)."""
import os
import re

IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")


class Macro:
    def __init__(self, name, params, body):
        self.name, self.params, self.body = name, params, body


def _strip_comments(text):
    out, i, n = [], 0, len(text)
    while i < n:
        c = text[i]
        if c == '"':
            j = i + 1
            while j < n:
                if text[j] == '"':
                    if j + 1 < n and text[j + 1] == '"':
                        j += 2
                        continue
                    break
                if text[j] == "\n":
                    break
                j += 1
            out.append(text[i:j + 1]); i = j + 1
        elif text.startswith("//", i):
            j = text.find("\n", i)
            i = n if j < 0 else j
        elif text.startswith("/*", i):
            j = text.find("*/", i + 2)
            seg = text[i:(n if j < 0 else j + 2)]
            out.append("\n" * seg.count("\n"))  # keep line numbers
            i = n if j < 0 else j + 2
        else:
            out.append(c); i += 1
    return "".join(out)


def _split_args(s, i):
    """s[i] == '('. Return (args, index after ')')."""
    depth, args, cur, j = 0, [], [], i + 1
    in_str = False
    while j < len(s):
        c = s[j]
        if in_str:
            cur.append(c)
            if c == '"':
                in_str = False
        elif c == '"':
            in_str = True; cur.append(c)
        elif c in "([{":
            depth += 1; cur.append(c)
        elif c in ")]}":
            if depth == 0 and c == ")":
                args.append("".join(cur).strip())
                return args, j + 1
            depth -= 1; cur.append(c)
        elif c == "," and depth == 0:
            args.append("".join(cur).strip()); cur = []
        else:
            cur.append(c)
        j += 1
    raise ValueError("unterminated macro call")


class Preprocessor:
    def __init__(self, defines=None):
        self.macros = {}
        self.warnings = []
        self.files = []
        for k, v in (defines or {}).items():
            self.macros[k] = Macro(k, None, v)

    def warn(self, msg):
        self.warnings.append(msg)

    # ---- expansion -------------------------------------------------------
    def expand(self, line, depth=0, active=frozenset()):
        if depth > 40:
            return line
        out, i, n = [], 0, len(line)
        changed = False
        while i < n:
            c = line[i]
            if c == '"':
                j = i + 1
                while j < n and not (line[j] == '"' and not (j + 1 < n and line[j + 1] == '"')):
                    j += 2 if line[j] == '"' else 1
                out.append(line[i:j + 1]); i = j + 1
                continue
            m = IDENT.match(line, i) if (c.isalpha() or c == "_") else None
            if not m:
                out.append(c); i += 1
                continue
            name = m.group(0)
            # skip identifiers that are part of a number like 0x800 handled by isalpha on 'x'? '0x' starts with digit
            if i > 0 and (line[i - 1].isalnum() or line[i - 1] == "_"):
                out.append(name); i = m.end(); continue
            mac = self.macros.get(name)
            if mac is None or name in active:
                out.append(name); i = m.end(); continue
            j = m.end()
            if mac.params is None:
                rep = mac.body
            else:
                k = j
                while k < n and line[k] in " \t":
                    k += 1
                if k >= n or line[k] != "(":
                    out.append(name); i = j; continue
                try:
                    args, j = _split_args(line, k)
                except ValueError:
                    self.warn(f"bad macro call {name}")
                    out.append(name); i = m.end(); continue
                args = [self.expand(a, depth + 1, active) for a in args]
                rep = self._subst(mac, args)
            rep = self.expand(rep, depth + 1, active | {name})
            out.append(rep); i = j; changed = True
        return "".join(out)

    def _subst(self, mac, args):
        args = list(args) + [""] * (len(mac.params) - len(args))
        amap = dict(zip(mac.params, args))
        body = mac.body
        res, i, n = [], 0, len(body)
        while i < n:
            c = body[i]
            if c == "#" and i + 1 < n and body[i + 1] == "#":
                while res and res[-1] in " \t":
                    res.pop()
                i += 2
                while i < n and body[i] in " \t":
                    i += 1
                continue
            if c == "#":
                m = IDENT.match(body, i + 1)
                if m and m.group(0) in amap:
                    res.append('"' + amap[m.group(0)] + '"'); i = m.end(); continue
                res.append(c); i += 1; continue
            if c.isalpha() or c == "_":
                m = IDENT.match(body, i)
                w = m.group(0)
                res.append(amap.get(w, w)); i = m.end(); continue
            res.append(c); i += 1
        return "".join(res)

    # ---- files -----------------------------------------------------------
    def process_file(self, path):
        out = []
        self._file(os.path.normpath(path), out, 0)
        return "\n".join(out)

    def _file(self, path, out, depth):
        if depth > 30:
            self.warn(f"include depth exceeded at {path}"); return
        try:
            with open(path, "r", encoding="utf-8-sig", errors="replace") as f:
                text = f.read()
        except OSError as e:
            self.warn(f"cannot read {path}: {e}"); return
        self.files.append(path)
        self.process_text(text, out, os.path.dirname(path), depth, path)

    def process_text(self, text, out=None, base=".", depth=0, fname="<text>"):
        ret = out is None
        if out is None:
            out = []
        text = text.replace("\r\n", "\n").replace("\r", "\n")
        text = re.sub(r"\\\n", " ", text)
        text = _strip_comments(text)
        stack = []  # each: [active, taken_branch]
        for lineno, raw in enumerate(text.split("\n"), 1):
            s = raw.strip()
            active = all(a for a, _ in stack)
            if s.startswith("#"):
                d = s[1:].strip()
                word = IDENT.match(d)
                kw = word.group(0) if word else ""
                rest = d[len(kw):].strip()
                if kw in ("ifdef", "ifndef"):
                    cond = (rest.split()[0] in self.macros) if rest else False
                    if kw == "ifndef":
                        cond = not cond
                    stack.append([cond, cond])
                elif kw == "if":
                    try:
                        cond = bool(eval(self.expand(rest).replace("&&", " and ").replace("||", " or "), {}, {}))
                    except Exception:
                        cond = False
                    stack.append([cond, cond])
                elif kw == "else":
                    if stack:
                        stack[-1][0] = not stack[-1][1]
                elif kw == "endif":
                    if stack:
                        stack.pop()
                elif not active:
                    pass
                elif kw == "include":
                    m = re.match(r'["<](.*?)[">]', rest)
                    if not m:
                        self.warn(f"{fname}:{lineno}: bad include {rest}"); continue
                    inc = m.group(1).replace("\\", "/")
                    p = os.path.normpath(os.path.join(base, inc))
                    if not os.path.exists(p):
                        self.warn(f"{fname}:{lineno}: include not found {inc}"); continue
                    self._file(p, out, depth + 1)
                elif kw == "define":
                    m = re.match(r"([A-Za-z_]\w*)(\(([^)]*)\))?\s*(.*)$", rest, re.S)
                    if not m:
                        self.warn(f"{fname}:{lineno}: bad define"); continue
                    params = None
                    if m.group(2) is not None:
                        params = [p.strip() for p in m.group(3).split(",") if p.strip()]
                    self.macros[m.group(1)] = Macro(m.group(1), params, m.group(4).strip())
                elif kw == "undef":
                    self.macros.pop(rest.split()[0] if rest else "", None)
                else:
                    self.warn(f"{fname}:{lineno}: ignored directive #{kw}")
                continue
            if active:
                out.append(self.expand(raw))
        if stack:
            self.warn(f"{fname}: unterminated #if block")
        if ret:
            return "\n".join(out)
