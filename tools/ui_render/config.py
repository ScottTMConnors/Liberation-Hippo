"""Arma config (rapified-text) parser with Arma-style class inheritance lookup."""
import re


class Str(str):
    """A quoted config string (as opposed to a bare expression)."""


class ConfigClass:
    def __init__(self, name, base_name=None, container=None):
        self.name = name
        self.base_name = base_name
        self.container = container
        self.entries = {}     # lower name -> value (ConfigClass, Str, str expr, list)
        self.order = []       # lower names in definition order
        self.names = {}       # lower -> original case
        self._base = None
        self._base_done = False

    def __repr__(self):
        return f"<class {self.name}{' : ' + self.base_name if self.base_name else ''}>"

    def set(self, name, value):
        k = name.lower()
        if k not in self.entries:
            self.order.append(k)
        self.entries[k] = value
        self.names[k] = name

    @property
    def base(self):
        if not self._base_done:
            self._base_done = True
            if self.base_name:
                self._base = self._resolve_base()
                if self._base is None:
                    ROOT_WARNINGS.append(f"base class {self.base_name} of {self.path()} not found")
        return self._base

    def _resolve_base(self):
        key = self.base_name.lower()
        scope = self.container
        while scope is not None:
            c = scope.get(key, skip=self)
            if isinstance(c, ConfigClass) and c is not self:
                return c
            scope = scope.container
        return None

    def path(self):
        parts, c = [], self
        while c is not None and c.container is not None:
            parts.append(c.name); c = c.container
        return "/".join(reversed(parts))

    def get(self, name, default=None, skip=None, _seen=None):
        k = name.lower()
        c, seen = self, set()
        while c is not None and id(c) not in seen:
            seen.add(id(c))
            v = c.entries.get(k)
            if v is not None and v is not skip:
                return v
            c = c.base
        return default

    def has(self, name):
        return self.get(name) is not None

    def classes(self):
        """Child classes incl. inherited, base-first order, overrides in place."""
        chain, c, seen = [], self, set()
        while c is not None and id(c) not in seen:
            seen.add(id(c)); chain.append(c); c = c.base
        order, result = [], {}
        for cls in reversed(chain):
            for k in cls.order:
                v = cls.entries[k]
                if isinstance(v, ConfigClass):
                    if k not in result:
                        order.append(k)
                    result[k] = v
        return [result[k] for k in order]

    def is_subclass_of(self, name):
        c, seen = self, set()
        while c is not None and id(c) not in seen:
            if c.name.lower() == name.lower():
                return True
            seen.add(id(c)); c = c.base
        return False


ROOT_WARNINGS = []

TOKEN = re.compile(r'\s*(?:(?P<str>"(?:[^"]|"")*")|(?P<punct>\+=|[{}\[\];:=,])|(?P<word>[^\s{}\[\];:=,"]+))')


class ParseError(Exception):
    pass


