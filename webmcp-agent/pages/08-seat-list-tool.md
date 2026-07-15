## 命令型 WebMCP で席一覧を取得する

Duration: 0:10:00

![seat_list tool が席ごとの状態を返し Agent が空席候補を選ぶ図](img/page08-seat-list-tool.svg)

このステップでは、全席の状態を返す `seat_list` tool を追加します。

前のステップで作った `seat_summary` は、空席数や予約済み数などの全体状況を返す tool でした。`seat_list` は、`A-1`、`A-2`、`B-1` のような席ごとの状態を返します。

### `seat_list` tool の役割

Agent が実際に予約する席を選ぶには、全体の空席数だけでは足りません。どの席が空いているのか、どの席が予約済みなのかを知る必要があります。

`seat_list` は、次のような席ごとの一覧を返します。

```json
{
  "seats": [
    { "id": "A-1", "row": "A", "number": 1, "status": "available" },
    { "id": "A-2", "row": "A", "number": 2, "status": "reserved" },
    { "id": "A-3", "row": "A", "number": 3, "status": "available" }
  ]
}
```

Agent はこの一覧を見て、「A 列の空席を探す」「前の方の空席を選ぶ」「予約済みではない席だけを候補にする」といった判断ができます。

> **補足:** このハンズオンでは、参加者を特定できる予約者情報は返しません。Agent が席を選ぶために必要な `id`、`row`、`number`、`status` を中心に扱います。

### `webmcp.js` に `seat_list` を追加する

`webmcp.js` を開きます。前のステップで作った `Promise.allSettled([...])` の配列の中に、`seat_list` tool を追加します。

`seat_summary` の `registerTool({...})` の後ろに、次の diff のように追加します。

`webmcp.js`

```diff js
   await Promise.allSettled([
     document.modelContext.registerTool({
       name: "ping",
       title: "Ping",
       description: "WebMCP の命令型 tool が登録できているか確認する。",
       inputSchema: {
         type: "object",
         properties: {},
         additionalProperties: false,
       },
       annotations: {
         readOnlyHint: true,
       },
       execute: async () => {
         return {
           ok: true,
           message: "pong",
           pageTitle: document.title,
         };
       },
     }),
 
     document.modelContext.registerTool({
       name: "seat_summary",
       title: "Seat Summary",
       description: "会場全体の席サマリーを取得する。",
       inputSchema: {
         type: "object",
         properties: {},
         additionalProperties: false,
       },
       annotations: {
         readOnlyHint: true,
       },
       execute: async () => {
         const data = await getSeats();
         return {
           eventName: data.eventName,
           summary: data.summary,
         };
       },
     }),
+    document.modelContext.registerTool({
+      name: "seat_list",
+      title: "Seat List",
+      description: "全席の状態一覧を取得する。",
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
+          seats: data.seats,
+        };
+      },
+    }),
   ]);
 
-  console.info("[webmcp] ping and seat_summary tools registered");
+  console.info("[webmcp] ping, seat_summary and seat_list tools registered");
 }
```

`seat_list` も `getSeats()` を呼び出します。ただし、`seat_summary` が `data.summary` だけを返したのに対して、`seat_list` は `data.seats` を返します。

### 返ってくる席データを見る

`data.seats` には、席ごとの情報が配列で入っています。

主に使うのは次の項目です。

| 項目 | 意味 | 例 |
| --- | --- | --- |
| `id` | 席 ID | `A-1` |
| `row` | 列 | `A` |
| `number` | 列の中の番号 | `1` |
| `status` | 席の状態 | `available` / `reserved` / `disabled` |

`status` が `available` の席は空席です。Agent はこの値を見て、予約できそうな席を候補にできます。

### `readOnlyHint` を付ける

`seat_list` も、席を予約したり解除したりしません。現在の席一覧を読むだけです。

そのため、`seat_summary` と同じように `annotations.readOnlyHint: true` を付けます。

読み取り専用 tool が増えてくると、Agent はまず `seat_summary` で全体を見て、必要に応じて `seat_list` で具体的な席を探す、という流れを作りやすくなります。

### ブラウザで登録ログを確認する

保存したら、ブラウザで席予約サイトを再読み込みします。

```text
http://localhost:8000
```

Chrome DevTools の Console に、次のような表示が出れば `seat_list` まで登録されています。

**期待される出力:**

```text
[webmcp] ping, seat_summary and seat_list tools registered
```

もし以前のログのまま変わらない場合は、`webmcp.js` を保存できているか確認し、ブラウザを再読み込みしてください。

### Antigravity で `seat_list` を確認する

Antigravity に次のように聞きます。

```text
WebMCP の seat_list tool を呼び出して、空席を5つ教えてください。
```

**期待される結果:**

- `seat_list` tool が呼び出される
- 席ごとの一覧が取得される
- `status` が `available` の席が候補として返る
- 予約や解除は行われない

次のような確認もできます。

```text
WebMCP の seat_list tool を使って、A列の空席を探してください。
```

Agent が `row: "A"` と `status: "available"` を見て、A 列の空席を探せれば成功です。

> **Troubleshooting:** tool は見えているのに席が返らない場合は、席予約サイトが API に接続できているか確認してください。画面の「席の状況」に座席マップと席一覧が表示されていれば、`getSeats()` は動いています。

ここまでで、Agent は会場全体のサマリーだけでなく、具体的な席候補も探せるようになりました。次のステップでは、参加者 ID を使って自分の予約状態を確認する tool を追加します。
