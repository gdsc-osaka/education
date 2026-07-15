## Antigravity で WebMCP tool をテストする

Duration: 0:12:00

![Antigravity から WebMCP tools を順番に確認するチェックリスト図](img/page11-test-with-antigravity.svg)

このステップでは、ここまで実装した WebMCP tool を Antigravity から個別に呼び出して確認します。

いきなり「いい感じの席を予約して」と大きく依頼するのではなく、まずは tool ごとに小さくテストします。小さく確認しておくと、うまく動かないときにどこで詰まっているか切り分けやすくなります。

### テスト前に確認する

次の状態になっていることを確認します。

- 席予約サイトをブラウザで開いている
- Chrome の WebMCP flag が有効になっている
- WebMCP bridge 拡張機能が有効になっている
- Antigravity CLI を `agy` で起動している
- 席予約サイトのページを再読み込みしている

席予約サイトは次の URL で開いている想定です。

```text
http://localhost:8000
```

Chrome DevTools の Console に次のログが出ていれば、命令型 WebMCP の `webmcp.js` は読み込まれています。

```text
[webmcp] all imperative tools registered
```

> **Troubleshooting:** `document.modelContext.registerTool が見つかりません。` と表示される場合は、Chrome flag、拡張機能、Antigravity CLI の起動状態を確認してください。確認後、席予約サイトのページを再読み込みします。

### 接続確認として `ping` を呼び出す

まず、命令型 WebMCP の登録経路が動いているかを確認します。

Antigravity に次のように聞きます。

```text
WebMCP の ping tool を呼び出してください。
```

**期待される結果:**

- `ping` tool が呼び出される
- `message: "pong"` が返る
- `pageTitle` に席予約サイトのタイトルが入る

`ping` が動けば、Antigravity からブラウザ内の WebMCP tool を呼び出す経路は動いています。

### 読み取り tool を確認する

次に、予約データを読む tool を確認します。

まず `seat_summary` を呼び出します。

```text
WebMCP の seat_summary tool を呼び出して、現在の席のサマリーを教えてください。
```

**期待される結果:**

- `total`
- `available`
- `reserved`
- `disabled`

のような集計値が返ります。

続けて `seat_list` を呼び出します。

```text
WebMCP の seat_list tool を呼び出して、空席を5つ教えてください。
```

**期待される結果:**

- 席ごとの一覧が取得される
- `status: "available"` の席が候補として返る
- 予約や解除は行われない

さらに、参加者 ID を指定して `my_reservation` を呼び出します。`your-connpass-id` は自分の connpass ID に置き換えてください。

```text
WebMCP の my_reservation tool を使って、参加者ID your-connpass-id の予約状況を確認してください。
```

予約があれば `reservation.seatId` が返り、予約がなければ `reservation: null` が返ります。

### 宣言型 tool で予約する

ここで、宣言型 WebMCP として実装した `reserve_seat` を確認します。

まず `seat_list` の結果から、空いている席を 1 つ選びます。たとえば `A-1` が空いている場合、Antigravity に次のように聞きます。

```text
WebMCP の reserve_seat tool を使って、参加者ID your-connpass-id で A-1 を予約してください。
```

**期待される結果:**

- `reserve_seat` tool が呼び出される
- 予約フォームに参加者 ID と席番号が入る
- `toolautosubmit` により、フォームが自動送信される
- 予約後、座席マップと席一覧の状態が変わる

予約できたか確認するには、もう一度 `my_reservation` を呼び出します。

```text
WebMCP の my_reservation tool を使って、参加者ID your-connpass-id の予約状況を確認してください。
```

`reservation.seatId` に予約した席が入っていれば成功です。

> **Warning:** すでに予約済みの席を指定すると、予約は失敗します。その場合は `seat_list` で空席を探し直してください。

### 状態変更 tool で解除する

最後に、命令型の状態変更 tool である `cancel_reservation` を確認します。

予約がある参加者 ID で、次のように聞きます。

```text
WebMCP の cancel_reservation tool を使って、参加者ID your-connpass-id の予約を解除してください。
```

**期待される結果:**

- `cancel_reservation` tool が呼び出される
- 予約が解除される
- 座席マップと席一覧が更新される
- 「自分の予約」表示が「予約はありません。」になる

解除後、もう一度 `my_reservation` で確認します。

```text
WebMCP の my_reservation tool を使って、参加者ID your-connpass-id の予約状況を確認してください。
```

`reservation: null` が返れば、解除は成功です。

### うまく動かないとき

tool が見えない、または呼び出せない場合は、次の順番で確認します。

| 症状 | 確認すること |
| --- | --- |
| WebMCP tool が見えない | `agy` が起動しているか、拡張機能が有効か、ページを再読み込みしたか |
| `document.modelContext` がない | Chrome flag が有効か、Chrome を再起動したか |
| `getSeats is not defined` | `webmcp.js` が `app.js` より後に読み込まれているか |
| 予約が失敗する | 指定した席が空席か、参加者 ID が正しいか |
| 解除が失敗する | その参加者 ID に予約があるか |

それでも動かない場合は、TA に画面を見てもらってください。特に拡張機能、Chrome flag、Antigravity CLI の接続まわりは、見た目だけでは原因が分かりにくいことがあります。

ここまで確認できれば、WebMCP tool の個別テストは完了です。次のステップでは、全員で同時に Agent に予約を依頼し、リアルタイムに席が埋まっていく様子を体験します。
