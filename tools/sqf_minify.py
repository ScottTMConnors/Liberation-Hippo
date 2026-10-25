"""Conservative, deterministic multi-file SQF release compaction.

Author: thehungrehippo. Ported from Arma3BuildingDestruction for LiberationRX.
The UltimateGore SQFMinifier was inspected read-only on 2026-10-20 as requested.
The original implementation was independently written there; no external tool, command
catalogue, preferences, assemblies or UltimateGore path is required at runtime.

Default compaction preserves the EXACT non-comment token sequence, all literal
contents and all variable names. It reduces release text/load input, not the
cost of executing an already compiled function. It does not promise higher FPS.
Preprocessed and __LINE__ inputs pass through intact: macro stringification can
observe whitespace even when an unexpanded token stream is unchanged.

Optional renaming requires an explicit reviewed allowlist of private locals.
One case-insensitive injective map spans the entire batch. This is an explicit
closed-world authoring contract, not a proof of SQF dynamic-scope safety. The
release build preserves names except its separately reviewed, call-free leaf
allowlist, guarded by declaration, literal and cross-file usage checks.
"""
from __future__ import annotations

import argparse
from dataclasses import dataclass
from functools import lru_cache
import hashlib
import json
from pathlib import Path
import re
from typing import Mapping

_WORD = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
_NUMBER = re.compile(r"(?:0[xX][0-9A-Fa-f]+|\$[0-9A-Fa-f]+|(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?)")
_PAIRS = frozenset(('>>', '>=', '<=', '==', '!=', '&&', '||', '##', '+=', '-=', '*=', '/='))
_SYMBOLS = frozenset('[]{}();,:=+-*/%^!<>#')
_MAGIC = frozenset(n.casefold() for n in (
    '_this', '_x', '_y', '_exception', '_fnc_scriptName', '_fnc_scriptNameParent',
    '_forEachIndex', '_self', '_thisArgs', '_thisEvent', '_thisEventHandler',
    '_thisFSM', '_thisScript', '_thisScriptedEventHandler'))


@dataclass(frozen=True)
class Token:
    kind: str
    text: str


def tokenize(source: str) -> list[Token]:
    """Read SQF lexical units, rejecting incomplete strings/comments.

    SQF quotes escape by doubling the delimiter; backslashes remain literal.
    The scanner never strips comments inside string data or compile strings.
    """
    tokens: list[Token] = []
    i = 0
    line_start = True
    length = len(source)
    while i < length:
        ch = source[i]
        if ch.isspace() or (i == 0 and ch == '\ufeff'):
            if ch in '\r\n':
                line_start = True
            i += 1
            continue
        if source.startswith('//', i):
            ends = [p for c in ('\r', '\n') if (p := source.find(c, i + 2)) >= 0]
            i = min(ends, default=length)
            continue
        if source.startswith('/*', i):
            end = source.find('*/', i + 2)
            if end < 0:
                raise ValueError(f'Unterminated SQF comment at offset {i}')
            if '\n' in source[i:end + 2] or '\r' in source[i:end + 2]:
                line_start = True
            i = end + 2
            continue
        start = i
        if line_start and ch == '#' and re.match(r'#[ \t]*[A-Za-z]', source[i:]):
            while True:
                ends = [p for c in ('\r', '\n') if (p := source.find(c, i)) >= 0]
                end = min(ends, default=length)
                if end == length:
                    i = length
                    break
                continued = source[start:end].endswith('\\')
                i = end
                if continued:
                    i += 2 if source.startswith('\r\n', end) else 1
                if not continued:
                    break
            kind = 'directive'
        elif ch in ('"', "'"):
            i += 1
            while i < length:
                if source[i] != ch:
                    i += 1
                elif i + 1 < length and source[i + 1] == ch:
                    i += 2
                else:
                    i += 1
                    break
            else:
                raise ValueError(f'Unterminated SQF string at offset {start}')
            kind = 'string'
        elif match := _NUMBER.match(source, i):
            i = match.end()
            kind = 'number'
        elif match := _WORD.match(source, i):
            i = match.end()
            kind = 'word'
        elif source[i:i + 2] in _PAIRS:
            i += 2
            kind = 'symbol'
        elif ch in _SYMBOLS:
            i += 1
            kind = 'symbol'
        else:
            raise ValueError(f'Unsupported SQF character {ch!r} at offset {i}')
        tokens.append(Token(kind, source[start:i]))
        line_start = False
    return tokens


