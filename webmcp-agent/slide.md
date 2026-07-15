---
marp: true
theme: gdg
paginate: true
size: 16:9
---

<script>
/* PowerPoint-style auto-shrink: iteratively reduce a slide's font size
   until its content stops overflowing. Also keeps the explicit opt-in
   <div class="fit">…</div> wrapper for finer-grained scaling. */
(() => {
  const MIN_FONT_PX = 12;
  const CODE_MIN_FONT_PX = 9;
  const STEP = 0.96;
  const MAX_ITERS = 40;
  const TOLERANCE = 1;
  let scheduled = false;

  const overflows = (el) =>
    el.scrollHeight > el.clientHeight + TOLERANCE ||
    el.scrollWidth  > el.clientWidth  + TOLERANCE;

  const shrinkElement = (el, minFontPx, shouldShrink = () => overflows(el)) => {
    if (!shouldShrink()) return;
    const base = parseFloat(getComputedStyle(el).fontSize) || 18;
    let size = base;
    for (let i = 0; i < MAX_ITERS && shouldShrink() && size > minFontPx; i++) {
      size *= STEP;
      el.style.fontSize = `${size}px`;
    }
  };

  const shrinkCodeBlocks = (section) => {
    for (const pre of section.querySelectorAll("pre")) {
      shrinkElement(pre, CODE_MIN_FONT_PX, () => overflows(pre) || overflows(section));
    }
  };

  const shrinkSection = (section) => {
    if (section.dataset.autofit === "skip") return;
    shrinkElement(section, MIN_FONT_PX, () => overflows(section));
  };

  const scaleFitBlocks = (root) => {
    for (const fit of root.querySelectorAll(".fit")) {
      if (!fit.scrollHeight) continue;
      const ratio = Math.min(1, fit.clientHeight / fit.scrollHeight);
      fit.style.transformOrigin = "top left";
      fit.style.transform = `scale(${ratio})`;
    }
  };

  const processSection = (section) => {
    if (!section.clientWidth || !section.clientHeight) return;
    scaleFitBlocks(section);
    shrinkCodeBlocks(section);
    shrinkSection(section);
  };

  const processVisibleSections = () => {
    scheduled = false;
    for (const section of document.querySelectorAll("section")) processSection(section);
  };

  const schedule = () => {
    if (scheduled) return;
    scheduled = true;
    requestAnimationFrame(() => requestAnimationFrame(processVisibleSections));
  };

  window.addEventListener("load", schedule);
  window.addEventListener("resize", schedule);
  new MutationObserver(schedule).observe(document.documentElement, {
    subtree: true,
    attributes: true,
    attributeFilter: ["class"],
  });
  schedule();
})();
</script>

<style>
/* Set once per deck — drives the colored university name on every title slide. */
:root { --gdg-university: 'University of Osaka'; }

.pill-row {
  display: flex;
  flex-wrap: wrap;
  gap: 14px;
  margin-top: 18px;
}

.pill {
  border: 2px solid var(--gdg-line);
  border-radius: 999px;
  padding: 9px 18px;
  background: #fff;
  font-weight: 600;
}

