## 予約フォームに宣言型 WebMCP を実装する

Duration: 0:10:00

![予約フォームに metadata を追加して reserve_seat tool として公開する図](img/page05-declarative-form.svg)

このステップでは、予約用の HTML フォームに宣言型 WebMCP の metadata を追加します。これにより、AI エージェントは「参加者 ID と席番号を渡すと、席を予約できるフォームがある」と理解できるようになります。

ここで触るファイルは `index.html` だけです。JavaScript はまだ書きません。

### 宣言型 WebMCP で何をするか

開始時点の `index.html` には、参加者 ID と席番号を入力して予約するフォームがあります。人間はこのフォームを見て「ここから予約できる」と分かりますが、Agent にはフォームの意味をもう少し明示してあげる必要があります。

通常のフォームには、送信先の `action`、送信方法の `method`、入力欄の `name` などがあります。宣言型 WebMCP では、そこに「このフォームはどんな tool なのか」「各入力欄は何を表すのか」という説明を足します。

今回追加する属性は次の 4 種類です。

| 属性 | 付ける場所 | 役割 |
| --- | --- | --- |
| `toolname` | `form` | Agent から見える tool の名前です。 |
| `tooldescription` | `form` | tool が何をするかを説明します。 |
| `toolautosubmit` | `form` | Agent が値を埋めたあと、このフォームを自動送信することを示します。 |
| `toolparamdescription` | `input` | 入力パラメータの意味を説明します。 |

> **Warning:** これらの属性名は、2026年7月時点で確定済みの標準属性として扱うものではありません。このハンズオンでは、講師が用意した Chrome 拡張機能が読み取る属性として使います。

### `index.html` の予約フォームを探す

VSCode で `index.html` を開き、`<h2>予約する</h2>` を検索します。

見つかるフォームは、ページ上部の「予約する」セクションにあります。次のような形です。

`index.html`

```html
<section>
  <h2>予約する</h2>
  <form
    action="http://localhost:8787/api/reservations"
    method="post"
  >
```

このフォームは画面にも表示されます。席の状況には、クリックできる座席マップも用意されていますが、今回の編集では見た目やクリック操作は変えません。Agent が読み取るための metadata だけを追加します。

### フォームに tool の名前・説明・自動送信を追加する

まず、`form` に `toolname`、`tooldescription`、`toolautosubmit` を追加します。

`index.html` の予約フォームを、次の diff のように編集します。

```diff html
         <form
           action="http://localhost:8787/api/reservations"
           method="post"
+          toolname="reserve_seat"
+          tooldescription="参加者IDと席番号を指定して席を予約する。"
+          toolautosubmit
         >
```

`toolname` は Agent から見える tool 名です。ここでは `reserve_seat` にします。

`tooldescription` は、Agent が「この tool はいつ使うものか」を判断するための説明です。短くてもよいですが、何を入力して何をする tool なのかが分かる文にします。

`toolautosubmit` は、Agent がフォームの入力値を埋めたあとに、そのフォームを自動で送信するための属性です。今回の予約フォームでは、参加者 ID と席番号が入ったら、そのまま予約 API に送信してよいものとして扱います。

> **Warning:** `toolautosubmit` は、人間の確認を挟まずにフォーム送信まで進めるための属性です。今回のようなハンズオン用の席予約では便利ですが、購入確定、送金、削除などの重要操作では、Agent の判断ミスがそのまま実行につながる可能性があります。

### 参加者 ID の説明を追加する

次に、参加者 ID の `input` に `toolparamdescription` を追加します。

`participantId` は、予約する人を識別するための ID です。このハンズオンでは connpass ID を使います。

```diff html
        <label>
          参加者ID
          <input
            id="participant-id"
            name="participantId"
            required
            pattern="[A-Za-z0-9_\-]{1,64}"
+           toolparamdescription="予約する参加者のID。"
          />
        </label>
```

`name="participantId"` は、実際にフォーム送信されるパラメータ名です。`toolparamdescription` は、そのパラメータが何を意味するかを Agent に伝える説明です。

### 席番号の説明を追加する

続けて、席番号の `input` にも `toolparamdescription` を追加します。

```diff html
        <label>
          席番号
          <input
            name="seatId"
            required
            pattern="[A-J]-([1-9]|10)"
            placeholder="A-5"
+           toolparamdescription="予約する席のID。例: A-5。"
          />
        </label>
```

席番号は `A-5` のような形式です。説明に例を入れておくと、Agent が入力形式を推測しやすくなります。

### 完成形を確認する

編集後のフォームは、次のようになります。

`index.html`

```html
<form
  action="http://localhost:8787/api/reservations"
  method="post"
  toolname="reserve_seat"
  tooldescription="参加者IDと席番号を指定して席を予約する。"
  toolautosubmit
>
  <label>
    参加者ID
    <input
      id="participant-id"
      name="participantId"
      required
      pattern="[A-Za-z0-9_\-]{1,64}"
      toolparamdescription="予約する参加者のID。"
    />
  </label>
  <label>
    席番号
    <input
      name="seatId"
      required
      pattern="[A-J]-([1-9]|10)"
      placeholder="A-5"
      toolparamdescription="予約する席のID。例: A-5。"
    />
  </label>
  <input type="hidden" name="source" value="webmcp" />
  <button type="submit">予約する</button>
</form>
```

ここまでで、予約フォームは `reserve_seat` tool として説明できる状態になりました。

### 自動送信と手動送信の違いを知る

このハンズオンで使う拡張機能では、`toolautosubmit` が付いた宣言型フォームを `webmcp_call_tool` で呼び出すと、入力値を埋めたあとにフォームが自動送信されます。つまり、Agent が `participantId` と `seatId` を渡すだけで、予約処理まで進みます。

一方、`toolautosubmit` が付いていないフォームでは、値を埋めたあとに送信を確定する必要があります。今回の拡張機能と bridge には、そのための `webmcp_submit_tool` という MCP tool も用意されています。

ただし、`webmcp_submit_tool` はこのハンズオン用拡張機能の polyfill 実装に対する機能です。ブラウザに WebMCP がネイティブ実装された場合、宣言型フォームの実行は人間のクリックや確認で止まることがあり、その場合は `webmcp_submit_tool` の出番自体がありません。

> **Warning:** `webmcp_submit_tool` は、本来人間の確認を要求するフォーム送信を Agent が明示的に進めるための経路です。便利な一方で、安全機構を迂回できる経路でもあります。このコードラボでは `toolautosubmit` を使うため、同じフォームに対して `webmcp_submit_tool` を追加で呼び出す必要はありません。

### ブラウザで表示が壊れていないことを確認する

保存したら、ブラウザで席予約サイトを再読み込みします。

```text
http://localhost:8000
```

**期待される状態:**

- 画面の見た目は編集前と変わらない
- 「予約する」フォームが表示される
- 座席マップと席一覧が表示される
- 座席マップの空席をクリックすると、フォームの席番号に `A-1` のような席 ID が入力される

HTML に追加した metadata は画面には表示されません。見た目を変えずに、Agent が読み取るための意味だけを追加しました。

> **Troubleshooting:** 画面が崩れた場合は、`form`、`input`、`label` の閉じタグが消えていないか確認してください。HTML の属性は、タグの `>` より前に追加します。

次のステップでは、命令型 WebMCP 用の `webmcp.js` を作成し、JavaScript から tool を登録します。