@lru_cache(maxsize=8192)
def _separate(left: Token, right: Token) -> bool:
    # Re-lex only the boundary pair, caching repeated pairs. This also catches
    # adjacent same-quote strings becoming a single doubled-quote literal.
    # '#' followed by a word at a new line would otherwise become a directive.
    if left.text.endswith('/') and right.text.startswith(('/', '*')):
        return True
    try:
        return tokenize(left.text + right.text) != [left, right]
    except ValueError:
        return True


def _emit(tokens: list[Token]) -> str:
    output: list[str] = []
    previous: Token | None = None
    for token in tokens:
        if token.kind == 'directive':
            if output and not output[-1].endswith('\n'):
                output.append('\n')
            output.extend((token.text, '\n'))
            previous = None
        else:
            if previous is not None and _separate(previous, token):
                output.append(' ')
            output.append(token.text)
            previous = token
    return ''.join(output).rstrip('\r\n')


def validate_equivalent(before: str, after: str) -> dict:
    """Exact lexical preservation; not a substitute for native SQF execution."""
    original = tokenize(before)
    compact = tokenize(after)
    if original != compact:
        first = next((i for i, pair in enumerate(zip(original, compact)) if pair[0] != pair[1]),
                     min(len(original), len(compact)))
        raise ValueError(f'Minification changed SQF token stream at token {first}')
    if any(t.kind == 'directive' or '__LINE__' in t.text for t in original) and before != after:
        raise ValueError('Preprocessed/line-sensitive SQF must be preserved byte for byte')
    return {'tokens': len(original), 'strings': sum(t.kind == 'string' for t in original),
            'directives': sum(t.kind == 'directive' for t in original),
            'token_stream_identical': True}


def minify(text: str) -> str:
    tokens = tokenize(text)
    compact = text if any(t.kind == 'directive' or '__LINE__' in t.text for t in tokens) else _emit(tokens)
    validate_equivalent(text, compact)
    return compact


def _local_map(documents: Mapping[str, list[Token]], names, prefix='_') -> dict[str, str]:
    if not _WORD.fullmatch(prefix) or not prefix.startswith('_'):raise ValueError('Invalid private alias prefix')
    selected = {name.casefold() for name in names}
    if not selected:
        return {}
    if any(not _WORD.fullmatch(n) or not n.startswith('_') or n in _MAGIC for n in selected):
        raise ValueError('Only explicitly allowlisted, non-magic local identifiers may be renamed')
    all_tokens = [token for tokens in documents.values() for token in tokens]
    if any(t.kind == 'directive' for t in all_tokens):
        raise ValueError('Local renaming is disabled for preprocessed inputs')
    if any(t.kind == 'word' and t.text.casefold() in ('compile', 'compilefinal', 'callExtension'.casefold())
           for t in all_tokens):
        raise ValueError('Local renaming is disabled for dynamic executable inputs')
    present = {t.text.casefold() for t in all_tokens if t.kind == 'word'}
    if selected - present:
        raise ValueError('Allowlisted locals missing from executable input: ' + ', '.join(sorted(selected - present)))
    # Partial references in messages, generated code or names cannot be rewritten
    # safely. Exact identifier literals are synchronized for params/private/isNil.
    for token in all_tokens:
        if token.kind != 'string':
            continue
        content = token.text[1:-1].replace(token.text[0] * 2, token.text[0])
        mentioned = selected.intersection(w.casefold() for w in _WORD.findall(content))
        if mentioned and content.casefold() not in selected:
            raise ValueError('Allowlisted local occurs inside opaque string data: ' + content[:80])
    occupied = present | _MAGIC
    occupied.update(t.text[1:-1].casefold() for t in all_tokens if t.kind == 'string')
    mapping: dict[str, str] = {}
    counter = 0
    for name in sorted(selected):
        while True:
            # Predictable compact identifier allocation permits reproducible builds.
            number, suffix = counter, ''
            counter += 1
            while True:
                suffix = chr(97 + number % 26) + suffix
                number = number // 26 - 1
                if number < 0:
                    break
            candidate = prefix + suffix
            if candidate not in occupied:
                occupied.add(candidate)
                mapping[name] = candidate
                break
    return mapping


