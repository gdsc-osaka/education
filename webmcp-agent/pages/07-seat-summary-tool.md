## 命令型 WebMCP で席サマリーを取得する

Duration: 0:10:00

![seat_summary tool が getSeats を呼び出して summary だけを返す図](img/page07-seat-summary-tool.svg)

このステップでは、命令型 WebMCP の最初の実用的な tool として `seat_summary` を追加します。

前のステップで作った `ping` は、WebMCP の登録経路を確認するための tool でした。ここからは、席予約サイトの実際のデータを読み取る tool を作っていきます。

### `seat_summary` tool の役割

`seat_summary` は、会場全体の席の状況をまとめて返す tool です。全席の細かい情報ではなく、合計席数、空席数、予約済み数、使用禁止席数だけを返します。

たとえば、Agent から見ると次のような結果が返ります。

```json
{
  "eventName": "WebMCP × Antigravity Hands-on",
  "summary": {
    "total": 100,
    "available": 98,
    "reserved": 2,
    "disabled": 0
  }
}
```

Agent はこの情報を見ることで、「まだ空席がある」「かなり埋まってきた」「具体的な席を探すために席一覧も見た方がよい」といった判断をしやすくなります。

この tool は席を予約したり解除したりしません。現在の状態を読むだけの tool です。

### `webmcp.js` に `seat_summary` を追加する

`webmcp.js` を開きます。前のステップで作った `ping` tool と、今回追加する `seat_summary` tool をまとめて登録する形に変更します。

複数の tool を登録するときは、完成例と同じように `Promise.allSettled([...])` を使います。これにより、複数の `registerTool()` を並べて書けるようになります。

`webmcp.js`

```diff js
 // WebMCP 命令型 tool
 
 async function registerImperativeTools() {
   if (!document.modelContext?.registerTool) {
     console.warn("[webmcp] document.modelContext.registerTool が見つかりません。");
     return;
   }
 
-  await document.modelContext.registerTool({
-    name: "ping",
-    title: "Ping",
-    description: "WebMCP の命令型 tool が登録できているか確認する。",
-    inputSchema: {
-      type: "object",
-      properties: {},
-      additionalProperties: false,
-    },
-    annotations: {
-      readOnlyHint: true,
-    },
-    execute: async () => {
-      return {
-        ok: true,
-        message: "pong",
-        pageTitle: document.title,
-      };
-    },
-  });
+  await Promise.allSettled([
+    document.modelContext.registerTool({
+      name: "ping",
+      title: "Ping",
+      description: "WebMCP の命令型 tool が登録できているか確認する。",
+      inputSchema: {
+        type: "object",
+        properties: {},
+        additionalProperties: false,
+      },
+      annotations: {
+        readOnlyHint: true,
+      },
+      execute: async () => {
+        return {
+          ok: true,
+          message: "pong",
+          pageTitle: document.title,
+        };
+      },
+    }),
 
-  console.info("[webmcp] ping tool registered");
+    document.modelContext.registerTool({
+      name: "seat_summary",
+      title: "Seat Summary",
+      description: "会場全体の席サマリーを取得する。",
+      inputSchema: {
+        type: "object",
+        properties: {},
+        additionalProperties: false,
+      },
+      annotations: {
+        readOnlyHint: true,
+      },
+      execute: async () => {
+        const data = await getSeats();
+        return {
+          eventName: data.eventName,
+          summary: data.summary,
+        };
+      },
+    }),
+  ]);
+
+  console.info("[webmcp] ping and seat_summary tools registered");
 }
 
 registerImperativeTools();
```

`seat_summary` の `execute` の中で `getSeats()` を呼び出しています。`getSeats()` は `app.js` に定義済みの関数です。`index.html` では `app.js` の後に `webmcp.js` を読み込んでいるため、`webmcp.js` から `getSeats()` を呼び出せます。

`Promise.allSettled([...])` の中には、これから作る tool も同じ形で追加していきます。次のステップで `seat_list` を追加するときも、この配列の中に `document.modelContext.registerTool({...})` を増やします。

### `readOnlyHint` を付ける

`seat_summary` には、`annotations.readOnlyHint: true` を付けています。

これは「この tool は状態を変更しない」というヒントです。今回の `seat_summary` は、席の状態を読むだけで、予約や解除は行いません。そのため読み取り専用の tool として扱えます。

反対に、後のステップで作る予約解除 tool のように状態を変更する tool には、`readOnlyHint: true` を付けません。

> **補足:** `readOnlyHint` は、tool の説明文を置き換えるものではありません。Agent が tool を選びやすくなるように、`description` と合わせて使います。

### ブラウザで登録ログを確認する

保存したら、ブラウザで席予約サイトを再読み込みします。

```text
http://localhost:8000
```

Chrome DevTools の Console に、次のような表示が出れば `webmcp.js` は読み込まれています。

**期待される出力:**

```text
[webmcp] ping and seat_summary tools registered
```

もし `document.modelContext.registerTool が見つかりません。` と表示される場合は、WebMCP flag、拡張機能、Antigravity CLI の起動状態を確認してください。

### Antigravity で `seat_summary` を確認する

Antigravity に次のように聞きます。

```text
WebMCP の seat_summary tool を呼び出して、現在の席のサマリーを教えてください。
```

**期待される結果:**

- `seat_summary` tool が呼び出される
- `eventName` が返る
- `summary.total`、`summary.available`、`summary.reserved`、`summary.disabled` が返る
- 予約や解除は行われない

返ってくる数値は、その時点の予約状況によって変わります。他の参加者が予約している場合は、空席数や予約済み数も変わります。

> **Troubleshooting:** `getSeats is not defined` と出た場合は、`index.html` で `webmcp.js` を `app.js` より後に読み込んでいるか確認してください。`<script src="./app.js"></script>` の下に `<script src="./webmcp.js"></script>` がある状態にします。

ここまでで、Agent は席予約サイトの全体状況を tool として取得できるようになりました。次のステップでは、全席の状態を返す `seat_list` tool を追加し、Agent が具体的な空席を探せるようにします。