.pill.blue { border-color: var(--gdg-blue); background: #e8f0fe; }
.pill.green { border-color: var(--gdg-green); background: #e6f4ea; }
.pill.yellow { border-color: var(--gdg-yellow); background: #fef7e0; }
.pill.red { border-color: var(--gdg-red); background: #fce8e6; }

.cards {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 18px;
  margin-top: 18px;
}

.card {
  background: #fff;
  border: 2px solid var(--gdg-line);
  border-radius: 18px;
  padding: 22px;
  min-height: 154px;
}

.card h3 {
  margin: 0 0 8px;
  color: var(--gdg-ink);
  font-weight: 700;
}

.card p {
  color: var(--gdg-muted);
  margin: 0;
}

.flow {
  display: flex;
  align-items: stretch;
  gap: 16px;
  margin-top: 18px;
}

.flow .node {
  flex: 1;
  border: 2px solid var(--gdg-line);
  background: #fff;
  border-radius: 18px;
  padding: 18px;
  min-height: 112px;
}

.flow .arrow {
  align-self: center;
  font-size: 36px;
  color: var(--gdg-muted);
}

.note-box {
  border-left: 8px solid var(--gdg-yellow);
  background: #fff;
  border-radius: 12px;
  padding: 18px 22px;
  margin-top: 18px;
}

.big-number {
  font-size: 58px;
  font-weight: 800;
  color: var(--gdg-blue);
  line-height: 1;
}

section:has(> .cards):not(.split):not(.title):not(.lead):not(.section),
section:has(> .flow):not(.split):not(.title):not(.lead):not(.section),
section:has(> .note-box):not(.split):not(.title):not(.lead):not(.section),
section:has(> table):not(.split):not(.title):not(.lead):not(.section),
section:has(> p > img):not(.split):not(.title):not(.lead):not(.section) {
  background-image: none !important;
  padding-right: 80px !important;
}
</style>

<!-- _class: title -->
<!-- _paginate: false -->

# WebMCPを使って<br>AIエージェントから<br>呼び出してみよう!

WebMCP 開発ハンズオン 講義パート

---

## 今日のゴール

席予約サイトに WebMCP の入口を追加し、Agent から予約できる状態にします

![w:650](../img/codelab_ogp.png)

---

## 90分の流れ

| パート | 目安 | やること |
| --- | ---: | --- |
| 講義 | 25〜35分 | WebMCP と今回の構成を理解します |
| セットアップ | 20〜25分 | Chrome / Antigravity / bridge をつなぎます |
| 実装 | 35〜45分 | 宣言型・命令型 WebMCP を追加します |
| 体験 | 10分 | 全員で同時に席を予約します |

---

<!-- _class: section -->

# 01. WebMCP とは

---

## WebMCP の一言まとめ

Web ページの機能を、ブラウザ側 Agent が呼べる **tool** として見せる仕様です

<div class="pill-row">
<div class="pill blue">Web ページ</div>
<div class="pill green">ブラウザ側 Agent</div>
<div class="pill yellow">tool</div>
<div class="pill red">実験段階の仕様</div>
</div>

<div class="note-box">
今日の構成は Antigravity CLI + bridge + Chrome extension ですが、主想定はブラウザ内蔵 Agent です
</div>

---

<!-- _class: split -->

## 今日の構成と本来の想定

![w:540](../img/webmcp-concept.svg)

- 本来の想定は **ブラウザ側 Agent**
- 今日の実行役は **Antigravity CLI**
- bridge と拡張機能で、WebMCP tool を CLI 側へ渡します

---

## tool として見せる情報

<div class="cards">

<div class="card">
<h3>名前</h3>
<p><code>seat_list</code> など、Agent が呼ぶ識別子です</p>
</div>

<div class="card">
<h3>説明</h3>
<p>何をする tool かを Agent が判断する材料です</p>
</div>

<div class="card">
<h3>入力</h3>
<p>必要な引数を JSON Schema や form metadata で表します</p>
</div>

</div>

---

## MCP との違い

| 観点 | MCP | WebMCP |
| --- | --- | --- |
| tool の場所 | 外部の MCP server | 表示中の Web ページ |
| 主な呼び出し元 | Agent runtime | ブラウザ側 Agent |
| Web UI との距離 | 離れていることが多い | ページの状態に近い |
| 今日の役割 | CLI と Chrome をつなぐ | 席予約サイトが tool を公開 |

---

## スクレイピングではなく WebMCP を使う理由

<div class="cards">

<div class="card">
<h3>画面推測を減らす</h3>
<p>ボタン位置や文言ではなく、機能名と入力で操作します</p>
</div>

<div class="card">
<h3>意味を渡せる</h3>
<p>description と schema が、Agent の判断材料になります</p>
</div>

<div class="card">
<h3>変化に強い</h3>
<p>リアルタイムに変わる席状態でも、tool 経由で読み直せます</p>
</div>

</div>

---

<!-- _class: section yellow -->

# 02. 今回作る席予約システム

---

<!-- _class: split -->

## 触る場所は 2 つだけ

![w:540](../img/project-structure.svg)

- `index.html`
  - 予約フォームに宣言型 WebMCP を追加します
- `webmcp.js`
  - JavaScript で命令型 WebMCP tool を登録します

---

## 参加者全員で同じ席データを見ます

共通 API につながるので、席はリアルタイムに埋まります

<div class="flow">
<div class="node"><strong>参加者 A</strong><br>前の方を狙う</div>
<div class="arrow">→</div>
<div class="node"><strong>共通 API</strong><br>早い者勝ちで予約</div>
<div class="arrow">←</div>
<div class="node"><strong>参加者 B</strong><br>同じ席を狙う</div>
</div>

<div class="note-box">
競合は失敗ではなく、今日の体験の一部です
</div>

---

<!-- _class: section green -->

# 03. セットアップで大事なこと

---

<!-- _class: split -->

## セットアップの順番

![w:540](../img/setup-flow.svg)

1. VSCode / Node.js / Git を準備
2. Antigravity CLI を入れて `agy`
3. MCP bridge を設定
4. Chrome flag と拡張機能を有効化
5. template repo を開いて起動

---

## ここだけは事故りやすいです

<div class="cards">

<div class="card">
<h3><code>agy</code> を閉じない</h3>
<p>拡張機能との接続が切れたら、もう一度 <code>agy</code> を実行します</p>
</div>

<div class="card">
<h3>Chrome flag</h3>
<p><code>chrome://flags/#enable-webmcp-testing</code> を Enabled にします</p>
</div>

<div class="card">
<h3>ページ reload</h3>
<p>tool を追加したら、席予約サイトを再読み込みします</p>
</div>

</div>

---

<!-- _class: section -->

# 04. 実装の見取り図

---

## 2種類の WebMCP を実装します

| 種類 | 使う場所 | 今回の tool |
| --- | --- | --- |
| 宣言型 | HTML form | `reserve_seat` |
| 命令型 | JavaScript | `ping`, `seat_summary`, `seat_list`, `my_reservation`, `cancel_reservation` |

---

<!-- _class: split -->

## 宣言型 WebMCP

![w:520](../img/page05-declarative-form.svg)

- 既存の予約フォームに metadata を足します
- `toolname` で tool 名を付けます
- `toolparamdescription` で入力項目の意味を渡します
- `toolautosubmit` で自動送信します

---

## `toolautosubmit` の注意

`toolautosubmit` は、Agent が値を埋めたあとにフォームを自動送信するためのハンズオン用拡張機能の挙動です

<div class="note-box">
購入・削除・送金のような本番操作では、人間の確認を飛ばす経路になり得ます。便利さと安全性をセットで考えましょう
</div>

---

<!-- _class: split -->

## 命令型 WebMCP

![w:520](../img/page06-imperative-webmcp-file.svg)

- `webmcp.js` を作ります
- `app.js` より後に読み込みます
- `document.modelContext?.registerTool` を確認します
- まずは `ping` で接続確認します

---

## `registerTool()` の基本形

```js
document.modelContext.registerTool({
  name: "seat_summary",
  title: "Seat Summary",
  description: "現在の席数サマリーを取得する。",
  inputSchema: { type: "object", properties: {} },
  annotations: { readOnlyHint: true },
  execute: async () => {
    return await getSeats();
  },
});
```

---

## 読む tool と変える tool

| tool | 状態を変える? | `readOnlyHint` |
| --- | --- | --- |
| `seat_summary` | 変えない | `true` |
| `seat_list` | 変えない | `true` |
| `my_reservation` | 変えない | `true` |
| `reserve_seat` | 変える | なし |
| `cancel_reservation` | 変える | `false` |

---

<!-- _class: section red -->

# 05. テストと一斉予約

---

<!-- _class: split -->

## 小さく tool を確認します

![w:520](../img/page11-test-with-antigravity.svg)

1. `ping`
2. `seat_summary`
3. `seat_list`
4. `my_reservation`
5. `reserve_seat`
6. `cancel_reservation`

---

<!-- _class: split -->

## 最後は全員で同時予約!

![w:520](../img/page12-live-booking.svg)

- 講師の合図まで予約しないでください
- リセット後はページを reload
- 競合したら、別の空席を探して再挑戦します
- Agent がどう tool を選ぶか観察しましょう!

---

<!-- _class: lead -->

# Agent に<br>席の希望を伝えてみましょう!

---

## 振り返り

![w:780](../img/page13-wrap-up.svg)

---

<!-- _class: lead -->
<!-- _paginate: false -->

# お疲れさまでした!
