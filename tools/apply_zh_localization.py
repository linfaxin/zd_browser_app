#!/usr/bin/env python3
"""
Replace English UI strings inside Dart non-raw string literals only.
Reads tools/zh_ui_map.tsv (English|||Chinese), longest keys first.
"""

from __future__ import annotations

import pathlib
import sys


def load_map(path: pathlib.Path) -> list[tuple[str, str]]:
    pairs: list[tuple[str, str]] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if "|||" not in line:
            continue
        en, zh = line.split("|||", 1)
        pairs.append((en, zh))
    pairs.sort(key=lambda x: len(x[0]), reverse=True)
    return pairs


def read_string_interpolation(body: str, start: int) -> tuple[str, int]:
    """Read ${...} or $identifier from body starting at body[start] == '$'. Returns (segment, new_index)."""
    if start >= len(body):
        return ("$", start + 1)
    if body[start] != "$":
        return ("", start)
    if start + 1 < len(body) and body[start + 1] == "{":
        j = start + 2
        depth = 1
        while j < len(body) and depth > 0:
            c = body[j]
            if c == "{":
                depth += 1
            elif c == "}":
                depth -= 1
            j += 1
        return (body[start:j], j)
    j = start + 1
    while j < len(body) and (body[j].isalnum() or body[j] == "_"):
        j += 1
    return (body[start:j], j)


def decode_dart_string_body(body: str, double_quote: bool) -> str:
    out: list[str] = []
    i = 0
    close = '"' if double_quote else "'"
    while i < len(body):
        c = body[i]
        if c == "\\":
            if i + 1 >= len(body):
                out.append(c)
                i += 1
                continue
            n = body[i + 1]
            if n == "n":
                out.append("\n")
                i += 2
            elif n == "r":
                out.append("\r")
                i += 2
            elif n == "t":
                out.append("\t")
                i += 2
            elif n == "\\":
                out.append("\\")
                i += 2
            elif double_quote and n == '"':
                out.append('"')
                i += 2
            elif not double_quote and n == "'":
                out.append("'")
                i += 2
            elif n == "$":
                out.append("$")
                i += 2
            else:
                out.append(n)
                i += 2
            continue
        if c == "$":
            seg, j = read_string_interpolation(body, i)
            out.append(seg)
            i = j
            continue
        out.append(c)
        i += 1
    return "".join(out)


def encode_dart_string_body(s: str, double_quote: bool) -> str:
    out: list[str] = []
    close = '"' if double_quote else "'"
    i = 0
    while i < len(s):
        ch = s[i]
        if ch == "\\":
            out.append("\\\\")
            i += 1
        elif double_quote and ch == '"':
            out.append('\\"')
            i += 1
        elif not double_quote and ch == "'":
            out.append("\\'")
            i += 1
        elif ch == "\n":
            out.append("\\n")
            i += 1
        elif ch == "\r":
            out.append("\\r")
            i += 1
        elif ch == "\t":
            out.append("\\t")
            i += 1
        elif ch == "$":
            if i + 1 < len(s) and s[i + 1] == "{":
                seg, j = read_string_interpolation(s, i)
                out.append(seg)
                i = j
            else:
                out.append(r"\$")
                i += 1
        else:
            out.append(ch)
            i += 1
    return "".join(out)


def replace_literals_in_text(text: str, pairs: list[tuple[str, str]]) -> str:
    result: list[str] = []
    i = 0
    n = len(text)

    while i < n:
        if i + 1 < n and text[i] == "/" and text[i + 1] == "/":
            j = text.find("\n", i)
            if j == -1:
                result.append(text[i:])
                break
            result.append(text[i : j + 1])
            i = j + 1
            continue
        if i + 1 < n and text[i] == "/" and text[i + 1] == "*":
            j = text.find("*/", i + 2)
            if j == -1:
                result.append(text[i:])
                break
            result.append(text[i : j + 2])
            i = j + 2
            continue

        start = i
        raw = False
        if text[i] == "r" and i + 1 < n and text[i + 1] in "\"'":
            raw = True
            i += 1
        if i >= n or text[i] not in "\"'":
            result.append(text[start])
            i = start + 1
            continue
        quote = text[i]
        double_q = quote == '"'
        i += 1
        body_start = i

        if raw:
            while i < n and text[i] != quote:
                i += 1
            body = text[body_start:i]
            decoded = body
        else:
            while i < n:
                c = text[i]
                if c == "\\":
                    i += 2 if i + 1 < n else 1
                    continue
                if c == quote:
                    break
                i += 1
            body = text[body_start:i]
            decoded = decode_dart_string_body(body, double_q)

        if i >= n:
            result.append(text[start:])
            break
        closing = i
        i += 1

        replacement_zh = None
        for en, zh in pairs:
            if decoded == en:
                replacement_zh = zh
                break
        if replacement_zh is None:
            result.append(text[start : closing + 1])
            continue

        new_body = encode_dart_string_body(replacement_zh, double_q)
        result.append(text[start:body_start] + new_body + quote)

    return "".join(result)


def apply_to_file(path: pathlib.Path, pairs: list[tuple[str, str]]) -> bool:
    orig = path.read_text(encoding="utf-8")
    new = replace_literals_in_text(orig, pairs)
    if new != orig:
        path.write_text(new, encoding="utf-8")
        return True
    return False


def main() -> int:
    root = pathlib.Path(__file__).resolve().parents[1]
    map_path = root / "tools" / "zh_ui_map.tsv"
    if not map_path.is_file():
        print(f"missing {map_path}", file=sys.stderr)
        return 1
    pairs = load_map(map_path)
    changed = 0
    for dart in sorted((root / "lib").rglob("*.dart")):
        if apply_to_file(dart, pairs):
            changed += 1
    print(f"updated {changed} dart files")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