def minify_files(files: Mapping[str, str], *, rename_locals=(), rename_prefix='_') -> tuple[dict[str, str], dict]:
    """Compact one complete release batch with a single optional local-name map.

    All globals, engine magic locals and filenames are always protected. Renaming
    requires callers to audit external/dynamically generated references and test
    exact outputs in-engine. Name-preserving mode provides the stronger invariant.
    """
    parsed = {name: tokenize(text) for name, text in sorted(files.items())}
    mapping = _local_map(parsed, rename_locals,rename_prefix)
    outputs: dict[str, str] = {}
    reports = {}
    for name, tokens in parsed.items():
        source = files[name]
        if mapping and any('__LINE__' in t.text for t in tokens):
            raise ValueError('Line-sensitive inputs cannot participate in local renaming')
        rewritten = []
        for token in tokens:
            replacement = mapping.get(token.text.casefold()) if token.kind == 'word' else None
            if token.kind == 'string':
                replacement = mapping.get(token.text[1:-1].casefold())
                if replacement:
                    replacement = token.text[0] + replacement + token.text[0]
            rewritten.append(Token(token.kind, replacement or token.text))
        compact = _emit(rewritten) if mapping else minify(source)
        if tokenize(compact) != rewritten:
            raise ValueError(f'Rewritten token stream mismatch: {name}')
        outputs[name] = compact
        reports[name] = {
            'source_bytes': len(source.encode('utf-8')), 'release_bytes': len(compact.encode('utf-8')),
            'source_sha256': hashlib.sha256(source.encode('utf-8')).hexdigest(),
            'release_sha256': hashlib.sha256(compact.encode('utf-8')).hexdigest(),
            'tokens': len(tokens), 'token_stream_identical': tokens == rewritten,
            'renamed_tokens_verified': tokens != rewritten,
            'line_sensitive_passthrough': '__LINE__' in source,
        }
    return outputs, {'schema': 1, 'mode': 'explicit-local-map' if mapping else 'exact-token-compaction',
                     'renames': mapping, 'files': reports,
                     'source_bytes': sum(r['source_bytes'] for r in reports.values()),
                     'release_bytes': sum(r['release_bytes'] for r in reports.values()),
                     'limitations': 'Lexical preservation; engine execution and external dynamic scope require native testing.'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    source, output = args.source.resolve(), args.output.resolve()
    if source == output or source in output.parents:
        raise SystemExit('Use a separate staging output outside the source directory')
    paths = sorted(source.rglob('*.sqf')) if source.is_dir() else [source]
    texts = {p.relative_to(source).as_posix() if source.is_dir() else p.name:
             p.read_text(encoding='utf-8-sig') for p in paths}
    outputs, report = minify_files(texts)
    output.mkdir(parents=True, exist_ok=True)
    for relative, text in outputs.items():
        target = output / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text, encoding='utf-8', newline='\n')
    print(json.dumps({k: v for k, v in report.items() if k != 'files'}, separators=(',', ':')))


if __name__ == '__main__':
    main()
