# WebMCP × ADK/A2A 座席予約ハンズオン テンプレート

イベント座席予約サイト（素のHTML/CSS/JS）に WebMCP の**命令型API**と**宣言型API**の両方を実装し、
Google ADK × A2A のマルチエージェントがそのWebMCPを使って実際に座席を予約するまでを、
このリポジトリに残った `# TODO:` の箇所を埋めながら組み立てていくハンズオン用テンプレートです。

> 詳しい実装手順は、今後配布するcodelab（claat）を参照してください。このREADMEは
> 「何が既に動くか」「どこを実装するか」の地図として使ってください。

## 留意点: WebMCPは実験的な仕様です

WebMCPは2026年7月時点でもW3C勧告ではなく、[W3C Web Machine Learning Community Group](https://github.com/webmachinelearning/webmcp) のドラフト（incubation）です。
Chromeでの実験実装やOrigin Trialが進行中ですが、本ハンズオンでは **[`@mcp-b/global`](https://github.com/WebMCP-org/npm-packages) ポリフィル**を使うため、
`chrome://flags` の有効化やOrigin Trialトークンの取得は**不要**です。通常のモダンブラウザでそのまま動きます。

## 構成と、今の状態

```
booking-api/    運営用予約API（Hono）。60席のシード + 予約 + 管理者リセット (:3001)  ← 完成済み
admin/          運営用管理フロント（React/Vite）。パスワードで座席リセット (:5174)   ← 完成済み
web/            素のHTML/CSS/JS予約サイト (:4000)                              ← WebMCP部分だけ未実装
agents/         Google ADK × A2A マルチエージェント
  shared/       ランキング・リトライ判定などのPython helper                     ← コア関数が未実装
  coordinator/  root Workflow                                              ← 全ファイル未実装
  seat_finder/  命令型WebMCPで空席を取得するspecialist (:8101)                  ← 未実装
  location/     「場所」の適合度を評価するspecialist (:8102)                    ← 未実装
  price/        「値段」の適合度を評価するspecialist (:8103)                    ← 未実装
  effect/       「効果」(タグ)の適合度を評価するspecialist (:8104)               ← 未実装
  reservation/  宣言型WebMCPで実際に予約するspecialist (:8105)                  ← 未実装
```

`booking-api/` と `admin/` は運営インフラとして最初から完成しており、変更不要です。
`web/` は座席一覧表示・人間による予約操作などサイトの基本機能は既に完成しており、
WebMCP（命令型/宣言型）の実装だけが残っています。`agents/` は骨組み（ファイル・関数の
シグネチャ）だけがあり、中身をこれから実装します。

`web/` と `agents/` は `booking-api` を唯一のデータソースとして共有します。複数の参加者PCが
それぞれ `web/` を起動しても、`booking-api` を1箇所（運営のPC等）で起動してそのURLを
`web/public/config.js` の `BOOKING_API_BASE_URL` と `admin/.env` の `VITE_BOOKING_API_URL` に
配れば、全員が同じ60席を奪い合う構成にできます。ローカルで動作確認する場合はデフォルトの
`http://localhost:3001` のままで構いません。

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

```bash
make run-booking-api  # http://localhost:3001 の運営用予約API（すぐ使える）
make run-admin        # http://localhost:5174 の運営用管理フロント（すぐ使える）
make run-web          # http://localhost:4000 の予約サイト（WebMCP実装前でも座席表示・人間の予約は動く）
```

`agents/` 配下は `# TODO:` を実装するまでは動きません。`make run-specialists` /
`make run-coordinator` / `make web`（ADK Web UI）は、それぞれのファイルを実装した後に
動作確認として使ってください。

## これから実装する場所（TODO一覧）

### 1. WebMCP（`web/`）

| ファイル | 実装すること |
|---|---|
| `web/public/index.html` | 予約フォーム`<form>`に宣言型WebMCP属性(`toolname`/`tooldescription`/`toolautosubmit`)、各`<input>`に`toolparamdescription`を追加する |
| `web/public/app.js` | `registerImperativeWebMcpTools()` 内で `list_available_seats` / `get_seat_detail` / `list_reservations` の3つの命令型ツールを `document.modelContext.registerTool()` で登録する |

### 2. ランキング・判定ロジック（`agents/shared/`）

| ファイル | 実装すること |
|---|---|
| `preference.py` | `normalize_preference()` — 希望をSeatPreferenceに揃え、語彙をクランプする |
| `scoring.py` | `score_and_rank()` — 3軸スコアを集計し降順ランキングする（最重要方針の核心） |
| `reservation.py` | `confirm_reservation()`, `build_success_message()`, `build_failure_message()` |

### 3. Agent / A2A配線（`agents/`）

| ファイル | 実装すること |
|---|---|
| `seat_finder/agent.py` | 命令型WebMCPツールで空席を取得するAgent (:8101) |
| `location/agent.py` | 「場所」の適合度を1-10で採点するAgent (:8102) |
| `price/agent.py` | 「値段」の適合度を1-10で採点するAgent (:8103) |
| `effect/agent.py` | 「効果」(タグ)の適合度を1-10で採点するAgent (:8104) |
| `reservation/agent.py` | 宣言型`reserve_seat`＋命令型`list_reservations`で予約するAgent (:8105) |
| `coordinator/parse.py` | `preference_parser_agent` と `normalize_preference_node` |
| `coordinator/candidates.py` | `seat_finder_remote`(RemoteA2aAgent) と `coerce_candidates` |
| `coordinator/evaluation.py` | location/price/effectの3specialistをRemoteA2aAgentとして定義し、`asyncio.gather`で並列に呼び出す `evaluate_axes` |
| `coordinator/reservation_flow.py` | `reservation_remote`(RemoteA2aAgent) とリトライループ `reserve_with_retry` |
| `coordinator/explain.py` | `explainer_agent` と `build_explainer_input` |
| `coordinator/agent.py` | 上記すべてを繋ぐ `root_agent = Workflow(edges=[...])` と `app = to_a2a_app(...)` |

## 運営用管理フロント（admin/）

`http://localhost:5174` を開き、`booking-api/.env` に設定した `ADMIN_PASSWORD`
（デフォルト: `gdg-io-osaka-2026`）を入力するとログインできます。ログイン後は:

- 60席の空席/予約済み状況と予約一覧を3秒ごとに自動更新で確認できる
- 「全座席をリセット」ボタンで、全予約を消して初期状態（60席、うち3席は予約済み）に戻せる

複数回ハンズオンを回す場合、参加者のセッションの間にこのボタンでリセットすることを想定しています。

## 設計方針（最重要・実装時に必ず守る）

- ランキング(`agents/shared/scoring.py`)、予約成功/失敗の判定・リトライ回数(`agents/shared/reservation.py`)、
  希望の正規化(`agents/shared/preference.py`)は**すべてPythonの決定的なコード**で行う。LLMの自由記述には頼らない。
- `coordinator/agent.py` の `Workflow(edges=[...])` はワークフローの**手順そのものをコードで表現**する。
  1つの大きな`instruction`でエージェントに手順を指示する構成にはしない。
- 各specialistは1つの仕事だけを持ち、`instruction`にはその仕事の説明のみを書く（次に何をするかは書かない）。

> `adk web` のアプリ一覧には `shared`（Python helper用ディレクトリ）も表示されますが、
> これはエージェントではないため選択しないでください。
