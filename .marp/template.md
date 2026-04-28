---
marp: true
theme: gdg
paginate: true
size: 16:9
---

<script>
/* Scale .fit elements down so overflowing content fits the slide
   (PowerPoint-style auto shrink). Wrap any block in <div class="fit">…</div>. */
(() => {
  const transformOrigin = "top left";
  window.addEventListener("load", () => {
    const fits = document.querySelectorAll(".fit");
    for (const fit of fits) {
      if (!fit.scrollHeight) continue;
      const scaleRatio = Math.min(1, fit.clientHeight / fit.scrollHeight);
      fit.style.transformOrigin = transformOrigin;
      fit.style.transform = `scale(${scaleRatio})`;
    }
  });
})();
</script>

<!-- _class: title -->

# Google Developer Group
## Marp Presentation Template

GDG on Campus University of Osaka
2026-04-28

---

<!-- _class: lead -->

# Welcome to GDG

---

## Agenda

1. About Google Developer Groups
2. What we build
3. How to get involved
4. Q&A

---

<!-- _class: section -->

# 01. About GDG

---

## What is GDG?

Google Developer Groups are **community-led developer groups** that host events for developers interested in Google's developer technology.

- Open to everyone — students, professionals, hobbyists
- Local meetups, workshops, study jams
- Powered by Google, run by volunteers

> "Build with Google. Connect with developers." — *GDG community motto*

---

<!-- _class: section yellow -->

# 02. What we build

---

## Tech we love

| Area              | Tools                              |
| ----------------- | ---------------------------------- |
| Web               | Chrome, Lighthouse, Web Vitals     |
| Mobile            | Android, Flutter, Jetpack Compose  |
| Cloud             | Google Cloud, Firebase             |
| AI                | Gemini API, Vertex AI, TensorFlow  |

---

## Code example

```ts
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

const message = await client.messages.create({
  model: "claude-opus-4-7",
  max_tokens: 1024,
  messages: [{ role: "user", content: "Hello, GDG!" }],
});

console.log(message.content);
```

---

## Auto-fit overflowing content

<div class="fit">

Wrap a block in `<div class="fit">…</div>` and the embedded script scales it
down to fit the remaining vertical space (PowerPoint-style). Useful when
AI-generated content runs longer than expected.

- Paste long bullet lists without manually trimming
- Drop in verbose code samples
- Keep generous prose without breaking layout
- Combine with regular markdown — headings, lists, code, tables
- The element must be a direct child of `section` for height to resolve

</div>

---

<!-- _class: split -->

## Two-column layout

### Left column

- Bullet point one
- Bullet point two
- Bullet point three

### Right column

- Another bullet
- Yet another bullet
- One more bullet

---

<!-- _class: invert -->

## Dark slide

Use the `invert` class for emphasis or for code-heavy slides.

```bash
$ npm install -g @marp-team/marp-cli
$ marp template.md --pdf
```

---

<!-- _class: section green -->

# 03. Get involved

---

## Join us

- Find your local chapter at **gdg.community.dev**
- Follow your chapter on social
- Attend an event — most are free
- Volunteer as an organizer or speaker

---

<!-- _class: lead -->

# Thank you!

Questions?
