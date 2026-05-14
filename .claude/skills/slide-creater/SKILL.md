---
name: slide-creater
description: Use this skill whenever the user asks to create slides, a slide deck, a presentation, a talk, 発表資料, スライド, or anything that will become a Marp deck in this repository. Explains the project-specific Marp template at `.marp/template.md` — its frontmatter, slide classes (`title` / `lead` / `section` / `split` / `invert`), CSS variables, layout patterns, and build pipeline — so new decks match the conventions GDG on Campus University of Osaka already uses. Trigger this skill even when the user just says "make slides" or "create a deck" without mentioning Marp; in this repo, slides always mean Marp + this template.
---

# slide-creater

This repo has a custom Marp template at `.marp/template.md` with bespoke CSS in `.marp/gdg.css`. New slide decks should start from that template so they match the GDG visual style. This skill explains how the template works — **not Marp in general**. Assume the user knows Marp basics; the value here is the project-specific conventions.

## When you're asked to create slides

1. Decide the destination directory using the convention in `CLAUDE.md`:
   ```
   <content-name>/slide.md            ← source
   <content-name>/slide/index.html    ← built output (committed)
   <content-name>/img/                ← images referenced from slide.md
   ```
2. Copy `.marp/template.md` to `<content-name>/slide.md` as the starting point. Don't write the frontmatter or the `.fit` `<script>` block from scratch — both are load-bearing and easy to break.
3. Replace the example slides with the user's content, picking slide types from the catalog below.
4. Build with `make slide <content-name>/slide.md <content-name>/slide/index.html`.
5. For PDFs: `npx -p @marp-team/marp-cli@latest marp --theme-set .marp/gdg.css --html <content-name>/slide.md -o <content-name>/slide.pdf`.

## What's in the template you must keep

### Frontmatter

```yaml
---
marp: true
theme: gdg
paginate: true
size: 16:9
---
```

`theme: gdg` is the registered name for `.marp/gdg.css`. Without it, none of the classes below will style correctly.

### The `.fit` shrink-to-fit script

The template embeds a `<script>` block right after the frontmatter. It scales any element wrapped in `<div class="fit">…</div>` down so overflowing content fits on the slide (PowerPoint-style auto-shrink). Keep the script as-is. Use it like this when content might overflow:

```markdown
## Auto-fit overflowing content

<div class="fit">

- Paste long bullet lists without manually trimming
- Drop in verbose code samples
- The element must be a direct child of `section` for height to resolve

</div>
```

The `.fit` div has to be a direct child of `section` — don't nest it inside another wrapper.

## Slide type catalog

Pick a class by setting `<!-- _class: <name> -->` at the top of a slide. `_class` (with underscore) applies to that slide only; `class` without underscore applies to all following slides.

### 1. Title slide — `_class: title`

The deck's cover. Big title, subtitle, and metadata.

```markdown
<!-- _class: title -->

# Google Developer Group
## Marp Presentation Template

GDG on Campus University of Osaka
2026-04-28
```

### 2. Lead slide — `_class: lead`

Centered, oversized heading. Use for intermediate "welcome" beats, the closing "Thank you!" slide, and dedicated quote slides.

```markdown
<!-- _class: lead -->

# Welcome to GDG
```

### 3. Section divider — `_class: section`

Chapter break with a colored full-bleed background. Variants: bare `section` (blue/default), `section yellow`, `section green`, `section red`. Yellow uses dark ink for contrast — picked automatically.

```markdown
<!-- _class: section yellow -->

# 02. What we build
```

### 4. Default slide — no class

Heading + body. The normal case. Markdown lists, paragraphs, and tables all work without any class.

### 5. Two-column / split — `_class: split`

Two-column grid (CSS grid, `1fr 1fr`). The `h1`/`h2` spans both columns; everything after is placed into columns in source order.

```markdown
<!-- _class: split -->

## Two-column layout

### Left column
- bullet
- bullet

### Right column
- bullet
- bullet
```

### 6 & 7. Image + text — also `_class: split`

The template uses `split` for both "left image + right text" and "right image + left text". Position is controlled by **source order**, not a different class:

- Image first → image on the left
- Text first → image on the right

```markdown
<!-- _class: split -->

## Left image + right text

![w:480](assets/gdg_logo.png)

- bullets land in the right column
```

Use `![w:480]` (or similar) to constrain the image to the column width.

### 8. Full-bleed image

Marp's `bg` directive. No class needed for the slide itself, but combine with `_class: invert` if you put light text on a dark image.