class Parser:
    def __init__(self, text):
        self.s = text
        self.i = 0
        self.n = len(text)
        self.warnings = []

    def skip_ws(self):
        while self.i < self.n and self.s[self.i].isspace():
            self.i += 1

    def peek_word(self):
        self.skip_ws()
        m = re.compile(r"[A-Za-z_][\w]*").match(self.s, self.i)
        return m.group(0) if m else None

    def expect(self, ch):
        self.skip_ws()
        if self.s.startswith(ch, self.i):
            self.i += len(ch); return True
        return False

    def line(self):
        return self.s.count("\n", 0, self.i) + 1

    def parse(self):
        root = ConfigClass("", None, None)
        self.body(root, top=True)
        return root

    def recover(self):
        """Skip to after the next ';' (or a '}' which we leave)."""
        depth = 0
        while self.i < self.n:
            c = self.s[self.i]
            if c == '"':
                self.read_string(); continue
            if c == "{":
                depth += 1
            elif c == "}":
                if depth == 0:
                    return
                depth -= 1
            elif c == ";" and depth == 0:
                self.i += 1; return
            self.i += 1

    def body(self, cls, top=False):
        while True:
            self.skip_ws()
            if self.i >= self.n:
                if not top:
                    self.warnings.append(f"unexpected EOF in class {cls.name}")
                return
            if self.s[self.i] == "}":
                if top:
                    self.warnings.append(f"line {self.line()}: stray '}}'")
                    self.i += 1; continue
                self.i += 1
                self.expect(";")
                return
            if self.s[self.i] == ";":
                self.i += 1; continue
            start = self.i
            try:
                self.entry(cls)
            except ParseError as e:
                self.warnings.append(f"line {self.line()}: {e}")
                if self.i == start:
                    self.i += 1
                self.recover()

    def entry(self, cls):
        w = self.peek_word()
        if w is None:
            raise ParseError(f"unexpected {self.s[self.i:self.i+20]!r}")
        if w == "class":
            self.i += 5
            name = self.peek_word()
            if not name:
                raise ParseError("class without name")
            self.i += len(name)
            base = None
            if self.expect(":"):
                base = self.peek_word()
                if not base:
                    raise ParseError("bad base")
                self.i += len(base)
            if self.expect("{"):
                existing = cls.entries.get(name.lower())
                if isinstance(existing, ConfigClass) and existing.base_name is None and base is None:
                    c = existing  # class reopened
                else:
                    c = ConfigClass(name, base, cls)
                cls.set(name, c)
                self.body(c)
            else:
                self.expect(";")
                if name.lower() not in cls.entries:  # forward declaration / external
                    cls.set(name, ConfigClass(name, None, cls))
            return
        if w == "delete":
            self.i += 6
            name = self.peek_word() or ""
            self.i += len(name)
            self.expect(";")
            cls.entries.pop(name.lower(), None)
            if name.lower() in cls.order:
                cls.order.remove(name.lower())
            return
        if w in ("__EXEC",):
            self.recover(); return
        self.i += len(w)
        is_array = False
        if self.expect("["):
            if not self.expect("]"):
                raise ParseError("bad array name")
            is_array = True
        if self.expect("+="):
            val = self.array()
            old = cls.get(w)
            cls.set(w, (list(old) if isinstance(old, list) else []) + val)
        elif self.expect("="):
            if is_array:
                self.skip_ws()
                if self.s.startswith("{", self.i):
                    cls.set(w, self.array())
                else:
                    cls.set(w, self.scalar())
            else:
                cls.set(w, self.scalar())
        else:
            raise ParseError(f"expected '=' after {w}")
        self.expect(";")

    def read_string(self):
        assert self.s[self.i] == '"'
        j = self.i + 1
        buf = []
        while j < self.n:
            c = self.s[j]
            if c == '"':
                if j + 1 < self.n and self.s[j + 1] == '"':
                    buf.append('"'); j += 2; continue
                break
            buf.append(c); j += 1
        self.i = j + 1
        return Str("".join(buf))

    def scalar(self):
        """Read until ';' / '}' / ',' (at depth 0). Quoted single string -> Str."""
        self.skip_ws()
        start = self.i
        if self.i < self.n and self.s[self.i] == '"':
            st = self.read_string()
            j = self.i
            while j < self.n and self.s[j] in " \t":
                j += 1
            if j >= self.n or self.s[j] in ";},\n":
                return st
            self.i = start
        depth = 0
        while self.i < self.n:
            c = self.s[self.i]
            if c == '"':
                self.read_string(); continue
            if c in "([":
                depth += 1
            elif c in ")]":
                depth -= 1
            elif depth <= 0 and c in ";},":
                break
            elif depth <= 0 and c == "\n":
                # values may lack ';' at line end
                rest = self.s[self.i:self.i + 200].lstrip()
                if rest[:1] in ("}",) or rest.startswith("class "):
                    break
            self.i += 1
        return self.s[start:self.i].strip()

    def array(self):
        if not self.expect("{"):
            raise ParseError("expected '{'")
        out = []
        while True:
            self.skip_ws()
            if self.i >= self.n:
                raise ParseError("unterminated array")
            c = self.s[self.i]
            if c == "}":
                self.i += 1; return out
            if c == ",":
                self.i += 1; continue
            if c == "{":
                out.append(self.array())
            else:
                v = self.scalar()
                if v == "" and self.i < self.n and self.s[self.i] not in "},":
                    self.i += 1
                    continue
                if v != "" or isinstance(v, Str):
                    out.append(v)


def parse(text):
    p = Parser(text)
    root = p.parse()
    return root, p.warnings
