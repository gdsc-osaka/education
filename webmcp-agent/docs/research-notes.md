# WebMCP 調査ノート

調査日: 2026-07-17

## 1. 一言で説明するなら

WebMCP は、Web アプリが持つ機能を、自然言語の説明と構造化された入力スキーマを備えた JavaScript tool として AI agent に公開するための Web API である。tool は表示中のページで実行され、既存の JavaScript、DOM、UI 状態、ログイン済みセッションを利用できる。

仕様は Web Machine Learning Community Group の Draft Community Group Report であり、W3C Standard でも Standards Track でもない。2026-07-10 版の仕様自身も、宣言型 API、入出力検証、ユーザー確認、ストリーミングなどに未決事項を残している。

根拠: [WebMCP 仕様](https://webmachinelearning.github.io/webmcp/)、[WebMCP Explainer](https://github.com/webmachinelearning/webmcp)

## 2. なぜ WebMCP が提案されたのか

### 人間向け UI を agent が推測している

従来の browser agent は、スクリーンショット、DOM、accessibility tree を観察し、クリック、スクロール、文字入力を人間のように再現する。汎用性は高いが、次の弱点がある。

- ボタン名や DOM 構造、画面レイアウト、読み込みタイミングの変更に弱い
- ひとつの目的に複数の観察と操作が必要で、遅くなりやすい
- UI の見た目から機能の意味、副作用、必要な入力を agent が推測する
- 複雑な UI や視覚的な widget では誤操作が起きやすい

WebMCP はこの方法を禁止しない。ページが目的に合う tool を公開していなければ、agent は従来の browser automation に fallback できる。したがって WebMCP は、汎用 browser automation を置き換えるものではなく、重要な操作により直接的な経路を足す progressive enhancement と考えると理解しやすい。

根拠: [Explainer: Existing web actuation techniques](https://github.com/webmachinelearning/webmcp#existing-web-actuation-techniques)、[Chrome: WebMCP を使用する理由](https://developer.chrome.com/docs/ai/webmcp?hl=ja#why-use)

### backend integration だけでは失うものがある

MCP や OpenAPI による backend integration は、サーバー側のデータ取得や処理に適している。一方、interactive web application では次の課題が生じる。

- agent と backend の間だけで処理が進み、Web UI がユーザー体験から外れる
- ブラウザ内の現在の画面状態や一時的な編集状態を別サーバーへ再現する必要がある
- 認証状態やユーザーコンテキストを別の integration に引き渡す必要がある
- client-side の機能を公開するためだけに専用 backend を作る負担が生じる

WebMCP は page script 内に tool を置くことで、ユーザー、ページ、agent が同じ UI と状態を共有する協調作業を狙う。Explainer はこれを、UI の disintermediation を防ぎ、既存 client logic を再利用する手段として説明している。

根拠: [Explainer: Backend Integrations vs. In-browser WebMCP Tools](https://github.com/webmachinelearning/webmcp#backend-integrations-vs-in-browser-webmcp-tools)

## 3. MCP の最小限の背景

Model Context Protocol は、AI application を外部 system に接続するための open-source standard である。MCP は LLM 自体や agent の推論方法を定義せず、context を交換する protocol に焦点を置く。

MCP の主な参加者は次の 3 つである。

| 参加者 | 役割 |
| --- | --- |
| MCP host | AI application 全体を調整し、複数の MCP client を管理する |
| MCP client | 1 つの MCP server との専用接続を維持する |
| MCP server | client に tool、resource、prompt などの context を提供する program |

MCP の data layer は JSON-RPC、lifecycle、Tools / Resources / Prompts / notifications を定義し、transport layer は STDIO や Streamable HTTP などの通信方法を扱う。

根拠: [MCP introduction](https://modelcontextprotocol.io/docs/getting-started/intro)、[MCP architecture](https://modelcontextprotocol.io/docs/learn/architecture)

![MCP が AI application と data source / tool を接続する概念図](img/mcp-simple-diagram.png)

## 4. MCP と WebMCP の関係

WebMCP は MCP の extension や replacement ではない。両者は tool、schema、parameter という共通語彙を持つが、対象と lifecycle が異なる。

| 観点 | MCP | WebMCP |
| --- | --- | --- |
| 主目的 | agent が場所や時刻を問わず data / action を利用する | 開いている Web ページを agent が高い忠実度で操作する |
| 実行場所 | local process または remote server | 表示中の `Document` の JavaScript event loop |
| lifecycle | server / daemon による永続的な提供 | tab-bound、page-bound で一時的 |
| context | API や server が提供する context | DOM、現在の UI、session、cookie、client state |
| discovery | agent / host 側で server を設定・接続 | ページ訪問後に、そのページの tool が現れる |
| UI | headless や外部 UI でも使える | live browser UI と協調する |
| Web 固有の安全境界 | protocol 外で扱う部分が多い | origin、Secure Context、Permissions Policy を設計に含む |

WebMCP の仕様は、browser が agent に tool を渡す形式を MCP に限定していない。browser は MCP、独自 function calling、その他の方式を選べる。したがって「WebMCP tool は必ず MCP protocol で agent に届く」と説明するのは正確ではない。この codelab の Chrome extension と `webmcp-bridge-mcp` は、WebMCP tool を Antigravity へ渡す今回固有の接続構成である。

根拠: [Chrome: WebMCP と MCP の使い分け](https://developer.chrome.com/docs/ai/webmcp/compare-mcp?hl=ja)、[WebMCP spec: Page observations](https://webmachinelearning.github.io/webmcp/#page-observations)

## 5. WebMCP の tool call lifecycle

Explainer は命令型 tool の lifecycle を次の 5 段階で整理している。

1. **Registration**: ページが `document.modelContext.registerTool()` で tool を登録する。
2. **Discovery**: ページに接続された agent が、その時点で有効な tool と schema を得る。
3. **Invocation**: agent が `inputSchema` に沿った structured arguments を渡して実行を要求する。
4. **Execution**: browser が call を仲介し、ページの event loop で `execute` callback を呼ぶ。
5. **Response**: callback の return value が agent に返り、agent が次の判断に使う。

tool は UI を更新しても、API を呼び出しても、両方を行ってもよい。大切なのは、tool 実行後の UI と return value が実際の結果と一致することである。

根拠: [Explainer: Lifecycle of a Tool Call](https://github.com/webmachinelearning/webmcp#lifecycle-of-a-tool-call)

## 6. 命令型 API

現在の仕様上の入口は Secure Context で利用できる `document.modelContext` である。

```js
const controller = new AbortController();

await document.modelContext.registerTool({
  name: "get_my_reservation",
  title: "予約を確認",
  description: "指定した参加者の現在の席予約を取得する。",
  inputSchema: {
    type: "object",
    properties: {
      participantId: {
        type: "string",
        description: "予約を確認する参加者 ID。"
      }
    },
    required: ["participantId"]
  },
  annotations: {
    readOnlyHint: true,
    untrustedContentHint: false
  },
  async execute({ participantId }) {
    return getMyReservation(participantId);
  }
}, { signal: controller.signal });

// tool が不要になった時点で登録解除する。
controller.abort();
```

### tool definition

| field | 状態 | 意味 |
| --- | --- | --- |
| `name` | 必須 | tool の識別子。1〜128 文字、ASCII 英数字と `_` `-` `.` |
| `title` | 任意 | UI 向けの人間可読 label。ユーザーの言語への localize が推奨 |
| `description` | 必須 | tool が何をし、いつ使うかを agent に伝える自然言語 |
| `inputSchema` | 任意 | 入力 parameter を表す JSON Schema object |
| `execute` | 必須 | agent が tool を呼んだときに実行される callback。Promise を返せる |
| `annotations.readOnlyHint` | 任意、既定 `false` | state を変更しないことを示す hint |
| `annotations.untrustedContentHint` | 任意、既定 `false` | 出力に外部・UGC 由来の未信頼 data が含まれることを示す hint |

登録時の option には `signal` と `exposedTo` がある。`signal` を abort すると tool が登録解除される。`exposedTo` は同一 frame tree 内の特定 secure origin に tool を共有するための allowlist である。

### エラーと lifecycle 管理

`registerTool()` は Promise を返す。同名 tool の重複、空の name / description、不正な name、不正な `inputSchema`、無効な `Document`、Permissions Policy 違反などでは reject される。認証状態や page state に応じて tool を出し入れしたい場合は、tool ごとに `AbortController` を保持する。

### Chrome 実装と仕様の差

Chrome の 2026-07-01 文書は `getTools()` と `executeTool()` も案内しているが、同時点の Explainer では両 API の仕様記述が TODO とされている。講義の中心は標準ドラフト本文に定義された `registerTool()` に置き、agent / bridge 側の discovery と execution は実装依存として説明するのが安全である。

根拠: [WebMCP spec: ModelContext](https://webmachinelearning.github.io/webmcp/#modelcontext-interface)、[Chrome: 命令型 API](https://developer.chrome.com/docs/ai/webmcp/imperative-api?hl=ja)

## 7. 宣言型 API

宣言型 API は、既存の semantic HTML form を tool definition と input schema の元として再利用する提案である。

```html
<form
  toolname="reserve_seat"
  tooldescription="参加者 ID と席番号を指定して席を予約する。"
  toolautosubmit>
  <label for="participant-id">参加者 ID</label>
  <input
    id="participant-id"
    name="participantId"
    type="text"
    toolparamdescription="予約する参加者の ID。"
    required>

  <label for="seat-id">席番号</label>
  <input
    id="seat-id"
    name="seatId"
    type="text"
    toolparamdescription="予約する席の ID。例: A-5。"
    required>

  <button type="submit">予約する</button>
</form>
```

提案では `name`、`type`、`required`、`min`、`max`、`select` / `option` など既存 HTML semantics から JSON Schema を合成する。`toolparamdescription` がなければ、Chrome 文書は関連する `label`、次に `aria-description` を説明候補として使うとしている。

`toolautosubmit` がなければ、agent が値を入れたあと form をユーザーに見せ、手動送信を促す。付けると agent が入力後に submit と navigation まで進められる。購入、予約確定、削除など不可逆または高影響な操作では、無条件の auto-submit を避ける設計が望ましい。

提案中の `SubmitEvent.agentInvoked` は agent 起点の submit を識別し、`SubmitEvent.respondWith()` は navigation を止めて tool result を agent に返すための API である。

### 標準化状況の注意

2026-07-10 の仕様本文で Declarative WebMCP 節は「entirely a TODO」で、form から JSON Schema を合成する正確な algorithm も TODO である。Explainer も form response、navigation、pseudo-class、event などに TBD を残す。Chrome が試験実装している具体的挙動と、仕様として合意済みの内容を混同しないこと。

根拠: [Declarative API Explainer](https://github.com/webmachinelearning/webmcp/blob/main/declarative-api-explainer.md)、[Chrome: 宣言型 API](https://developer.chrome.com/docs/ai/webmcp/declarative-api?hl=ja)、[仕様 4.3](https://webmachinelearning.github.io/webmcp/#declarative-webmcp)

## 8. 設計目標と non-goals

### Goals

- ユーザーがページを見ながら agent に作業を委任できる human-in-the-loop workflow
- DOM scraping や simulated click より直接的で信頼しやすい client-side tool
- backend integration だけで Web UI が体験から外れることを防ぐ
- 既存の client-side code と UI 更新処理を再利用する
- agent を介して assistive technology の利用者を支援する可能性を広げる

### Non-goals

- browser UI のない headless workflow を主用途にすること
- human oversight のない fully autonomous agent
- MCP など backend integration の置き換え
- 人間向け interface の置き換え
- WebMCP 自体が accessibility tree を直接扱う accessibility API になること

この境界から、講義では「Web サイトを agent 専用 API に作り替える」のではなく「人間向け UI に agent 用の意味のある入口を追加する」と説明するとよい。

## 9. ユースケース

### Explainer が示す 3 分野

1. **Creative / graphic design**: template filtering、自然言語による visual edit、複数案の作成、checkout 前までの print order。UI 上に uncommitted changes を残し、人が確認・調整する。
2. **E-commerce / tailored shopping**: size や条件で商品を取得し、agent の vision とユーザー context で候補を絞り、ページの product grid を更新する。
3. **Specialized developer workflow**: code review UI から trybot status と log snippet を取得し、suggested edit を UI に表示して人が採否を決める。

### Chrome 文書が示す具体例

- 商品検索、wishlist への追加、再注文、配送方法の選択
- timesheet、job application、support request、warranty claim など長い form の入力
- 複雑な date picker や人間向け widget の操作
- 開発者設定画面の diagnostics 実行
- agent が page を移動しながら multi-step critical user journey を完了する支援

### この席予約 codelab との対応

| codelab tool | WebMCP の価値 |
| --- | --- |
| `list_seat` | UI を読む代わりに structured data で空席を取得する |
| `reserve_seat` | 既存 form semantics と validation を再利用する |
| `get_my_reservation` | ログイン中・閲覧中の context で read-only data を得る |
| `cancel_reservation` | state-changing action を明示的な name / description で公開する |

席予約は、検索→選択→予約→確認→取消という critical user journey を複数 tool で構成でき、WebMCP の協調 workflow を短時間で示しやすい題材である。

根拠: [Explainer: Use Cases](https://github.com/webmachinelearning/webmcp#use-cases)、[Chrome: user journeys](https://developer.chrome.com/docs/ai/webmcp/use-cases)

## 10. tool 設計の best practices

- 1 tool は 1 つの明確な機能にする。目的が重なる tool を増やさない。
- tool がその page state で使える時だけ登録し、使えなくなったら解除する。
- tool の数は agent の context と選択時間を消費するため、必要最小限にする。
- name は実行と開始を区別する。例: 即時作成の `create-event` と、form へ誘導する `start-event-creation-process`。
- description は「何をするか」「いつ使うか」を肯定形で書く。禁止事項の羅列で agent を制御しようとしない。
- parameter は明確な type / enum と意味のある値を使う。曖昧な内部 ID を agent に変換させすぎない。
- schema だけを信用せず、実行コードでも厳密に validate し、修正可能な error を返す。
- 実行後は UI state と result を一致させる。長い処理では完了前に成功を返さない。
- unit test に加え、複数の自然言語 prompt で tool 選択と parameter mapping を eval する。

Chrome の暫定的 character budget は name / parameter name 30 文字、parameter description 150 文字、tool description 500 文字、1 tool output 1,500 文字である。仕様上の上限ではなく、ecosystem feedback で変わりうる運用目安として扱う。

根拠: [Chrome: WebMCP best practices](https://developer.chrome.com/docs/ai/webmcp/best-practices)、[Chrome: tool security](https://developer.chrome.com/docs/ai/webmcp/secure-tools)

## 11. セキュリティとプライバシー

### WebMCP 特有の前提

browser agent は、ユーザーのログイン状態、personalization、閲覧中の data、場合によっては複数 site の context を利用できる。この能力は便利だが、従来の origin 境界だけでは説明できない agent-level risk を生む。

### 主な risk

1. **Tool poisoning**: name、description、parameter description に悪意ある自然言語命令を埋める。
2. **Output injection**: tool result に含まれる UGC や外部 data が agent への命令として解釈される。
3. **Misrepresentation of intent**: `finalizeCart` のような曖昧な名前が、実際には購入確定など別の副作用を起こす。
4. **Over-parameterization**: 本来不要な年齢、所在地、健康情報などを schema に要求し、agent が持つ personalization data を引き出す。
5. **Cross-origin exposure**: 不要な origin に tool を公開し、user data や state-changing action を利用可能にする。

### platform 側の境界

- `document.modelContext` は Secure Context に限定される。
- `tools` Permissions Policy の default allowlist は `'self'`。
- cross-origin iframe への登録委譲には `allow="tools"` が必要。
- cross-origin 共有は `exposedTo` に secure origin を明示する。
- 同じ name の重複や不正な schema は registration error になる。

これらは access boundary であり、tool の business authorization を代替しない。参加者 ID を知っているだけで他人の予約を取消せる API なら、WebMCP の有無に関係なく backend authorization の欠陥である。

### tool author が行うこと

- state-changing tool を明確に命名し、description に副作用を書く。
- read-only tool にだけ `readOnlyHint: true` を付ける。
- UGC や外部 data を返す tool に `untrustedContentHint: true` を付ける。
- 不要な parameter を要求しない。
- tool output を短く構造化し、信頼できない instruction を混ぜない。
- server 側で authentication、authorization、input validation、CSRF 対策、audit を行う。
- 購入、送金、削除、予約確定などはユーザー確認を設計する。

`readOnlyHint` と `untrustedContentHint` は agent への hint で、強制力のある security control ではない。LLM 内部だけで prompt injection を完全に防げないという前提で、agent、browser、site の多層防御が必要である。

根拠: [仕様: Security and Privacy](https://webmachinelearning.github.io/webmcp/#security-privacy)、[Chrome: WebMCP tool security](https://developer.chrome.com/docs/ai/webmcp/secure-tools)、[Chrome: agent security considerations](https://developer.chrome.com/docs/agents/security?hl=en)

## 12. 制限と open questions

### 現時点の制限

- tool を実行する page / WebView が必要で、通常の headless backend tool には向かない。
- agent は site を訪れるまで tool を discover できない。
- complex UI では client logic の整理や refactor が必要になる。
- page navigation や tab close で tool lifecycle が終わる。
- 宣言型 form の response と cross-document navigation の扱いは未確定。

### Explainer が追跡する主な open questions

- multimodal / binary input-output
- streamable input-output
- input / output schema validation
- `outputSchema`
- long-running tool の progress
- tool から user confirmation を要求する elicitation
- 複数 tool を束ねる skill
- Service Worker による background discovery / execution
- built-in agent への default exposure

講義では「将来は Service Worker で background tool もあり得る」より、「現在の基本モデルは human-in-the-loop の開いている tab」であることを先に固定する。

## 13. ユーザーブログから得られる実装上の知見

[DevelopersIO の検証記事](https://dev.classmethod.jp/articles/exploring-webmcp-and-testing-it/) は、Chrome flag、有志 extension、tool discovery、tool call の見え方を日本語の screenshot で追える点が有用である。また、name / description / inputSchema が agent の tool 選択と引数生成に影響するという説明は現在の設計とも一致する。

一方、記事は 2026-03-18 時点の preview API を扱い、現在の仕様と異なる記述がある。

| 記事の記述 | 現在の扱い |
| --- | --- |
| `navigator.modelContext` | `document.modelContext` を使う。Chrome 文書は前者を Chrome 150 で deprecated と明記 |
| `unregisterTool(name)` | 現仕様の registration option に `AbortSignal` を渡し、abort して解除 |
| `provideContext()` | 2026-07-10 仕様の `ModelContext` interface には存在しない |

したがって、記事の screenshot は環境説明に利用できるが、API code はそのまま教材へ転載しない。

## 14. 画像候補

| file | 内容 | 講義での利用候補 |
| --- | --- | --- |
| `img/mcp-simple-diagram.png` | MCP が AI application と data / tool をつなぐ概念図 | MCP の導入。ただし英語表記 |
| `img/classmethod-article-hero.png` | 記事の eye-catch | WebMCP セクション扉。概念説明力は低い |
| `img/classmethod-chrome-flag.png` | Chrome の WebMCP testing flag | setup 手順。撮影時の Chrome 148 表示に注意 |
| `img/classmethod-demo-availability.png` | preview demo site が WebMCP API を検出した表示 | 当時の entry point が `navigator.modelContext` だったことを示す旧 API 資料 |
| `img/classmethod-extension-tools.png` | extension が検出した tool 一覧と schema | name / description / inputSchema の関係の説明 |
| `img/classmethod-manual-tool-execution.png` | extension UI から `greet` を直接実行した画面 | structured arguments と response の説明 |
| `img/classmethod-agent-multi-tool-result.png` | agent が `greet` と `calculate` を連続実行した trace | 複数 tool を選択・連携する user journey |

各 PNG の出典は同名の `.png.meta` に URL のみ保存している。ブログ画像は preview 実装の UI なので、`claat.md` に採用する前に現在の workshop 環境と見た目が一致するか確認する。
