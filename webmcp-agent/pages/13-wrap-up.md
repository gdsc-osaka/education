## まとめと次のステップ

Duration: 0:06:00

![宣言型 WebMCP、命令型 WebMCP、Antigravity、席予約体験を振り返る図](img/page13-wrap-up.svg)

このコードラボでは、席予約サイトに WebMCP の入口を追加し、Antigravity CLI から Web ページの機能を tool として呼び出しました。

最後に、今日作ったものと、次に試せることを整理します。

### 作ったものを振り返る

このハンズオンでは、既存の席予約サイトに対して、次の WebMCP tool を追加しました。

| tool | 種類 | 役割 |
| --- | --- | --- |
| `reserve_seat` | 宣言型 | 予約フォームを tool として公開し、参加者 ID と席 ID で予約する |
| `ping` | 命令型 | 命令型 WebMCP の登録経路が動いているか確認する |
| `seat_summary` | 命令型 | 合計席数、空席数、予約済み数などを取得する |
| `seat_list` | 命令型 | 全席の状態を取得し、Agent が候補を探せるようにする |
| `my_reservation` | 命令型 | 指定した参加者 ID の予約状態を確認する |
| `cancel_reservation` | 命令型 | 指定した参加者 ID の予約を解除する |

これらの tool により、Agent は画面上のボタンや入力欄を手探りで操作するのではなく、「席一覧を取得する」「空席を選ぶ」「予約する」「予約を確認する」といった意味のある単位で Web ページを扱えるようになりました。

### 宣言型 WebMCP と命令型 WebMCP

宣言型 WebMCP では、HTML フォームに metadata を追加しました。

`reserve_seat` は、もともと存在していた予約フォームを tool として見せる形でした。参加者 ID と席 ID を入力して送信する、というフォームの構造がそのまま tool の入力になります。今回の拡張機能では `toolautosubmit` を使い、Agent が値を埋めたあとにフォームを自動送信できるようにしました。

命令型 WebMCP では、`webmcp.js` から `document.modelContext.registerTool()` を呼び出しました。

`seat_summary` や `seat_list` のように既存の JavaScript 関数を呼び出して結果を整える処理、`my_reservation` のように画面状態と API 呼び出しを組み合わせる処理、`cancel_reservation` のように状態を変更する処理は、JavaScript で tool を登録する命令型の方が書きやすくなります。

読み取り専用の tool には `readOnlyHint: true` を付けました。予約解除のように状態を変える tool では、読み取り専用ではないことが分かるようにしました。

### 今回の構成をもう一度見る

WebMCP の主な想定は、ブラウザ側の Agent が、表示中の Web ページから tool を見つけて呼び出すことです。

今回のハンズオンでは、ブラウザ内蔵 Agent そのものではなく、次のような構成で WebMCP tool を体験しました。

1. 席予約サイトが WebMCP tool を公開する
2. Chrome 拡張機能がページ上の WebMCP 情報を読み取る
3. MCP bridge が Chrome と Antigravity CLI をつなぐ
4. Antigravity CLI の Agent が tool を呼び出す

この構成により、WebMCP の本来の方向性に近い体験を、今日の環境で試しました。Web ページ側が tool を用意し、Agent 側がそれを使って予約状況を読み取り、必要な操作を実行しました。

### 次に試すこと

時間があれば、次のような改善を試せます。

- tool の `description` を変えて、Agent の使い方がどう変わるか確認する
- `inputSchema` の説明をより具体的にして、入力ミスを減らす
- 返す JSON の形を変えて、Agent が判断しやすい出力を考える
- 読み取り専用 tool と状態変更 tool の境界を見直す
- 別のフォームや別の Web アプリにも WebMCP の入口を追加する
- [WebMCP Draft Community Group Report](https://webmachinelearning.github.io/webmcp/) を読んで、今回使った API と仕様上の位置づけを確認する

特に、tool の名前、説明、入力 schema、返すデータは Agent の判断に強く影響します。同じ処理でも、metadata の書き方が変わると Agent の選び方や説明の仕方が変わります。

### お疲れさまでした

これで、WebMCP を使って席予約サイトを AI エージェントから呼び出すハンズオンは完了です。

今日のポイントは、Web ページの機能を Agent に推測させるのではなく、ページ側から構造化された tool として見せることでした。

WebMCP はまだ実験段階の仕様ですが、Web アプリと AI Agent がより自然につながるための重要な入口です。今日作った小さな席予約 tool を出発点に、別の Web アプリではどんな機能を tool として見せられるか考えてみてください。
