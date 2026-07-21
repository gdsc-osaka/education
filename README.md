# GDGoC Osaka Codelabs

Educational content for GDG on Campus University of Osaka. Sources are markdown; outputs are static HTML hosted on GitHub Pages.

Published codelabs:

- [ポートフォリオ Web サイト Workshop 2025](https://gdsc-osaka.github.io/education/portfolio-2025/)
- [ポートフォリオ Web サイト Workshop 2026](https://gdsc-osaka.github.io/education/portfolio-2026/)
- [ポートフォリオ Web サイト Workshop 2026 スライド](https://gdsc-osaka.github.io/education/portfolio-2026/slide/)
- [Vibe coding hands-on](https://gdsc-osaka.github.io/education/vibe-coding-hands-on/)
- [Web アプリ チーム開発 はじめの一歩](https://gdsc-osaka.github.io/education/team-dev-onboarding/)
- [Web アプリ チーム開発 スライド](https://gdsc-osaka.github.io/education/team-dev-onboarding/slide/)
- [AI と Flutter で スマホアプリを作ろう スライド](https://gdsc-osaka.github.io/education/flutter-workshop/slide/)

## Setup

Install the latest [gdg-jp claat fork](https://github.com/gdg-jp/tools/tree/main/claat)
with Go:

```bash
go install github.com/gdg-jp/tools/claat@latest
```

Prebuilt Windows, macOS, and Linux binaries are available on the
[gdg-jp/tools Releases page](https://github.com/gdg-jp/tools/releases/latest).

Marp CLI runs via `npx` and needs no install. Building codelabs requires only
the forked `claat` binary; Python and POSIX-specific `sed`/`cp` commands are not used.

On Windows, the Makefile wrapper is optional:

```powershell
claat build portfolio-2026
```

## Build commands

```bash
# Export a claat codelab (<content-name>/claat.md → <content-name>/)
make claat <content-name>

# Render a Marp deck (<content-name>/slide.md → <content-name>/slide/index.html)
make slide <content-name>
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

- `.claat.json` — configuration read by the gdg-jp claat fork for the public URL, favicon, bundled assets, and root resource index.
- `.marp/gdg.css` — shared Marp theme (registered as `gdg`). See `.marp/template.md` for the available layout classes.
- `web/` — legacy 2025 content; new workshops should follow the directory structure above.
