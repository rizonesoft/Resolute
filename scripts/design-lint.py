#!/usr/bin/env python3
"""Two-tier static design token and theme linter for Conclave-SDK repositories.

Stdlib-only Python 3. Reads repository UI sources (or staged git blobs with --staged)
and checks adherence to the project's design contract in one of three modes:

  strict      custom token-system apps: bans color-literal, font-family-literal,
              font-size-literal, spacing-radius-literal, and emoji-icon outside
              token definitions, generated theme tables, brand/reference folders,
              and documented exemptions.
  theme-only  accepted-look platform-native apps (e.g. docs/design-contract.md):
              bans color-literal outside theme resources and brand folders.
  off         repositories without a design contract or config: exits 0 cleanly.

Findings above a shrink-only baseline (.conclave/design-lint-baseline.json) fail
with exit 1 and <file>:<line>:<rule>:<message> lines.

Usage:
  python scripts/design-lint.py
  python scripts/design-lint.py --staged
  python scripts/design-lint.py --update-baseline [--allow-add --reason "..."]
  python scripts/design-lint.py --base HEAD
  python scripts/design-lint.py --self-test
"""
from __future__ import annotations

import argparse
from collections import defaultdict
import datetime as _dt
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

CREATION_FLAGS = getattr(subprocess, "CREATE_NO_WINDOW", 0) if os.name == "nt" else 0
DEFAULT_BASELINE = ".conclave/design-lint-baseline.json"
CONFIG_PATH = ".conclave/design-lint.json"
VALID_MODES = frozenset({"strict", "theme-only", "off"})
CONFIG_KEYS = frozenset({"schema_version", "mode", "contract", "ui_roots", "exclude", "generated", "baseline"})
ALL_RULES = (
    "color-literal",
    "font-family-literal",
    "font-size-literal",
    "spacing-radius-literal",
    "emoji-icon",
)
STRICT_MARKERS = (
    "design/SPEC.md",
    "design/tokens.json",
    "design/tokens",
    "docs/design/SPEC.md",
    "docs/design/tokens.json",
    "DESIGN.md",
    "sdk/DESIGN.md",
    "standards/design-contract.md",
)
THEME_ONLY_MARKERS = ("docs/design-contract.md",)

SKIP_DIR_NAMES = frozenset({
    ".git",
    ".agents",
    ".claude",
    ".codex",
    ".conclave",
    ".vs",
    ".vscode",
    "node_modules",
    "build",
    "dist",
    "out",
    "bin",
    "obj",
    "vcpkg_installed",
    "vendor",
    "__pycache__",
    "testresults",
    "tokens",
    "themes",
    "tests",
    "test",
})
DEFAULT_EXCLUDE_PREFIXES = (
    "design/",
    "brand/",
    "resources/brand/",
    "assets/brand/",
    "assets/icons/",
    "reference/",
    "docs/",
    "todo/",
    "scripts/",
    "tools/",
    "tests/",
    "test/",
)

XAML_EXTS = frozenset({".xaml"})
CS_EXTS = frozenset({".cs"})
CPP_EXTS = frozenset({".c", ".cc", ".cpp", ".cxx", ".c++", ".h", ".hh", ".hpp", ".hxx", ".h++", ".inl", ".ipp"})
CSS_EXTS = frozenset({".css", ".scss"})
WEB_CODE_EXTS = frozenset({".tsx", ".jsx", ".ts", ".js", ".html", ".htm", ".vue", ".svelte"})
ALL_EXTS = XAML_EXTS | CS_EXTS | CPP_EXTS | CSS_EXTS | WEB_CODE_EXTS

ALWAYS_UI_EXTS = frozenset({".xaml", ".css", ".scss", ".tsx", ".jsx", ".vue", ".svelte"})
HTML_UI_SEGMENTS = frozenset({
    "src", "app", "web", "frontend", "client", "ui", "views", "pages", "components",
    "panels", "dialogs", "controls", "windows", "chrome", "shell", "widgets", "wwwroot", "public",
})
CODE_UI_SEGMENTS = frozenset({
    "ui", "view", "views", "dialog", "dialogs", "panel", "panels", "control", "controls",
    "chrome", "shell", "window", "windows", "widget", "widgets", "page", "pages",
    "component", "components", "screen", "screens", "frontend", "web", "resources",
    "theme", "themes", "styles", "style", "kami", "converters",
})
UI_STEM_SUFFIXES = ("view", "window", "dialog", "panel", "page", "control", "overlay", "shell", "theme", "renderer", "canvas", "chrome")

GENERATED_RE = re.compile(
    r"(?:auto-)?generated\s+(?:from|by)\s+(?:[^\s]*(?:tokens\.json|generate-theme\.py|build-theme\.py|design-lint))",
    re.IGNORECASE,
)
WORKAROUND_RE = re.compile(r"\bWORKAROUND:\s*\S+")
ALLOW_RE = re.compile(r"\bdesign-lint:\s*allow\s+([a-z0-9_,\s-]+?)\s+--\s*\S+", re.IGNORECASE)

EMOJI_RE = re.compile(
    "[\U0001F000-\U0001FAFF\U00002600-\U000027BF\U00002B00-\U00002BFF"
    "\U0000231A-\U0000231B\U000023E9-\U000023FA\U0001F1E6-\U0001F1FF]"
)

URL_RE = re.compile(r"https?://[^\s\"'<>`]+")
ANCHOR_RE = re.compile(r"[A-Za-z0-9_./-]+\.[A-Za-z0-9]{1,8}#[A-Za-z0-9_-]+")
HEX_STR_RE = re.compile(r"(?<![\w/.-])#(?:[0-9A-Fa-f]{8}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{3,4})(?![\w-])")
CUSTOM_PROP_START_RE = re.compile(r"(?:(?<=^)|(?<=[;{}\"'\s=`]))--[A-Za-z0-9_-]+\s*:")

