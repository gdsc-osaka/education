# GDGoC Osaka Codelabs

Educational content for GDG on Campus University of Osaka. Sources are markdown; outputs are static HTML hosted on GitHub Pages.

Published codelabs:

- [ポートフォリオ Web サイト Workshop 2025](https://gdsc-osaka.github.io/education/portfolio-2025)
- [Vibe coding hands-on](https://gdsc-osaka.github.io/education/vibe-coding-hands-on)

## Setup

Install [claat](https://github.com/googlecodelabs/tools/tree/main/claat) (requires Go):

```bash
go install github.com/googlecodelabs/tools/claat@latest
```

Marp CLI runs via `npx` and needs no install. Python 3 is required for the claat post-processor.

## Build commands

```bash
# Export a claat codelab to a directory (the directory is fully replaced)
make claat <content-name>/claat.md <content-name>

# Render a Marp deck to HTML (HTML output defaults to <input>.html)
make slide <content-name>/slide.md <content-name>/slide/index.html
```

For PDFs, invoke Marp directly:

```bash
npx -p @marp-team/marp-cli@latest marp --theme-set .marp/gdg.css --html <content-name>/slide.md -o <content-name>/slide.pdf
```

## Directory structure

Each piece of content lives in its own directory:

```
<content-name>/
  claat.md          # Codelab source (markdown)
  slide.md          # Marp slide source (markdown)
  index.html        # Generated codelab site (committed)
  slide/index.html  # Generated slide site (committed)
  libs/             # codelab-elements assets (committed)
  img/              # images referenced from claat.md / slide.md
```

Generated `index.html`, `libs/`, and slide HTML/PDFs are committed because GitHub Pages serves them directly.

## Other directories

- `.claat/fix-claat-codespans.py` — post-processor that escapes raw HTML inside inline `<code>` spans and re-wraps `Note:` / `Tip:` paragraphs as `<aside>` callouts. Run automatically by `make claat`.
- `.marp/gdg.css` — shared Marp theme (registered as `gdg`). See `.marp/template.md` for the available layout classes.
- `web/` — legacy 2025 content; new workshops should follow the directory structure above.
