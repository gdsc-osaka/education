## 命令型 WebMCP を実装する `webmcp.js` を作成する

Duration: 0:10:00

![webmcp.js から registerTool を呼び出して ping tool を登録する図](img/page06-imperative-webmcp-file.svg)

このステップでは、命令型 WebMCP を書くための `webmcp.js` を作成します。まずは席予約の処理には触れず、動作確認用の小さな `ping` tool を登録します。

`ping` tool が Agent から見えれば、`webmcp.js` が読み込まれ、`document.modelContext.registerTool()` が呼び出せていることを確認できます。

### 命令型 WebMCP で何をするか

前のステップでは、HTML フォームに metadata を追加して、宣言型 WebMCP の `reserve_seat` tool を用意しました。

ここからは JavaScript で tool を登録する命令型 WebMCP を使います。命令型 WebMCP では、`document.modelContext.registerTool()` に tool の名前、説明、入力 schema、実行する関数を渡します。

このステップでは、次のことをします。

- `webmcp.js` を新規作成する
- `index.html` から `webmcp.js` を読み込む
- WebMCP が使えるか確認する
- `ping` tool を登録する
- Antigravity から `ping` を呼び出して動作確認する

### `webmcp.js` を作成する

`index.html` や `app.js` と同じフォルダに、`webmcp.js` というファイルを新しく作成します。

まずは次の内容を書きます。

`webmcp.js`

```js
// WebMCP 命令型 tool

async function registerImperativeTools() {
  if (!document.modelContext?.registerTool) {
    console.warn("[webmcp] document.modelContext.registerTool が見つかりません。");
    return;
  }

  console.info("[webmcp] register imperative tools");
}

registerImperativeTools();
```

`document.modelContext?.registerTool` が存在するか確認してから処理を進めます。WebMCP が使えない環境では、エラーで画面を止めずに `console.warn` を出して終了します。

> **補足:** `?.` は optional chaining です。左側が `null` や `undefined` のときにエラーにせず、結果を `undefined` にします。

### `index.html` から `webmcp.js` を読み込む

作成しただけでは、ブラウザは `webmcp.js` を読み込みません。`index.html` の最後で `app.js` の後に読み込みます。

`index.html` の下のほうを、次の diff のように編集します。

```diff html
     <script src="./app.js"></script>
+    <script src="./webmcp.js"></script>
   </body>
 </html>
```

`webmcp.js` は `app.js` の後に読み込みます。後のステップで、`webmcp.js` から `app.js` に定義されている `getSeats()` や `cancelReservation()` を呼び出すためです。

### ブラウザで読み込みを確認する

ブラウザで席予約サイトを再読み込みします。

```text
http://localhost:8000
```

Chrome DevTools の Console を開きます。Console に次のような表示が出ていれば、`webmcp.js` は読み込まれています。

**期待される出力:**

```text
[webmcp] register imperative tools
```

もし次のような warning が出た場合は、Chrome の WebMCP flag、拡張機能、ページの開き直しを確認します。

```text
[webmcp] document.modelContext.registerTool が見つかりません。
```

> **Troubleshooting:** Console に何も出ない場合は、`index.html` に追加した `<script src="./webmcp.js"></script>` のファイル名を確認してください。`webmcp.js` と `webmcp.Js` のように大文字小文字が違うと、環境によって読み込めません。

### `ping` tool を登録する

次に、動作確認用の `ping` tool を登録します。

`webmcp.js` を次のように更新します。

```diff js
 // WebMCP 命令型 tool
 
 async function registerImperativeTools() {
   if (!document.modelContext?.registerTool) {
     console.warn("[webmcp] document.modelContext.registerTool が見つかりません。");
     return;
   }
 
-  console.info("[webmcp] register imperative tools");
+  await document.modelContext.registerTool({
+    name: "ping",
+    title: "Ping",
+    description: "WebMCP の命令型 tool が登録できているか確認する。",
+    inputSchema: {
+      type: "object",
+      properties: {},
+      additionalProperties: false,
+    },
+    annotations: {
+      readOnlyHint: true,
+    },
+    execute: async () => {
+      return {
+        ok: true,
+        message: "pong",
+        pageTitle: document.title,
+      };
+    },
+  });
+
+  console.info("[webmcp] ping tool registered");
 }
 
 registerImperativeTools();
```

`ping` はデータを読むだけで、予約や解除のような状態変更をしません。そのため `annotations.readOnlyHint` を `true` にしています。

`inputSchema` は空の object です。つまり、この tool は引数なしで呼び出せます。

### Antigravity で `ping` を確認する

ブラウザを再読み込みし、Antigravity CLI が起動していることを確認します。

Antigravity に次のように聞きます。

```text
WebMCP の ping tool は見えていますか？見えていたら呼び出してください。
```

**期待される結果:**

- `ping` tool が見つかる
- tool の実行結果として `ok: true` や `message: "pong"` が返る
- `pageTitle` に席予約サイトのタイトルが入る

この確認が通れば、命令型 WebMCP の登録経路は動いています。次のステップから、`ping` と同じ形で実際の席予約サイトの関数を tool として登録していきます。