# XAML patterns
XAML_HEX_ATTR_RE = re.compile(
    r"=\s*([\"'])\s*(#(?:[0-9A-Fa-f]{8}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{3,4}))\s*\1"
)
XAML_NAMED_COLOR_RE = re.compile(
    r"\b(?:Background|Foreground|BorderBrush|Fill|Stroke|Color|TintColor|ShadowColor|CaretBrush|SelectionHighlightColor)"
    r"\s*=\s*([\"'])\s*([A-Za-z]+)\s*\1",
    re.IGNORECASE,
)
XAML_SAFE_NAMED_COLORS = frozenset({"transparent", "inherit", "null"})
XAML_NAMED_COLORS = frozenset({
    "aliceblue", "antiquewhite", "aqua", "aquamarine", "azure", "beige", "bisque", "black",
    "blanchedalmond", "blue", "blueviolet", "brown", "burlywood", "cadetblue", "chartreuse",
    "chocolate", "coral", "cornflowerblue", "cornsilk", "crimson", "cyan", "darkblue", "darkcyan",
    "darkgoldenrod", "darkgray", "darkgreen", "darkgrey", "darkkhaki", "darkmagenta", "darkolivegreen",
    "darkorange", "darkorchid", "darkred", "darksalmon", "darkseagreen", "darkslateblue",
    "darkslategray", "darkslategrey", "darkturquoise", "darkviolet", "deeppink", "deepskyblue",
    "dimgray", "dimgrey", "dodgerblue", "firebrick", "floralwhite", "forestgreen", "fuchsia",
    "gainsboro", "ghostwhite", "gold", "goldenrod", "gray", "green", "greenyellow", "grey",
    "honeydew", "hotpink", "indianred", "indigo", "ivory", "khaki", "lavender", "lavenderblush",
    "lawngreen", "lemonchiffon", "lightblue", "lightcoral", "lightcyan", "lightgoldenrodyellow",
    "lightgray", "lightgreen", "lightgrey", "lightpink", "lightsalmon", "lightseagreen",
    "lightskyblue", "lightslategray", "lightslategrey", "lightsteelblue", "lightyellow", "lime",
    "limegreen", "linen", "magenta", "maroon", "mediumaquamarine", "mediumblue", "mediumorchid",
    "mediumpurple", "mediumseagreen", "mediumslateblue", "mediumspringgreen", "mediumturquoise",
    "mediumvioletred", "midnightblue", "mintcream", "mistyrose", "moccasin", "navajowhite", "navy",
    "oldlace", "olive", "olivedrab", "orange", "orangered", "orchid", "palegoldenrod", "palegreen",
    "paleturquoise", "palevioletred", "papayawhip", "peachpuff", "peru", "pink", "plum", "powderblue",
    "purple", "rebeccapurple", "red", "rosybrown", "royalblue", "saddlebrown", "salmon", "sandybrown",
    "seagreen", "seashell", "sienna", "silver", "skyblue", "slateblue", "slategray", "slategrey",
    "snow", "springgreen", "steelblue", "tan", "teal", "thistle", "tomato", "turquoise", "violet",
    "wheat", "white", "whitesmoke", "yellow", "yellowgreen",
})
XAML_FONT_FAMILY_RE = re.compile(r"\bFontFamily\s*=\s*([\"'])(?!\s*\{)([^\"']+)\1")
XAML_FONT_SIZE_RE = re.compile(r"\bFontSize\s*=\s*([\"'])(?!\s*\{)\s*([0-9]+(?:\.[0-9]+)?)\s*\1")
XAML_GEOM_ATTR_RE = re.compile(
    r"\b(?:Margin|Padding|CornerRadius|BorderThickness|Spacing|RowSpacing|ColumnSpacing|StrokeThickness)"
    r"\s*=\s*([\"'])(?!\s*\{)([^\"']+)\1"
)

# C# patterns
CS_COLOR_API_RE = re.compile(
    r"\bColor(?:Helper)?\.FromArgb\s*\("
    r"|\bColor\.From(?:KnownColor|Name)\s*\("
    r"|\bColorTranslator\.(?:FromHtml|FromOle|FromWin32)\s*\("
    r"|\bnew\s+SolidColorBrush\s*\(\s*Colors\.(?!Transparent\b)[A-Za-z_]\w*"
    r"|\bColors\.(?!Transparent\b)[A-Z][A-Za-z0-9_]*\b"
)
CS_QUOTED_HEX_RE = re.compile(r"\"#(?:[0-9A-Fa-f]{8}|[0-9A-Fa-f]{6})\"")
CS_FONT_FAMILY_RE = re.compile(
    r"\bFontFamily\s*=\s*(?:new\s+FontFamily\s*\(\s*)?\"[^\"{}]+\""
    r"|\bnew\s+Font(?:Family)?\s*\(\s*\"[^\"{}]+\""
)
CS_FONT_SIZE_RE = re.compile(r"\bFontSize\s*=\s*([0-9]+(?:\.[0-9]+)?)[fFdDmM]?\b")
CS_GEOM_CTOR_RE = re.compile(r"\bnew\s+(?:Thickness|CornerRadius)\s*\(([^)]+)\)")
CS_GEOM_PROP_RE = re.compile(
    r"\b(?:Margin|Padding|CornerRadius|Spacing)\s*=\s*([0-9]+(?:\.[0-9]+)?)[fFdD]?\b"
)

