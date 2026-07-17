# `claat.md` 講義パート改善案

対象: `webmcp-agent/claat.md`

調査日: 2026-07-17

## 1. 推奨する講義の流れ

現在の「AI エージェントと tool → MCP → WebMCP → 両者の関係 → 画面操作との比較」は大筋でよい。15 分の概論としては、次の 6 ブロックに再構成すると因果関係が伝わりやすい。

1. **課題**: agent が人間向け UI を screenshot / DOM から推測して操作している
2. **tool**: name、description、schema、execute で機能の意味を構造化する
3. **MCP**: AI application と外部 system をつなぐ protocol
4. **WebMCP**: 開いている page 自身が client-side tool を公開する Web API
5. **比較**: MCP と WebMCP は競合せず、永続 backend と live tab という得意領域が違う
6. **責任**: tool は誤操作を減らすが、曖昧な説明、過剰 parameter、prompt injection、authorization は別途設計する

「WebMCP の定義」から始めるより、先に brittle UI actuation と backend integration の弱点を示すと、仕様が必要になった動機を理解しやすい。

## 2. 概論へ追加したい比較表

```markdown
| 観点 | MCP | WebMCP |
| --- | --- | --- |
| 主な対象 | local / remote server の機能 | 表示中の Web page の機能 |
| lifecycle | server が動く間は利用可能 | page を開いている間だけ利用可能 |
| 得意な context | backend data、background task | DOM、UI state、login session |
| UI | headless でも使える | live browser UI と協調する |
| discovery | host が server を設定・接続する | site を訪れたときに tool が現れる |
```

表の直後に次の注意書きを置く。

```markdown
> **補足:** WebMCP は、tool を agent へ渡す wire protocol を MCP に限定しません。このコードラボでは、Chrome 拡張機能と `webmcp-bridge-mcp` が WebMCP tool を MCP tool として Antigravity へ中継します。
```

## 3. `WebMCP とは` に足したい要点

- tool は `Document` に属し、page の JavaScript event loop で実行される
- page UI と tool が同じ client logic と state を共有できる
- tab を閉じる、navigate する、登録解除することで tool は利用できなくなる
- built-in browser agent、iframe 内 agent、extension の agent などを想定する
- human UI を置き換えるのではなく augment する

「Web page を in-page MCP server のように考えられる」は導入には便利だが、仕様が MCP transport を要求しない点も同時に説明する。

## 4. 命令型 API の説明で修正・追記したい点

現在の `registerTool()` の要素表に次を加える。

- `title`: UI 向けの localizable label
- `annotations.untrustedContentHint`: UGC / 外部 data を返す場合の hint
- registration option の `signal`: abort による登録解除
- registration option の `exposedTo`: 特定 secure origin への共有

`registerTool()` が Promise を返す理由は「登録完了を待つ」だけでなく、重複 name、不正 schema、Permissions Policy などを error として受け取るため、と説明するとよい。

## 5. 宣言型 API の説明で維持すべき注意

現在の「仕様本文は TODO、属性は実験的」という注意は正しいので残す。ただし「講師指定 extension が解釈する属性」と限定しすぎると、Chrome の origin trial / testing implementation でも同じ属性が扱われている事実が伝わりにくい。次の表現がより正確である。

```markdown
2026 年 7 月時点で、Chrome は宣言型 API を試験実装しています。一方、WebMCP 仕様本文の Declarative WebMCP 節と、HTML form から JSON Schema を合成する正確な algorithm はまだ TODO です。このステップでは現在の Chrome / bridge 環境が解釈する実験的な属性を使います。
```

`toolautosubmit` の warning は維持し、次も説明する。

- 属性なし: agent が form を埋め、ユーザーが内容を見て submit
- 属性あり: agent が submit / navigation まで進める
- state-changing action では、速さより user intent の確認を優先する

## 6. セキュリティ説明の改善

概論末尾の 1 段落を、次の 4 点が区別できる短い節にする。

1. **意味の明示**: name と description に実際の副作用を書く
2. **最小権限**: 必要な tool と parameter だけを公開する
3. **hint**: read-only と untrusted output を annotation する
4. **強制 control**: authentication、authorization、validation、confirmation は app / backend で行う

`readOnlyHint` は「safeHint」ではない。個人情報を読む tool は state を変更しなくても privacy risk がある。`untrustedContentHint` も output の無害化を保証しない。この 2 点を明記すると、annotation を security boundary と誤解しにくい。

## 7. 席予約題材に接続する問い

講義から実装へ移る直前に、受講者へ次の問いを置くと、その後の 4 tool の意味が立つ。

```markdown
席予約サイトの機能を次の 3 種類に分けてみます。

- 見るだけの操作: 空席一覧、現在の予約
- 状態を変える操作: 予約、キャンセル
- agent に任せず人が確認したい操作: 最終確定や本人確認が必要な処理

この分類は、どの機能を tool にするか、`readOnlyHint` を付けるか、実行前に確認を求めるかを決める材料になります。
```

## 8. 画像の採用候補

- MCP の説明: `docs/img/mcp-simple-diagram.png`
- tool の構成要素: `docs/img/classmethod-extension-tools.png`
- setup: `docs/img/classmethod-chrome-flag.png`

ただし codelab の画像規約では実際に使う画像を `webmcp-agent/img/` に置く。採用時に必要な画像だけコピーし、出典 URL を caption または本文リンクで明示する。Classmethod の screenshot は preview 時点の Chrome / extension UI なので、setup 用には workshop 当日の画面を新規撮影する方が混乱が少ない。

## 9. 既存本文で再確認したい記述

- `Antigravity CLI` の正式名称、install URL、bridge の動作は WebMCP 公式仕様の範囲外なので、workshop 固有の情報源で再検証する。
- `Chrome 149` origin trial と workshop で使う testing flag / extension の関係を分ける。origin trial は一般 site で API を有効化する仕組み、flag は local testing 用である。
- `file://` で開いた page と Secure Context / origin-keyed agent cluster の扱いは通常の HTTPS page と異なるため、「本番 WebMCP の一般的構成」と「この local workshop の例外」を混同しない。
- Chrome 文書の `getTools()` / `executeTool()` は実装文書にあるが、Explainer では仕様化が TODO。受講者向けには bridge 内部の詳細として深入りしない。

