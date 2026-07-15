## 命令型 WebMCP で自分の予約を確認する

Duration: 0:10:00

![my_reservation tool が参加者 ID から現在の予約を確認する図](img/page09-my-reservation-tool.svg)

このステップでは、参加者 ID を指定して現在の予約を確認する `my_reservation` tool を追加します。

ここまでに作った `seat_summary` と `seat_list` は、会場全体や席一覧を見るための tool でした。`my_reservation` は、特定の参加者がすでに席を予約しているかを確認する tool です。

### `my_reservation` tool の役割

Agent が席を予約するとき、いきなり新しい予約を作る前に「この参加者はすでに予約しているか」を確認できると便利です。

`my_reservation` は、参加者 ID を受け取り、その参加者の予約状況を返します。

予約がある場合は、次のような結果が返ります。

```json
{
  "reservation": {
    "seatId": "A-1"
  }
}
```

予約がない場合は、次のように `reservation` が `null` になります。

```json
{
  "reservation": null
}
```

この tool があると、Agent は「すでに予約があるなら新しく予約しない」「予約解除の前に今の予約を確認する」といった判断をしやすくなります。

### 初めての引数あり tool

これまでに作った `ping`、`seat_summary`、`seat_list` は、引数なしで呼び出せる tool でした。

`my_reservation` は「誰の予約を見るのか」を知る必要があるため、`participantId` を入力として受け取ります。

`inputSchema` は次のような形になります。

```js
inputSchema: {
  type: "object",
  properties: {
    participantId: {
      type: "string",
      description: "予約状況を確認する参加者ID。",
    },
  },
  required: ["participantId"],
  additionalProperties: false,
}
```

`required: ["participantId"]` があるため、Agent はこの tool を呼び出すときに `participantId` を渡す必要があります。

### `webmcp.js` に `my_reservation` を追加する

`webmcp.js` を開きます。`Promise.allSettled([...])` の配列の中で、`seat_list` の後ろに `my_reservation` tool を追加します。

`webmcp.js`

```diff js
     document.modelContext.registerTool({
       name: "seat_list",
       title: "Seat List",
       description: "全席の状態一覧を取得する。",
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
           seats: data.seats,
         };
       },
     }),
+    document.modelContext.registerTool({
+      name: "my_reservation",
+      title: "My Reservation",
+      description: "参加者IDを指定して、その参加者の現在の予約を確認する。",
+      inputSchema: {
+        type: "object",
+        properties: {
+          participantId: {
+            type: "string",
+            description: "予約状況を確認する参加者ID。",
+          },
+        },
+        required: ["participantId"],
+        additionalProperties: false,
+      },
+      annotations: {
+        readOnlyHint: true,
+      },
+      execute: async ({ participantId }) => {
+        const input = document.querySelector("#participant-id");
+        input.value = participantId;
+        const data = await getMyReservation();
+        await renderMyReservation();
+        return data;
+      },
+    }),
   ]);
 
-  console.info("[webmcp] ping, seat_summary and seat_list tools registered");
+  console.info("[webmcp] ping, seat_summary, seat_list and my_reservation tools registered");
 }
```

`getMyReservation()` は、画面の参加者 ID 入力欄に入っている値を使って API を呼び出します。そのため、tool の中で `#participant-id` に `participantId` を入れてから `getMyReservation()` を呼び出します。

その後で `renderMyReservation()` を呼び出し、画面の「自分の予約」表示も更新します。

### 読み取り専用だが画面は更新する

`my_reservation` には `annotations.readOnlyHint: true` を付けます。

この tool は予約を作ったり解除したりせず、予約状態を読むだけです。一方で、ページ上の参加者 ID 入力欄と「自分の予約」表示は更新します。

つまり、サーバー上の予約データは変更しませんが、Web ページの表示状態は変わります。この違いを意識しておくと、後の状態変更 tool との区別がしやすくなります。

### ブラウザで登録ログを確認する

保存したら、ブラウザで席予約サイトを再読み込みします。

```text
http://localhost:8000
```

Chrome DevTools の Console に、次のような表示が出れば `my_reservation` まで登録されています。

**期待される出力:**

```text
[webmcp] ping, seat_summary, seat_list and my_reservation tools registered
```

もし以前のログのまま変わらない場合は、`webmcp.js` を保存できているか確認し、ブラウザを再読み込みしてください。

### Antigravity で `my_reservation` を確認する

Antigravity に次のように聞きます。`your-connpass-id` は、自分の connpass ID に置き換えてください。

```text
WebMCP の my_reservation tool を使って、参加者ID your-connpass-id の予約状況を確認してください。
```

**期待される結果:**

- `my_reservation` tool が呼び出される
- 予約があれば `reservation.seatId` が返る
- 予約がなければ `reservation: null` が返る
- ページ上の「自分の予約」表示も更新される

まだ予約していない場合は `reservation: null` が返ります。その場合は、予約フォームから手動で予約するか、宣言型 WebMCP の `reserve_seat` tool で予約してからもう一度確認します。

> **Troubleshooting:** `getMyReservation is not defined` と出た場合は、`index.html` で `webmcp.js` を `app.js` より後に読み込んでいるか確認してください。`getMyReservation()` は `app.js` に定義されています。

ここまでで、Agent は参加者 ID から現在の予約状況を確認できるようになりました。次のステップでは、参加者 ID を指定して予約を解除する `cancel_reservation` tool を追加します。