# C / C++ patterns
CPP_COLOR_RE = re.compile(
    r"\b(?:PALETTE)?RGB(?:A)?\s*\("
    r"|\b(?:D2D1::)?ColorF::(?:Enum::)?(?!ColorF\b|Enum\b)[A-Za-z_]\w*"
    r"|\b(?:D2D1::)?ColorF\s*\(\s*(?:0[xX][0-9A-Fa-f]+|[0-9])"
    r"|\bD2D1_COLOR_F\s*[({=]\s*(?:0[xX][0-9A-Fa-f]+|[0-9])"
)
CPP_FONT_RE = re.compile(
    r"\bCreateTextFormat\s*\(\s*L?\"[^\"\\]+\""
    r"|\b(?:font_?family|FontFamily)\s*=\s*L?\"[^\"\\]+\""
)
CPP_TEXT_FORMAT_CALL_RE = re.compile(r"\bCreateTextFormat\s*\(([^;]{1,400})\)")
CPP_FONT_SIZE_ASSIGN_RE = re.compile(
    r"\b(?:font_?size|FontSize)\s*(?:=|\()\s*([0-9]+(?:\.[0-9]+)?)[fF]?\b"
)
CPP_ROUNDED_RECT_RE = re.compile(r"\b(?:D2D1::)?RoundedRect\s*\(([^;]{1,240})\)")
CPP_GEOM_ASSIGN_RE = re.compile(
    r"\b(?:corner_?radius|border_?radius|stroke_?width|border_?width|padding|margin|spacing|item_?spacing)\s*"
    r"=\s*([0-9]+(?:\.[0-9]+)?)[fF]?\b"
)

# Web patterns
CSS_CUSTOM_PROP_DEF_RE = re.compile(r"^\s*--[A-Za-z0-9_-]+\s*:")
CSS_FUNC_COLOR_RE = re.compile(r"\b(?:rgba?|hsla?|oklch|oklab|lab|lch)\s*\(([^)]+)\)", re.IGNORECASE)
CSS_FONT_FAMILY_RE = re.compile(
    r"\bfont-family\s*:(?!\s*(?:var\s*\(|inherit\b|initial\b|unset\b))([^;}\n]+)",
    re.IGNORECASE,
)
CSS_FONT_SIZE_RE = re.compile(
    r"\bfont-size\s*:(?!\s*(?:var\s*\(|inherit\b|initial\b|unset\b))([^;}\n]+)",
    re.IGNORECASE,
)
CSS_SPACING_PROP_RE = re.compile(
    r"(?<![-\w])(?:padding|margin|gap|row-gap|column-gap|border-radius)"
    r"(?:-(?:top|right|bottom|left|inline|block|start|end))*\s*:\s*([^;}\n]+)",
    re.IGNORECASE,
)
JS_FONT_FAMILY_RE = re.compile(
    r"\bfontFamily\s*[:=]\s*([\"'])(?!var\()([^\"']+)\1"
)
JS_FONT_SIZE_RE = re.compile(
    r"\bfontSize\s*[:=]\s*(?:([0-9]+(?:\.[0-9]+)?)|([\"'])([0-9]+(?:\.[0-9]+)?(?:px|rem|em|pt))\2)"
)
JS_SPACING_PROP_RE = re.compile(
    r"\b(?:padding|margin|gap|borderRadius)(?:Top|Right|Bottom|Left)?\s*[:=]\s*"
    r"(?:([0-9]+(?:\.[0-9]+)?)|([\"'])([^\"']+)\2)"
)


class ConfigError(Exception):
    """Configuration or invocation error (exit 2)."""


def _atomic_write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp_name = tempfile.mkstemp(dir=str(path.parent), prefix=f".{path.name}.", suffix=".tmp")
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(text)
            fh.flush()
        os.replace(tmp_name, path)
    except BaseException:
        if os.path.exists(tmp_name):
            os.unlink(tmp_name)
        raise


