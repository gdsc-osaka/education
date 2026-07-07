# WebMCP × ADK/A2A 座席予約ハンズオン 完成例

イベント座席予約サイト（素のHTML/CSS/JS）に WebMCP の**命令型API**と**宣言型API**の両方を実装し、
Google ADK × A2A のマルチエージェントがそのWebMCPを使って実際に座席を予約するまでの完成例です。

## 留意点: WebMCPは実験的な仕様です

WebMCPは2026年7月時点でもW3C勧告ではなく、[W3C Web Machine Learning Community Group](https://github.com/webmachinelearning/webmcp) のドラフト（incubation）です。
Chromeでの実験実装やOrigin Trialが進行中ですが、本ハンズオンでは **[`@mcp-b/global`](https://github.com/WebMCP-org/npm-packages) ポリフィル**を使うため、
`chrome://flags` の有効化やOrigin Trialトークンの取得は**不要**です。通常のモダンブラウザでそのまま動きます。

## 構成

```
booking-api/    運営用予約API（Hono）。60席のシード + 予約 + 管理者リセット (:3001)
admin/          運営用管理フロント（React/Vite）。パスワードで座席リセット (:5174)
web/            素のHTML/CSS/JS予約サイト（WebMCP実装済み） (:4000)
agents/         Google ADK × A2A マルチエージェント
  shared/       ランキング・リトライ判定などのPython helper（決定的、LLM不使用）
  coordinator/  root Workflow（手順は全てPythonコードで制御） (:8100)
  seat_finder/  命令型WebMCPで空席を取得するspecialist (:8101)
  location/     「場所」の適合度を評価するspecialist (:8102)
  price/        「値段」の適合度を評価するspecialist (:8103)
  effect/       「効果」(タグ)の適合度を評価するspecialist (:8104)
  reservation/  宣言型WebMCPで実際に予約するspecialist (:8105)
```

`web/` と `agents/` は `booking-api` を唯一のデータソースとして共有する。つまり
複数の参加者PCがそれぞれ `web/` を起動しても、`booking-api` を1箇所（運営のPC等）で
起動してそのURLを `web/public/config.js` の `BOOKING_API_BASE_URL` と
`admin/.env` の `VITE_BOOKING_API_URL` に配れば、全員が同じ60席を奪い合う構成にできる。
ローカルで動作確認する場合はデフォルトの `http://localhost:3001` のままで良い。

## セットアップ

```bash
cp .env.example .env
# .env の GOOGLE_API_KEY に Gemini APIキーを設定する
cp booking-api/.env.example booking-api/.env
# booking-api/.env の ADMIN_PASSWORD を運営で決めたパスワードに変更する（任意）
make setup
```

`agents/webmcp_tools.py` が起動する `@mcp-b/webmcp-local-relay` はエージェント実行時に
`npx` が自動的にダウンロード・実行します（Node.js 22.12+が必要）。

## 起動

まとめて起動する場合:

```bash
make run
```

個別に起動する場合:

```bash
make run-booking-api  # http://localhost:3001 の運営用予約API
make run-admin        # http://localhost:5174 の運営用管理フロント
make run-web          # http://localhost:4000 の予約サイト
make run-specialists  # seat_finder/location/price/effect/reservation (8101-8105)
make run-coordinator  # coordinator (8100)
make web              # ADK Web UI (http://localhost:8000)
```

`http://localhost:4000` を開いた状態（タブを閉じない）で ADK Web UI から `coordinator`
を選び、たとえば「前の方で静かで、5000円以下の席がいい」のように話しかけると、
実際にブラウザ側の座席が予約され、予約済み一覧に反映されます。

> `adk web` のアプリ一覧には `shared`（Python helper用ディレクトリ）も表示されますが、
> これはエージェントではないため選択しないでください。

## 運営用管理フロント（admin/）

`http://localhost:5174` を開き、`booking-api/.env` に設定した `ADMIN_PASSWORD`
（デフォルト: `gdg-io-osaka-2026`）を入力するとログインできる。ログイン後は:

- 60席の空席/予約済み状況と予約一覧を3秒ごとに自動更新で確認できる
- 「全座席をリセット」ボタンで、全予約を消して初期状態（60席、うち3席は予約済み）に戻せる

複数回ハンズオンを回す場合、参加者のセッションの間にこのボタンでリセットすることを想定している。
パスワードはリクエストヘッダ `x-admin-password` で毎回サーバー側でも検証されるため、
フロント側のログイン画面はあくまで簡易的なゲートで、実際の認可はAPI側で行っている。

## WebMCPの実装箇所

- **予約データの取得元**: `web/public/app.js` の `fetchSeats`/`fetchReservations`/`reserveSeat` は
  `web/public/config.js` の `BOOKING_API_BASE_URL`（デフォルト `http://localhost:3001`）に対して
  `fetch` する。WebMCPツールはこれらの関数をラップしているだけなので、データソースを
  booking-apiに変更してもWebMCP側の実装(命令型/宣言型)は変わらない。
- **命令型API** (`web/public/app.js`): `document.modelContext.registerTool()` で
  `list_available_seats` / `get_seat_detail` / `list_reservations` を登録。
- **宣言型API** (`web/public/index.html`): 予約フォームの `<form>` に
  `toolname` / `tooldescription` / `toolautosubmit`、各 `<input>` に `toolparamdescription` を付与。
- **ブリッジ**: `@mcp-b/global`（ポリフィル）→ アプリのロジック → `@mcp-b/webmcp-local-relay`
  (embed.js) の順でscriptを読み込み、`ws://127.0.0.1:9333` 経由でPython側のADKエージェントに
  ツールを公開する。Python側は `agents/webmcp_tools.py` で `McpToolset` + `StdioConnectionParams`
  を使い、`npx -y @mcp-b/webmcp-local-relay@latest` を起動して接続する。

## 設計方針（最重要）

- ランキング(`agents/shared/scoring.py`)、予約成功/失敗の判定・リトライ回数(`agents/shared/reservation.py`)、
  希望の正規化(`agents/shared/preference.py`)は**すべてPythonの決定的なコード**で行う。LLMの自由記述には頼らない。
- `coordinator/agent.py` の `Workflow(edges=[...])` はワークフローの**手順そのものをコードで表現**しており、
  1つの大きな`instruction`でエージェントに手順を指示する構成にはしていない。
- 各specialistは1つの仕事だけを持ち、`instruction`にはその仕事の説明のみを書く（次に何をするかは書かない）。
