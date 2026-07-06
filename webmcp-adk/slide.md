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
</style>

<!-- _class: title -->
<!-- _paginate: false -->

# WebMCP x ADK で作る  
座席予約マルチエージェント

Google I/O Extended 2026 @ Osaka ハンズオン

---

<!-- _class: lead -->

# 今日のゴール

自然文で希望を伝えると、4 specialist と coordinator Workflow が WebMCP 経由で席を予約します

---

## Agenda

1. LLM / Agent / Tool
2. MCP と WebMCP
3. 宣言型と命令型 WebMCP
4. 4 specialist + Workflow 構成
5. 今日触るファイル
6. 進め方

---

<!-- _class: section -->

# 01. Agent の考え方

---

## LLM / Agent / Tool

LLM は入力から出力を生成します  
Agent は LLM に **Tool** と **実行の流れ** を持たせたアプリです

| 役割 | 今回の例 |
| --- | --- |
| LLM | 希望文を読み、次の行動を決める |
| Tool | 空席取得、席詳細取得、予約 |
| Agent | tool を使って座席予約を進める |

---

## なぜ Agent を分ける?

<div class="fit">

- 1つの巨大な instruction より、責務が読みやすい
- WebMCP の「調べる」と「予約する」を別々に扱える
- 失敗したときに、検索・予約・調整のどこで詰まったか見やすい
- A2A 化する Extra へ自然につながる

</div>

---

<!-- _class: section yellow -->

# 02. MCP と WebMCP

---

## API と MCP

API はアプリ同士が通信するための約束です  
MCP は Agent が tool を発見し、入力を理解し、実行するための約束です

| 観点 | API | MCP |
| --- | --- | --- |
| 主な利用者 | 開発者 / アプリ | Agent / モデル |
| 中心 | endpoint | tool schema |
| 目的 | データ通信 | tool 利用 |

---

## WebMCP

WebMCP は Web ページ上の機能を Agent に見つけやすくします

```js
document.modelContext.registerTool({
  name: "list_available_seats",
  description: "予約可能な席を一覧します",
  inputSchema: { type: "object" },
});
```

今日は **本物の WebMCP** を使います  
WebMCP 風の shim は使いません

---

<!-- _class: split -->

## 宣言型 / 命令型

### 命令型

- JavaScript から tool を登録
- 空席一覧、席詳細、予約一覧を取得
- `seat_finder_agent` が使う

### 宣言型

- フォームや action の意味を公開
- 予約フォームを `reserve_seat` として扱う
- `reservation_agent` が使う

---

<!-- _class: section green -->

# 03. 今日作るもの

---

## 全体構成

![w:920](img/step2-architecture.svg)

---

## 4 specialist + Workflow

| Agent | 役割 | 使うもの |
| --- | --- | --- |
| `coordinator` | ユーザーの入口、候補選択、retry | `Workflow` |
| `preference_parser_agent` | 希望をタグへ構造化 | structured output |
| `seat_finder_agent` | 空席調査、最大3候補を返す | 命令型 WebMCP |
| `seat_ranker_agent` | 候補をスコア順に並べる | structured output |
| `reservation_agent` | 指定された1席を1回だけ予約 | 宣言型 WebMCP |

---

## retry の置き場所

`seat_already_reserved` のときだけ  
`coordinator` が次候補を試します

`reservation_agent` は retry しません  
指定された席を1回だけ予約します

---

<!-- _class: split -->

## 参加者が実装する場所

### Web

- `public/script.js`
- 命令型 WebMCP tool
- 宣言型 WebMCP action

### Agent

- `tools/webmcp_tools.py`
- `agents/preference_parser/agent.py`
- `agents/seat_finder/agent.py`
- `agents/seat_ranker/agent.py`
- `agents/reservation/agent.py`
- `agents/coordinator/agent.py`

---

## Web 側の設定

すでに完成している予約サイトに  
WebMCP を足す状況を想定します

- UI は完成済み
- API client は完成済み
- form submit は完成済み
- WebMCP 登録だけを書く

---

## Agent 側の設定

関数、ファイル、Agent 定義は用意済みです

参加者は中身を埋めます

- MCP relay への接続
- WebMCP toolset
- specialist agent の instruction
- coordinator の `Workflow` node 実装

---

## 当日の進め方

1. `setup` を実行します
2. `.env` に Gemini API key を貼ります
3. 予約サイトを先に開きます
4. ADK Web を開いて Agent と話します
5. 運営ボードで connpass ID を確認します

困ったら `#260718_webmcp_agent` と TA を使ってください!

---

## 完成確認

運営ボードで、自分の connpass ID が席に表示されたら完成です

失敗したら見る場所

- 予約サイトの debug page
- ADK Web の tool 呼び出し
- `.env` と `public/config.js`
- Discord の `BOARD_URL`

---

<!-- _class: section yellow -->

# 04. Extra

---

## 早く終わったら

- debug page の実装を読む
- 重み付きランキングに広げる
- 複数席予約に広げる
- A2A で specialist agent を分離する
- specialist prompt と出力形式を改善する

---

<!-- _class: lead -->

# 実装してみましょう!