def _utc_now() -> str:
    return _dt.datetime.now(_dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _clean_rel(path_str: str) -> str:
    clean = path_str.replace("\\", "/")
    while clean.startswith("./"):
        clean = clean[2:]
    return clean.lstrip("/")


def _norm_prefix_list(items: object, key: str) -> list[str]:
    if not isinstance(items, list) or not all(isinstance(x, str) and x.strip() for x in items):
        raise ConfigError(f"{CONFIG_PATH}: '{key}' must be a list of non-empty strings")
    return [_clean_rel(x) for x in items]


def _load_config_dict(raw_text: str) -> dict:
    try:
        data = json.loads(raw_text)
    except ValueError as exc:
        raise ConfigError(f"{CONFIG_PATH} is not valid JSON: {exc}") from exc
    if not isinstance(data, dict):
        raise ConfigError(f"{CONFIG_PATH} must be a JSON object")
    unknown = set(data) - CONFIG_KEYS
    if unknown:
        raise ConfigError(f"{CONFIG_PATH} has unknown keys: {', '.join(sorted(unknown))}")
    sv = data.get("schema_version")
    if isinstance(sv, bool) or sv != 1:
        raise ConfigError(f"{CONFIG_PATH}: schema_version must be 1")
    mode = data.get("mode")
    if not isinstance(mode, str) or mode not in VALID_MODES:
        raise ConfigError(f"{CONFIG_PATH}: mode must be one of {', '.join(sorted(VALID_MODES))}")
    if "contract" in data and not (isinstance(data["contract"], str) and data["contract"].strip()):
        raise ConfigError(f"{CONFIG_PATH}: 'contract' must be a non-empty string")
    return {
        "schema_version": 1,
        "mode": mode,
        "contract": data.get("contract", ""),
        "ui_roots": _norm_prefix_list(data.get("ui_roots", []), "ui_roots") if "ui_roots" in data else [],
        "exclude": _norm_prefix_list(data.get("exclude", []), "exclude") if "exclude" in data else [],
        "generated": _norm_prefix_list(data.get("generated", []), "generated") if "generated" in data else [],
        "baseline": _clean_rel(data.get("baseline") or DEFAULT_BASELINE)
        if isinstance(data.get("baseline", DEFAULT_BASELINE), str)
        else _raise_cfg(f"{CONFIG_PATH}: 'baseline' must be a string"),
    }


def _raise_cfg(msg: str):
    raise ConfigError(msg)


def _auto_detect_mode(root: Path, index_paths: set[str] | None = None) -> str:
    if index_paths is not None:
        for marker in STRICT_MARKERS:
            if marker in index_paths or any(p.startswith(marker + "/") for p in index_paths):
                return "strict"
        for marker in THEME_ONLY_MARKERS:
            if marker in index_paths:
                return "theme-only"
        return "off"
    for marker in STRICT_MARKERS:
        if (root / marker).exists():
            return "strict"
    for marker in THEME_ONLY_MARKERS:
        if (root / marker).exists():
            return "theme-only"
    return "off"


def resolve_config(root: Path, staged: bool = False) -> dict:
    cfg_text: str | None = None
    index_paths: set[str] | None = None
    if staged:
        index_paths = _index_paths(root)
        if CONFIG_PATH in index_paths:
            cfg_text = _read_index_text(root, CONFIG_PATH)
    elif (root / CONFIG_PATH).is_file():
        try:
            cfg_text = (root / CONFIG_PATH).read_text(encoding="utf-8")
        except OSError as exc:
            raise ConfigError(f"cannot read {CONFIG_PATH}: {exc}") from exc

    if cfg_text is not None:
        return _load_config_dict(cfg_text)

    return {
        "schema_version": 1,
        "mode": _auto_detect_mode(root, index_paths),
        "contract": "",
        "ui_roots": [],
        "exclude": [],
        "generated": [],
        "baseline": DEFAULT_BASELINE,
    }


def _matches_prefix(rel_posix: str, prefix: str) -> bool:
    clean = prefix.rstrip("/")
    return rel_posix == clean or rel_posix.startswith(clean + "/")


def is_candidate_ui_file(rel_posix: str, cfg: dict) -> bool:
    ext = Path(rel_posix).suffix.lower()
    if ext not in ALL_EXTS:
        return False

    parts = rel_posix.split("/")
    low_parts = [p.lower() for p in parts[:-1]]
    if any(p in SKIP_DIR_NAMES or p.startswith("cmake-build-") for p in low_parts):
        return False

    for gen in cfg["generated"]:
        if rel_posix == gen.rstrip("/"):
            return False

    for exc in cfg["exclude"]:
        if _matches_prefix(rel_posix, exc):
            return False

    for pref in DEFAULT_EXCLUDE_PREFIXES:
        if _matches_prefix(rel_posix, pref):
            return False

    ui_roots = cfg["ui_roots"]
    if ui_roots:
        return any(_matches_prefix(rel_posix, ur) for ur in ui_roots)

    if ext in ALWAYS_UI_EXTS:
        return True
    if ext in (".html", ".htm"):
        return any(p in HTML_UI_SEGMENTS for p in low_parts)
    if any(p in CODE_UI_SEGMENTS for p in low_parts):
        return True
    low_name = parts[-1].lower()
    if low_name.endswith(".xaml.cs"):
        return True
    stem = Path(low_name).stem
    return any(stem.endswith(suf) for suf in UI_STEM_SUFFIXES)


def _preserve_newlines(text: str) -> str:
    return "".join("\n" if ch == "\n" else " " for ch in text)


def strip_comments(text: str, ext: str) -> str:
    """Replace comments with spaces while keeping newlines and string literals intact."""
    if ext in XAML_EXTS or ext in (".html", ".htm", ".vue", ".svelte"):
        return re.sub(r"<!--.*?-->", lambda m: _preserve_newlines(m.group(0)), text, flags=re.S)

    allow_line = ext != ".css"
    out: list[str] = []
    i = 0
    n = len(text)
    in_str: str | None = None
    in_verbatim = False
    while i < n:
        ch = text[i]
        nxt = text[i + 1] if i + 1 < n else ""
        if in_str:
            out.append(ch)
            if in_verbatim:
                if ch == '"' and nxt == '"':
                    out.append(nxt)
                    i += 2
                    continue
                if ch == '"':
                    in_str = None
                    in_verbatim = False
                i += 1
                continue
            if ch == "\\" and i + 1 < n:
                out.append(text[i + 1])
                i += 2
                continue
            if ch == in_str:
                in_str = None
            i += 1
            continue

        if ext in CS_EXTS and ch == "@" and nxt == '"':
            out.append('@"')
            in_str = '"'
            in_verbatim = True
            i += 2
            continue
        if ch in ('"', "'") or (ext in WEB_CODE_EXTS and ch == "`"):
            out.append(ch)
            in_str = ch
            i += 1
            continue
        if ch == "/" and nxt == "*":
            end = text.find("*/", i + 2)
            end = n if end == -1 else end + 2
            out.append(_preserve_newlines(text[i:end]))
            i = end
            continue
        if allow_line and ch == "/" and nxt == "/":
            end = text.find("\n", i + 2)
            end = n if end == -1 else end
            out.append(" " * (end - i))
            i = end
            continue
        out.append(ch)
        i += 1
    return "".join(out)


def _has_exemption(raw_lines: list[str], lineno: int, rule: str) -> bool:
    start = max(0, lineno - 4)
    for idx in range(start, lineno):
        ln = re.sub(r"(?:\*/|-->)\s*$", "", raw_lines[idx]).strip()
        if WORKAROUND_RE.search(ln):
            return True
        for m in ALLOW_RE.finditer(ln):
            allowed = {tok.strip().lower() for tok in m.group(1).split(",") if tok.strip()}
            if "all" in allowed or rule in allowed:
                return True
    return False


def _has_nonzero_number(expr: str) -> bool:
    nums = re.findall(
        r"(?<![A-Za-z0-9_$.])(?:[0-9]+(?:\.[0-9]+)?|\.[0-9]+)(?:[eE][+-]?[0-9]+)?"
        r"(?=(?:[fFdDmM]|px|rem|em|pt)?(?:[^A-Za-z0-9_]|$))",
        expr,
    )
    return any(float(v) != 0.0 for v in nums)


def _mask_urls_and_anchors(line: str) -> str:
    masked = URL_RE.sub(lambda m: " " * len(m.group(0)), line)
    return ANCHOR_RE.sub(lambda m: " " * len(m.group(0)), masked)


def _is_unquoted_html_attr(line: str, start: int) -> bool:
    j = start - 1
    while j >= 0 and line[j] in " \t":
        j -= 1
    while j >= 0:
        ch = line[j]
        if ch in "\"'`<>{}":
            return False
        if ch == "=":
            return True
        if ch.isspace():
            return False
        j -= 1
    return False


def _mask_css_custom_props(line: str, *, web: bool = False) -> str:
    n = len(line)
    out = list(line)
    pos = 0
    while pos < n:
        m = CUSTOM_PROP_START_RE.search(line, pos)
        if not m:
            break
        start = m.start()
        i = m.end()
        if web:
            unquoted_attr = _is_unquoted_html_attr(line, start)
            while i < n:
                ch = line[i]
                if ch in ";{}<>\"'`":
                    break
                if unquoted_attr and ch.isspace():
                    break
                i += 1
        else:
            quote: str | None = None
            escaped = False
            while i < n:
                ch = line[i]
                if quote is not None:
                    if escaped:
                        escaped = False
                    elif ch == "\\":
                        escaped = True
                    elif ch == quote:
                        quote = None
                    i += 1
                else:
                    if ch == "\\":
                        i = min(i + 2, n)
                    elif ch in "\"'":
                        quote = ch
                        i += 1
                    elif ch in ";{}":
                        break
                    else:
                        i += 1
        for k in range(start, i):
            out[k] = " "
        pos = max(i, m.end())
    return "".join(out)


def lint_content(rel_posix: str, raw_text: str, mode: str) -> list[dict]:
    if mode == "off":
        return []
    head = "\n".join(raw_text.splitlines()[:12])
    if GENERATED_RE.search(head):
        return []

    ext = Path(rel_posix).suffix.lower()
    raw_lines = raw_text.splitlines()
    clean_text = strip_comments(raw_text, ext)
    clean_lines = clean_text.splitlines()
    strict = mode == "strict"
    findings: list[dict] = []

    def add(lineno: int, rule: str, msg: str) -> None:
        if not _has_exemption(raw_lines, lineno, rule):
            findings.append({"file": rel_posix, "line": lineno, "rule": rule, "message": msg})

    if ext in XAML_EXTS:
        for idx, line in enumerate(clean_lines, 1):
            for m in XAML_HEX_ATTR_RE.finditer(line):
                add(idx, "color-literal", f"raw hex color literal {m.group(2)}")
            for m in XAML_NAMED_COLOR_RE.finditer(line):
                name = m.group(2).lower()
                if name in XAML_NAMED_COLORS and name not in XAML_SAFE_NAMED_COLORS:
                    add(idx, "color-literal", f"raw named color '{m.group(2)}'")
            if strict:
                if XAML_FONT_FAMILY_RE.search(line):
                    add(idx, "font-family-literal", "literal FontFamily instead of token resource")
                for m in XAML_FONT_SIZE_RE.finditer(line):
                    if float(m.group(2)) != 0.0:
                        add(idx, "font-size-literal", f"literal FontSize={m.group(2)}")
                for m in XAML_GEOM_ATTR_RE.finditer(line):
                    if _has_nonzero_number(m.group(2)):
                        add(idx, "spacing-radius-literal", f"literal geometry value '{m.group(2)}'")
                if EMOJI_RE.search(line):
                    add(idx, "emoji-icon", "emoji glyph used in UI source")
        return findings

    if ext in CS_EXTS:
        for idx, line in enumerate(clean_lines, 1):
            for m in CS_COLOR_API_RE.finditer(line):
                add(idx, "color-literal", f"raw color literal '{m.group(0).strip()}'")
            for m in CS_QUOTED_HEX_RE.finditer(line):
                add(idx, "color-literal", f"raw hex color literal {m.group(0)}")
            if strict:
                if CS_FONT_FAMILY_RE.search(line):
                    add(idx, "font-family-literal", "literal font family instead of design token")
                for m in CS_FONT_SIZE_RE.finditer(line):
                    if float(m.group(1)) != 0.0:
                        add(idx, "font-size-literal", f"literal FontSize={m.group(1)}")
                for m in CS_GEOM_CTOR_RE.finditer(line):
                    if _has_nonzero_number(m.group(1)):
                        add(idx, "spacing-radius-literal", f"literal Thickness/CornerRadius({m.group(1)})")
                for m in CS_GEOM_PROP_RE.finditer(line):
                    if float(m.group(1)) != 0.0:
                        add(idx, "spacing-radius-literal", f"literal spacing/radius={m.group(1)}")
                if EMOJI_RE.search(line):
                    add(idx, "emoji-icon", "emoji glyph used in UI source")
        return findings

    if ext in CPP_EXTS:
        for idx, line in enumerate(clean_lines, 1):
            for m in CPP_COLOR_RE.finditer(line):
                add(idx, "color-literal", f"raw native color '{m.group(0).strip()}'")
            masked = _mask_urls_and_anchors(line)
            for m in HEX_STR_RE.finditer(masked):
                if f'"{m.group(0)}"' in line or f"'{m.group(0)}'" in line:
                    add(idx, "color-literal", f"raw hex color literal {m.group(0)}")
            if strict:
                if CPP_FONT_RE.search(line):
                    add(idx, "font-family-literal", "literal font family instead of theme token")
                for m in CPP_FONT_SIZE_ASSIGN_RE.finditer(line):
                    if float(m.group(1)) != 0.0:
                        add(idx, "font-size-literal", f"literal font size {m.group(1)}")
                for m in CPP_GEOM_ASSIGN_RE.finditer(line):
                    if float(m.group(1)) != 0.0:
                        add(idx, "spacing-radius-literal", f"literal geometry value {m.group(1)}")
                if EMOJI_RE.search(line):
                    add(idx, "emoji-icon", "emoji glyph used in UI source")

        if strict:
            for m in CPP_TEXT_FORMAT_CALL_RE.finditer(clean_text):
                args = m.group(1).split(",")
                if len(args) >= 6:
                    sz = args[5].strip().rstrip("fF")
                    if re.fullmatch(r"[0-9]+(?:\.[0-9]+)?", sz) and float(sz) != 0.0:
                        lineno = clean_text.count("\n", 0, m.start()) + 1
                        add(lineno, "font-size-literal", f"literal CreateTextFormat size {args[5].strip()}")
            for m in CPP_ROUNDED_RECT_RE.finditer(clean_text):
                args = m.group(1).split(",")
                if len(args) >= 2 and any(_has_nonzero_number(a) for a in args[1:]):
                    lineno = clean_text.count("\n", 0, m.start()) + 1
                    add(lineno, "spacing-radius-literal", "literal D2D1::RoundedRect corner radius")
        return findings

    if ext in CSS_EXTS:
        for idx, line in enumerate(clean_lines, 1):
            if CSS_CUSTOM_PROP_DEF_RE.match(line):
                continue
            css_line = _mask_css_custom_props(line)
            masked = _mask_urls_and_anchors(css_line)
            for m in HEX_STR_RE.finditer(masked):
                add(idx, "color-literal", f"raw hex color {m.group(0)}")
            for m in CSS_FUNC_COLOR_RE.finditer(css_line):
                if "var(" not in m.group(1).lower():
                    add(idx, "color-literal", f"raw functional color '{m.group(0)}'")
            if strict:
                if CSS_FONT_FAMILY_RE.search(css_line):
                    add(idx, "font-family-literal", "literal font-family instead of var(--...)")
                m_fs = CSS_FONT_SIZE_RE.search(css_line)
                if m_fs and re.search(r"[1-9][0-9.]*\s*(?:px|rem|em|pt)\b", m_fs.group(1), re.I):
                    add(idx, "font-size-literal", f"literal font-size '{m_fs.group(1).strip()}'")
                for m_sp in CSS_SPACING_PROP_RE.finditer(css_line):
                    val = re.sub(r"var\([^)]*\)", "", m_sp.group(1))
                    if re.search(r"[1-9][0-9.]*\s*(?:px|rem|em)\b", val, re.I):
                        add(idx, "spacing-radius-literal", f"literal spacing/radius '{m_sp.group(1).strip()}'")
                if EMOJI_RE.search(line):
                    add(idx, "emoji-icon", "emoji glyph used in CSS")
        return findings

    # Web TSX / JSX / TS / JS / HTML / Vue / Svelte
    for idx, line in enumerate(clean_lines, 1):
        if CSS_CUSTOM_PROP_DEF_RE.match(line):
            continue
        css_line = _mask_css_custom_props(line, web=True)
        masked = _mask_urls_and_anchors(css_line)
        for m in HEX_STR_RE.finditer(masked):
            add(idx, "color-literal", f"raw hex color {m.group(0)}")
        for m in CSS_FUNC_COLOR_RE.finditer(masked):
            if "var(" not in m.group(1).lower():
                add(idx, "color-literal", f"raw functional color '{m.group(0)}'")
        if strict:
            if CSS_FONT_FAMILY_RE.search(css_line) or JS_FONT_FAMILY_RE.search(line):
                add(idx, "font-family-literal", "literal font-family instead of token")
            m_cfs = CSS_FONT_SIZE_RE.search(css_line)
            if m_cfs and re.search(r"[1-9][0-9.]*\s*(?:px|rem|em|pt)\b", m_cfs.group(1), re.I):
                add(idx, "font-size-literal", f"literal font-size '{m_cfs.group(1).strip()}'")
            m_jfs = JS_FONT_SIZE_RE.search(line)
            if m_jfs:
                num = m_jfs.group(1) or m_jfs.group(3)
                if _has_nonzero_number(num):
                    add(idx, "font-size-literal", f"literal fontSize '{num}'")
            for m_sp in CSS_SPACING_PROP_RE.finditer(css_line):
                val = re.sub(r"var\([^)]*\)", "", m_sp.group(1))
                if re.search(r"[1-9][0-9.]*\s*(?:px|rem|em)\b", val, re.I):
                    add(idx, "spacing-radius-literal", f"literal spacing/radius '{m_sp.group(1).strip()}'")
            for m_jsp in JS_SPACING_PROP_RE.finditer(line):
                val = m_jsp.group(1) or m_jsp.group(3)
                if val and "var(" not in val and _has_nonzero_number(val):
                    add(idx, "spacing-radius-literal", f"literal spacing/radius '{val}'")
            if EMOJI_RE.search(line):
                add(idx, "emoji-icon", "emoji glyph used in UI source")
    return findings


def _git(root: Path, *args: str, binary: bool = False) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["git", *args],
        cwd=str(root),
        stdin=subprocess.DEVNULL,
        capture_output=True,
        text=not binary,
        encoding=None if binary else "utf-8",
        errors=None if binary else "replace",
        creationflags=CREATION_FLAGS,
        timeout=30,
    )


