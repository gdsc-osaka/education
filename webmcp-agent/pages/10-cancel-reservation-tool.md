## 命令型 WebMCP で予約を解除する

Duration: 0:10:00

![cancel_reservation tool が参加者 ID から予約を解除する図](img/page10-cancel-reservation-tool.svg)

このステップでは、参加者 ID を指定して現在の予約を解除する `cancel_reservation` tool を追加します。

ここまでに作った `seat_summary`、`seat_list`、`my_reservation` は、予約データを読むための tool でした。`cancel_reservation` は、予約を解除してサーバー上の状態を変える tool です。

### `cancel_reservation` tool の役割

席を取り直したいときや、間違えて予約したときには、現在の予約を解除する必要があります。

`cancel_reservation` は、参加者 ID を受け取り、その参加者の予約を解除します。解除に成功すると、解除された席の情報などが返ります。

この tool は、前のステップで作った `my_reservation` と組み合わせると自然に使えます。

1. `my_reservation` で現在の予約を確認する
2. 必要であれば `cancel_reservation` で解除する
3. 解除後にもう一度 `my_reservation` で `reservation: null` を確認する

### 状態変更 tool と `readOnlyHint`

`cancel_reservation` は予約を解除します。つまり、サーバー上の予約状態を変更します。

そのため、`annotations.readOnlyHint: true` は付けません。このコードラボでは、状態を変える tool であることが分かるように、明示的に `readOnlyHint: false` を指定します。

```js
annotations: {
  readOnlyHint: false,
}
```

`seat_summary`、`seat_list`、`my_reservation` は読むだけの tool でした。`cancel_reservation` は状態を変える tool なので、Agent にもその違いが伝わるようにします。

> **Warning:** 状態を変更する tool は、読み取り専用 tool よりも慎重に扱います。今回の予約解除はハンズオン用の操作ですが、実サービスでは削除、購入、送金などの tool に同じ考え方が必要です。

### `webmcp.js` に `cancel_reservation` を追加する

`webmcp.js` を開きます。`Promise.allSettled([...])` の配列の中で、`my_reservation` の後ろに `cancel_reservation` tool を追加します。

`webmcp.js`

```diff js
     document.modelContext.registerTool({
       name: "my_reservation",
       title: "My Reservation",
       description: "参加者IDを指定して、その参加者の現在の予約を確認する。",
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
       },
       annotations: {
         readOnlyHint: true,
       },
       execute: async ({ participantId }) => {
         const input = document.querySelector("#participant-id");
         input.value = participantId;
         const data = await getMyReservation();
         await renderMyReservation();
         return data;
       },
     }),
+    document.modelContext.registerTool({
+      name: "cancel_reservation",
+      title: "Cancel Reservation",
+      description: "参加者IDを指定して、その参加者の予約を解除する。",
+      inputSchema: {
+        type: "object",
+        properties: {
+          participantId: {
+            type: "string",
+            description: "予約時に使用した参加者ID。",
+          },
+        },
+        required: ["participantId"],
+        additionalProperties: false,
+      },
+      annotations: {
+        readOnlyHint: false,
+      },
+      execute: async ({ participantId }) => {
+        const input = document.querySelector("#participant-id");
+        input.value = participantId;
+        const result = await cancelReservation();
+        await render();
+        await renderMyReservation();
+        return result;
+      },
+    }),
   ]);
 
-  console.info("[webmcp] ping, seat_summary, seat_list and my_reservation tools registered");
+  console.info("[webmcp] all imperative tools registered");
 }
```

`cancelReservation()` は、画面の参加者 ID 入力欄に入っている値を使って API を呼び出します。そのため、`my_reservation` と同じように、tool の中で `#participant-id` に `participantId` を入れてから呼び出します。

解除後は `render()` と `renderMyReservation()` を呼び出します。これにより、席一覧、座席マップ、自分の予約表示が更新されます。

### 返ってくる結果を確認する

`cancelReservation()` は、API の結果をそのまま返します。

予約が解除できた場合は、解除された席に関する情報が返ります。予約がない場合や参加者 ID が違う場合は、API からエラーが返ることがあります。

このステップでは、成功時に「予約が解除されたこと」、失敗時に「どの参加者 ID で試したか」を確認できれば十分です。

### ブラウザで登録ログを確認する

保存したら、ブラウザで席予約サイトを再読み込みします。

```text
http://localhost:8000
```

Chrome DevTools の Console に、次のような表示が出れば `cancel_reservation` まで登録されています。

**期待される出力:**

```text
[webmcp] all imperative tools registered
```

もし以前のログのまま変わらない場合は、`webmcp.js` を保存できているか確認し、ブラウザを再読み込みしてください。

### Antigravity で `cancel_reservation` を確認する

まず、予約がある参加者 ID を用意します。まだ予約していない場合は、予約フォームまたは宣言型 WebMCP の `reserve_seat` tool で先に予約します。

次に Antigravity に次のように聞きます。`your-connpass-id` は、自分の connpass ID に置き換えてください。

```text
WebMCP の cancel_reservation tool を使って、参加者ID your-connpass-id の予約を解除してください。
```

**期待される結果:**

- `cancel_reservation` tool が呼び出される
- その参加者 ID の予約が解除される
- 座席マップと席一覧が更新される
- 「自分の予約」表示が「予約はありません。」になる

解除後に、次のように確認します。

```text
WebMCP の my_reservation tool を使って、参加者ID your-connpass-id の予約状況を確認してください。
```

`reservation: null` が返れば、予約解除は成功です。

> **Troubleshooting:** 予約がない状態で `cancel_reservation` を呼び出すと、API からエラーが返る場合があります。先に `my_reservation` で予約があるか確認してから解除すると、原因を切り分けやすくなります。

ここまでで、命令型 WebMCP から席サマリー、席一覧、自分の予約確認、予約解除を扱えるようになりました。次のステップでは、Antigravity からそれぞれの tool を個別にテストし、宣言型の `reserve_seat` と組み合わせて動作を確認します。
