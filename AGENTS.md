# Repository Guidelines

## Project Structure & Module Organization

This repository contains workshop content generated from Markdown for GitHub Pages.

- `<content-name>/claat.md`: codelab source for Google Claat.
- `<content-name>/slide.md`: Marp slide source.
- `<content-name>/index.html`, `libs/`, `slide/index.html`, and PDFs: committed outputs.
- `.claat/fix-claat-codespans.py`: codelab post-processor.
- `.marp/gdg.css`: shared Marp theme; see `.marp/template.md` for layouts.
- `assets/`: shared fonts and visual assets.
- `team-dev-onboarding/example/`: React/Vite sample app.
- `flutter-workshop/examples/reading_note/`: Flutter sample app; tests live in `test/`.
- `web/` and older folders are legacy content; avoid renames because URLs depend on them.

## Build, Test, and Development Commands

Run builds from the repository root:

```bash
make claat portfolio-2026/claat.md portfolio-2026
make slide portfolio-2026/slide.md portfolio-2026/slide/index.html
make slide-pdf portfolio-2026/slide.md portfolio-2026/slide.pdf
```

`make claat` exports, copies local `libs/`, rewrites asset URLs, and runs the post-processor. Slide targets use Marp with `.marp/gdg.css`.

React example:

```bash
cd team-dev-onboarding/example
npm install
npm run dev
npm run build
npm run lint
```

Flutter example:

```bash
cd flutter-workshop/examples/reading_note
flutter pub get
flutter analyze
flutter test
flutter run
```

## Coding Style & Naming Conventions

Use lowercase kebab-case for workshop directories, for example `portfolio-2026`. New workshops should use the standard `claat.md`, `slide.md`, `img/`, and generated output layout.

Edit Markdown sources first; update generated HTML through the Makefile. Marp slides need `marp: true` and `theme: gdg`. React uses the existing Vite/ES module style and ESLint config. Flutter uses `flutter_lints`; run `dart format .` before committing Dart changes.

## Testing Guidelines

There is no repository-wide test suite. Verify the changed area:

- Codelabs: rebuild with `make claat ...` and inspect the generated `index.html`.
- Slides: rebuild with `make slide ...` or `make slide-pdf ...` and check the rendered output.
- React example: run `npm run lint` and `npm run build`.
- Flutter example: run `flutter analyze` and `flutter test`; name tests with `_test.dart`.

## Commit & Pull Request Guidelines

Recent commits use short, imperative summaries such as `update README.md and marp slide template`. Keep commits focused and include generated artifacts when intentionally updated.

Pull requests should include a description, affected paths, commands run, and screenshots or links for visual changes. Link issues when available. Do not remove generated files unless the page is being retired.

## Security & Configuration Tips

Preserve published URLs and legacy names. Avoid broad cleanup in generated HTML or vendored `libs/` unless the build produced it. For new codelabs, ensure compatible `libs/` handling or pass `LIBS_SRC`.