def _index_paths(root: Path) -> set[str]:
    listed = _git(root, "ls-files", "-z", binary=True)
    if listed.returncode != 0:
        raise ConfigError(f"git ls-files failed: {listed.stderr.decode('utf-8', 'replace').strip()}")
    return {p.decode("utf-8", "replace") for p in listed.stdout.split(b"\x00") if p}


def _read_index_text(root: Path, rel: str) -> str:
    shown = _git(root, "show", f":{rel}", binary=True)
    if shown.returncode != 0:
        raise ConfigError(f"cannot read staged :{rel}: {shown.stderr.decode('utf-8', 'replace').strip()}")
    return shown.stdout.decode("utf-8", "replace")


def _staged_ui_entries(root: Path, cfg: dict) -> tuple[list[str], dict[str, str]]:
    listed = _git(root, "diff", "--cached", "--name-only", "-z", "--diff-filter=ACMR", binary=True)
    if listed.returncode != 0:
        raise ConfigError(f"git diff --cached failed: {listed.stderr.decode('utf-8', 'replace').strip()}")
    changed_rels = [p.decode("utf-8", "replace") for p in listed.stdout.split(b"\x00") if p]
    targets: dict[str, str] = {}
    for rel in sorted(changed_rels):
        if not is_candidate_ui_file(rel, cfg):
            continue
        shown = _git(root, "show", f":{rel}", binary=True)
        if shown.returncode != 0:
            continue
        targets[rel] = shown.stdout.decode("utf-8", "replace")
    return changed_rels, targets


