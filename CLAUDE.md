# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Educational content for GDG on Campus University of Osaka. The repo produces two kinds of artifacts:

1. **Claat codelabs** — markdown → static HTML site, published to GitHub Pages at `https://gdsc-osaka.github.io/education/<codelab-dir>`. Each codelab lives in its own directory (`portfolio-2025/`, `portfolio-2026/`, `vibe-coding-hands-on/`, `first-portfolio-workshop-2hr-nogit/`).
2. **Marp slide decks** — markdown → HTML/PDF presentations.

Source markdown lives at the repo root or under `web/`.

## Build commands

Both build flows go through the root `Makefile` and use positional args (not `KEY=value` style):

```bash
# Export a claat codelab (the output directory is fully replaced)
make claat path/to/source.md path/to/output-dir

# Render a Marp deck (HTML output defaults to <input>.html)
make slide path/to/deck.md [path/to/deck.html]
```

For PDFs, invoke Marp CLI directly: `npx -p @marp-team/marp-cli@latest marp --theme-set .marp/gdg.css --html source.md -o source.pdf`.

## Claat export pipeline (important)

`make claat` is not a plain `claat export`. It runs these steps in order:

1. `claat export` into a temp directory (claat forces the output directory name to match the `id` field in `codelab.json`, so a temp dir + rename is needed to get a stable output name).
2. Move the exported directory to the requested path.
3. Copy `portfolio-2025/libs` (overridable via `LIBS_SRC`) into the output and rewrite `https://storage.googleapis.com/claat-public/` references to relative `libs/`. This switches from Google-hosted codelab-elements assets to the local copy.
4. Run `.claat/fix-claat-codespans.py` against the generated `index.html`.

The postfix script (`.claat/fix-claat-codespans.py`) fixes two claat-output issues:

- Escapes raw HTML tags inside inline `<code>` spans (`<code><html></code>` → `<code>&lt;html&gt;</code>`). Without escaping, the browser parses them as real `<html>`/`<body>` tags and breaks the document.
- Re-wraps `<p><strong>Note:</strong>...</p>`-style paragraphs in `<aside class="warning">` / `<aside class="special">` to restore styled callout boxes. Recognized keywords: `Note`, `Notice`, `Tip`, `Tips`, `Hint`, `補足`, `Warning`, `Warn`, `Caution`, `Troubleshooting`. Add new keywords by editing the `ASIDE_KEYWORDS` dict.

A new codelab directory needs its own `libs/` or must override `LIBS_SRC` (the default reuses `portfolio-2025/libs`).

## Marp setup

- Shared theme is `.marp/gdg.css` (registered as `gdg`). The VSCode Marp extension also loads it automatically (configured in `.vscode/settings.json`).
- Slide sources need `---\nmarp: true\ntheme: gdg\n---` frontmatter. `.marp/template.md` shows the available layout classes (`title`, `lead`, `section`, `section yellow`, `section green`, `split`, `invert`).

## Repository conventions

- `.gitignore` only excludes `.kiri` (Kiri MCP workspace cache). Generated `index.html` / `libs/` directories and PDFs are committed (they are served via GitHub Pages).
- Markdown under `web/` is older content (pre-2025). The current convention for new workshops is `<topic>-<year>.md` at the root, exported into a sibling `<topic>-<year>/` directory.