```markdown
![bg cover](path/to/image.jpg)

<!-- _class: invert -->

## Caption text
```

Modifiers: `bg`, `bg fit`, `bg cover`, `bg left`, `bg right`.

### 9. Quote slide — `_class: lead` + blockquote

There's no dedicated quote class. Use `lead` for a single centered quote:

```markdown
<!-- _class: lead -->

> "The best way to predict the future is to invent it."
>
> — *Alan Kay*
```

### 10. Code slide — default + fenced block

`section.invert blockquote` and `section.invert code` are styled for dark slides, so combine with `_class: invert` for code-heavy slides:

````markdown
<!-- _class: invert -->

## Dark slide

```ts
const client = new Anthropic();
```
````

### 11. Table slide — default + Markdown table

Normal Markdown tables work; no class needed.

### 12. Diagram / flow — inline HTML

No `card` or `flow` CSS class exists. Use inline HTML with the project's CSS variables (see below) for color consistency:

```html
<div style="display: flex; align-items: center; justify-content: center; gap: 24px;">
  <div style="padding: 24px 32px; border: 2px solid var(--gdg-blue); border-radius: 12px;">Idea</div>
  <div style="font-size: 40px; color: var(--gdg-blue);">→</div>
  <div style="padding: 24px 32px; border: 2px solid var(--gdg-green); border-radius: 12px;">Build</div>
</div>
```

Mermaid is **not** wired up — render Mermaid externally and embed the resulting image, or use inline SVG/HTML.

### 13. Chart / graph — inline SVG

No chart library. Use inline `<svg>` with the project colors, or embed a pre-rendered image:

```html
<svg viewBox="0 0 600 280" style="width: 100%; height: 280px;">
  <rect x="100" y="160" width="60" height="80" fill="var(--gdg-blue)"/>
  …
</svg>
```

### 14. Takeaways / summary — inline HTML card grid

Card-style layout via CSS grid. Match top-border colors to GDG palette:

```html
<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px;">
  <div style="padding: 24px; border-top: 4px solid var(--gdg-blue); background: #F8F9FA; border-radius: 8px;">
    <h3>Community</h3>
    <p>GDG is global, local, and open to everyone.</p>
  </div>
  …
</div>
```

### 15. Closing — `_class: lead`

Same class as the welcome lead. Typically `# Thank you!` + a "Questions?" line.

## Available CSS variables

Defined in `.marp/gdg.css`. Use these instead of hardcoding hex codes so the deck stays on-brand:

| Variable          | Value     | Typical use                       |
| ----------------- | --------- | --------------------------------- |
| `--gdg-blue`      | `#4285F4` | primary accent, default section   |
| `--gdg-red`       | `#EA4335` | section red, alerts               |
| `--gdg-yellow`    | `#FBBC04` | section yellow, highlights        |
| `--gdg-green`     | `#34A853` | section green, success            |
| `--gdg-ink`       | `#1A1A1A` | dark text (used on yellow bgs)    |

## Assets you can reuse

- `.marp/assets/gdg_logo.png` — official logo. Reference as `assets/gdg_logo.png` from `.marp/template.md`'s own location, or copy into `<content-name>/img/` and reference as `img/gdg_logo.png` from `<content-name>/slide.md`.
- `.marp/assets/GoogleSans-Variable.ttf` / `GoogleSans-Italic-Variable.ttf` — bundled fonts already loaded by `gdg.css`.

## Things that will surprise you

- **`title` vs `lead`**: the cover uses `title`, not `lead`. `lead` is for intermediate big-text slides like "Welcome", quotes, and "Thank you!".
- **No `card`, `quote`, `flow`, or `chart` classes**: build those with inline HTML and CSS variables. Don't invent new `_class` names unless you also add CSS to `gdg.css`.
- **`split` heading spans both columns**: the `h1`/`h2` is set to `grid-column: 1 / -1` in CSS. Don't try to put it inside a column.
- **`.fit` must be a direct child of `section`**: nesting it inside another `<div>` breaks the height calculation and the shrink does nothing.
- **Images in `split`**: column width is ~half the slide. Use explicit `![w:480]` or similar — large images otherwise overflow.

## Building

From the project root:

```bash
make slide <content-name>/slide.md <content-name>/slide/index.html
```

This invokes Marp CLI with `--theme-set .marp/gdg.css --html`. The `--html` flag is required because the template and most slide types use inline HTML.

Generated HTML is **committed** (GitHub Pages serves it directly at `https://gdsc-osaka.github.io/education/<content-name>/slide/`).