def _parse_baseline(raw_text: str, label: str) -> dict:
    try:
        data = json.loads(raw_text)
    except ValueError as exc:
        raise ConfigError(f"baseline {label} is not valid JSON: {exc}") from exc
    if not isinstance(data, dict) or data.get("schema_version") != 1 or not isinstance(data.get("counts"), dict):
        raise ConfigError(f"baseline {label} must have schema_version: 1 and counts object")
    if "history" in data and not isinstance(data["history"], list):
        raise ConfigError(f"baseline {label}: history must be a list")
    return data


def _load_baseline_disk(path: Path) -> dict | None:
    if not path.is_file():
        return None
    return _parse_baseline(path.read_text(encoding="utf-8"), path.as_posix())


def _load_baseline_git(root: Path, rev: str, baseline_rel: str) -> dict | None:
    check_rev = _git(root, "rev-parse", "--verify", "--quiet", f"{rev}^{{commit}}")
    if check_rev.returncode != 0:
        raise ConfigError(f"--base {rev!r} does not resolve to a commit")
    shown = _git(root, "show", f"{rev}:{baseline_rel}")
    if shown.returncode != 0:
        return None
    return _parse_baseline(shown.stdout, f"{rev}:{baseline_rel}")


def _counts_from_findings(findings: list[dict]) -> dict[str, dict[str, int]]:
    grouped: dict[str, dict[str, int]] = defaultdict(lambda: defaultdict(int))
    for item in findings:
        grouped[item["file"]][item["rule"]] += 1
    return {f: dict(sorted(rules.items())) for f, rules in sorted(grouped.items())}


