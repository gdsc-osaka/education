#!/usr/bin/env python3
"""Post-process claat-exported index.html files.

Two fixes are applied:

1. Escape unescaped HTML tags inside inline <code>...</code> spans. claat's
   markdown renderer leaves backtick spans like `<html>` as
   `<code><html></code>`, which the browser parses as real <html>/<body>/<head>
   tags and breaks the document. We rewrite them to `<code>&lt;html&gt;</code>`.

2. Wrap blockquote-style note paragraphs in <aside class="..."> boxes. Older
   claat versions converted `> **Note:** ...` markdown into
   `<aside class="note">...</aside>`; the current version emits a plain <p>,
   so the styled callout box is lost. We re-wrap any
   `<p><strong>Keyword:</strong>...</p>` whose keyword matches a known callout
   label, including an immediately following <ul>/<ol> list when present.
"""

import re
import sys

ASIDE_KEYWORDS = {
    "Note": "warning",
    "Notice": "warning",
    "Tip": "special",
    "Tips": "special",
    "Hint": "special",
    "補足": "special",
    "Warning": "warning",
    "Warn": "warning",
    "Caution": "warning",
    "Troubleshooting": "warning",
}


def escape_codespans(html: str) -> tuple[str, int]:
    pattern = re.compile(r"<code>([^<>]*<[^<]*?)</code>")

    def escape(m: re.Match) -> str:
        inner = m.group(1)
        inner = inner.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
        return f"<code>{inner}</code>"

    total = 0
    while True:
        html, n = pattern.subn(escape, html)
        if n == 0:
            return html, total
        total += n


def wrap_asides(html: str) -> tuple[str, int]:
    keys = "|".join(re.escape(k) for k in ASIDE_KEYWORDS)
    # <p><strong>Keyword:</strong>...</p> optionally followed by a single <ul>/<ol> block
    pattern = re.compile(
        r"<p><strong>(?P<kw>" + keys + r"):?</strong>"
        r"(?P<body>.*?)</p>"
        r"(?P<list>\s*<(?P<lt>ul|ol)[^>]*>.*?</(?P=lt)>)?",
        re.DOTALL,
    )

    def repl(m: re.Match) -> str:
        klass = ASIDE_KEYWORDS[m.group("kw")]
        return f'<aside class="{klass}">{m.group(0)}</aside>'

    return pattern.subn(repl, html)


def fix(html: str) -> tuple[str, int, int]:
    html, n_code = escape_codespans(html)
    html, n_aside = wrap_asides(html)
    return html, n_code, n_aside


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: fix-claat-codespans.py <html-file>...", file=sys.stderr)
        return 2
    for path in sys.argv[1:]:
        with open(path, encoding="utf-8") as f:
            original = f.read()
        fixed, n_code, n_aside = fix(original)
        if n_code or n_aside:
            with open(path, "w", encoding="utf-8") as f:
                f.write(fixed)
        print(f"{path}: fixed {n_code} code spans, wrapped {n_aside} asides")
    return 0


if __name__ == "__main__":
    sys.exit(main())