def _baseline_growth(prev_counts: dict, cur_counts: dict) -> list[tuple[str, str, int, int]]:
    grew: list[tuple[str, str, int, int]] = []
    for f, rules in sorted(cur_counts.items()):
        prev_rules = prev_counts.get(f, {}) if isinstance(prev_counts.get(f), dict) else {}
        for rule, cur_n in sorted(rules.items()):
            prev_n = int(prev_rules.get(rule, 0))
            if int(cur_n) > prev_n:
                grew.append((f, rule, prev_n, int(cur_n)))
    return grew


def _verify_baseline_vs_base(cur_data: dict | None, prev_data: dict | None, base_label: str) -> list[str]:
    if cur_data is None:
        return []
    prev_counts = prev_data["counts"] if prev_data else {}
    grew = _baseline_growth(prev_counts, cur_data["counts"])
    if not grew:
        return []
    prev_hist = len((prev_data or {}).get("history") or [])
    cur_hist = cur_data.get("history") or []
    new_entries = cur_hist[prev_hist:]
    valid_reason = any(isinstance(e, dict) and isinstance(e.get("reason"), str) and e["reason"].strip() for e in new_entries)
    if valid_reason:
        return []
    return [
        f"baseline count grew vs {base_label} without a history reason entry: {f} {r} ({p} -> {c})"
        for f, r, p, c in grew
    ]


def _is_pruned_dir(rel_dir_posix: str, dir_name: str, cfg: dict) -> bool:
    low = dir_name.lower()
    if low in SKIP_DIR_NAMES or low.startswith("cmake-build-") or dir_name.startswith("."):
        return True
    for exc in cfg["exclude"]:
        if _matches_prefix(rel_dir_posix, exc):
            return True
    for pref in DEFAULT_EXCLUDE_PREFIXES:
        if _matches_prefix(rel_dir_posix, pref):
            return True
    return False


def _gather_worktree_files(root: Path, cfg: dict) -> dict[str, str]:
    files: dict[str, str] = {}
    start_roots = [root / ur for ur in cfg["ui_roots"]] if cfg["ui_roots"] else [root]
    for start in start_roots:
        if not start.is_dir() or start.is_symlink():
            continue
        for cur, dirs, filenames in os.walk(start):
            cur_path = Path(cur)
            rel_cur = cur_path.relative_to(root).as_posix() if cur_path != root else ""
            kept_dirs = []
            for d in sorted(dirs):
                if (cur_path / d).is_symlink():
                    continue
                rel_child = f"{rel_cur}/{d}" if rel_cur else d
                if not _is_pruned_dir(rel_child, d, cfg):
                    kept_dirs.append(d)
            dirs[:] = kept_dirs
            for fn in sorted(filenames):
                rel = f"{rel_cur}/{fn}" if rel_cur else fn
                if is_candidate_ui_file(rel, cfg):
                    files[rel] = (cur_path / fn).read_text(encoding="utf-8", errors="replace")
    return files


def _self_test() -> int:
    with tempfile.TemporaryDirectory() as td:
        root = Path(td)
        (root / "DESIGN.md").write_text("# Self-test\n", encoding="utf-8")
        ui = root / "src/ui"
        ui.mkdir(parents=True)
        bad = ui / "bad.css"
        bad.write_text(".x { color: #123456; }\n", encoding="utf-8")
        cfg = resolve_config(root)
        assert cfg["mode"] == "strict"
        assert len(lint_content("src/ui/bad.css", bad.read_text(encoding="utf-8"), "strict")) == 1
        good = ".x { color: var(--ink); }\n"
        assert len(lint_content("src/ui/bad.css", good, "strict")) == 0
    print("design-lint self-test: ok")
    return 0


def run(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Two-tier static design token and theme linter.")
    parser.add_argument("--baseline", default=None, help=f"Baseline JSON path (default: {DEFAULT_BASELINE})")
    parser.add_argument("--update-baseline", action="store_true", help="Write or shrink the baseline file")
    parser.add_argument("--allow-add", action="store_true", help="Allow baseline counts to grow when updating")
    parser.add_argument("--reason", default="", help="Required reason when --allow-add grows the baseline")
    parser.add_argument("--base", default=None, help="Git revision to verify baseline did not grow unapproved")
    parser.add_argument("--staged", action="store_true", help="Lint only staged git index files")
    parser.add_argument("--summary", action="store_true", help="Print violation counts by rule")
    parser.add_argument("--self-test", action="store_true", help="Run built-in smoke checks")
    args = parser.parse_args(argv)

    if args.self_test:
        return _self_test()

    if args.allow_add and not args.reason.strip():
        print("design-lint: --allow-add requires a non-empty --reason", file=sys.stderr)
        return 2

    root = Path.cwd().resolve()
    try:
        cfg = resolve_config(root, staged=args.staged)
    except ConfigError as exc:
        print(f"design-lint: {exc}", file=sys.stderr)
        return 2

    if cfg["mode"] == "off":
        return 0

    baseline_rel = _clean_rel(args.baseline or cfg["baseline"])
    baseline_path = root / baseline_rel

    try:
        if args.staged:
            index_set = _index_paths(root)
            baseline_data = _parse_baseline(_read_index_text(root, baseline_rel), f":{baseline_rel}") if baseline_rel in index_set else None
        else:
            baseline_data = _load_baseline_disk(baseline_path)
    except ConfigError as exc:
        print(f"design-lint: {exc}", file=sys.stderr)
        return 2

    changed_rels: list[str] = []
    if args.staged:
        try:
            changed_rels, targets = _staged_ui_entries(root, cfg)
        except ConfigError as exc:
            print(f"design-lint: {exc}", file=sys.stderr)
            return 2

    if args.base:
        try:
            prev_data = _load_baseline_git(root, args.base, baseline_rel)
        except ConfigError as exc:
            print(f"design-lint: {exc}", file=sys.stderr)
            return 2
        growth_faults = _verify_baseline_vs_base(baseline_data, prev_data, args.base)
        if growth_faults:
            for msg in growth_faults:
                print(msg)
            return 1
    elif args.staged and baseline_rel in changed_rels:
        head_check = _git(root, "rev-parse", "--verify", "--quiet", "HEAD^{commit}")
        if head_check.returncode == 0:
            try:
                prev_data = _load_baseline_git(root, "HEAD", baseline_rel)
            except ConfigError as exc:
                print(f"design-lint: {exc}", file=sys.stderr)
                return 2
            growth_faults = _verify_baseline_vs_base(baseline_data, prev_data, "HEAD")
            if growth_faults:
                for msg in growth_faults:
                    print(msg)
                return 1

    if not args.staged:
        targets = _gather_worktree_files(root, cfg)

    all_findings: list[dict] = []
    for rel, text in sorted(targets.items()):
        all_findings.extend(lint_content(rel, text, cfg["mode"]))

    if args.update_baseline:
        if args.staged:
            print("design-lint: --update-baseline cannot be combined with --staged", file=sys.stderr)
            return 2
        new_counts = _counts_from_findings(all_findings)
        old_counts = baseline_data["counts"] if baseline_data else {}
        grew = _baseline_growth(old_counts, new_counts)
        if grew and not (args.allow_add and args.reason.strip()):
            for f, r, p, c in grew:
                print(f"design-lint: refusing baseline growth for {f} {r} ({p} -> {c}); pass --allow-add --reason")
            return 1
        history = list((baseline_data or {}).get("history") or [])
        if grew:
            history.append({
                "at": _utc_now(),
                "reason": args.reason.strip(),
                "added": {f"{f}:{r}": c - p for f, r, p, c in grew},
            })
        doc = {"schema_version": 1, "counts": new_counts, "history": history}
        _atomic_write_text(baseline_path, json.dumps(doc, indent=2) + "\n")
        return 0

    if args.summary:
        counts_by_rule: dict[str, int] = defaultdict(int)
        for item in all_findings:
            counts_by_rule[item["rule"]] += 1
        for rule in ALL_RULES:
            if counts_by_rule[rule]:
                print(f"{rule}: {counts_by_rule[rule]}")
        return 0

    base_counts = baseline_data["counts"] if baseline_data else {}
    grouped: dict[tuple[str, str], list[dict]] = defaultdict(list)
    for item in all_findings:
        grouped[(item["file"], item["rule"])].append(item)

    failures: list[dict] = []
    for (rel, rule), items in sorted(grouped.items()):
        allowed = 0
        if isinstance(base_counts.get(rel), dict):
            allowed = int(base_counts[rel].get(rule, 0))
        if len(items) > allowed:
            failures.extend(items[allowed:])

    if failures:
        for item in failures:
            print(f"{item['file']}:{item['line']}:{item['rule']}:{item['message']}")
        return 1
    return 0


def main() -> int:
    return run()


if __name__ == "__main__":
    sys.exit(main())
