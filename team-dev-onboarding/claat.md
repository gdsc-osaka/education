summary: チーム開発に参加するための事前準備とハンズオン (clone → PR まで)
id: team-dev-onboarding
categories: Web, 入門, GitHub, React
environments: Web
status: Draft
author: GDG on Campus University of Osaka

# Web アプリ チーム開発 はじめの一歩

## Codelab の概要
Duration: 0:05:00

この Codelab では、Web アプリのチーム開発に**初めて参加する人**を対象に、開発に必要なツールのインストールから、実際に Pull Request（PR）を 1 回出すまでの流れを体験します。

座学のスライドだけでは細かい手順までは追いきれないので、こちらの Codelab に沿って**自分のペースで**手を動かしてみてください。

**この Codelab で達成すること:**
* チーム開発に必要なツール（Git, Node.js, VS Code）が動く状態を作る
* GitHub アカウントを準備する
* リポジトリを clone してブランチを切る
* React のコードを少しだけ編集して、ブラウザで確認する
* commit → push → Pull Request の流れを 1 周経験する

**必要なもの:**
* インターネットに接続された PC（Windows または macOS）
* メールアドレス（GitHub アカウント作成用）
* 受信できる電話番号 or 認証アプリ（GitHub の 2 段階認証用）

> **Note:** すべてを完璧に理解する必要はありません。「だいたい流れが分かる」「困ったときに何を聞けばいいか分かる」状態を目指しましょう。

## STEP 1: 事前準備の全体像
Duration: 0:05:00

ハンズオンを始める前に、以下のツール / アカウントを揃えておきます。**できれば前日まで**に終わらせておくと当日スムーズです。

| # | 準備するもの | 確認コマンド |
| - | --------- | -------- |
| 1 | GitHub アカウント | ブラウザでログインできる |
| 2 | Git | `git --version` |
| 3 | Node.js | `node --version` |
| 4 | VS Code | アプリを起動できる |
| 5 | ターミナル | 開いてコマンドが打てる |

それぞれのインストール手順を以下で詳しく説明します。

> **Tip:** すでにインストール済みの場合は、確認コマンドを打って表示されればスキップして構いません。バージョンが古い場合のみアップデートしてください。

## STEP 2: GitHub アカウントを準備する
Duration: 0:10:00

チーム開発のコード共有・PR レビュー・履歴管理は GitHub を中心に行います。

### アカウントを作る（未作成の人）
1. ブラウザで [https://github.com/signup](https://github.com/signup) を開きます。
2. 画面の指示に従って **メールアドレス**、**パスワード**、**ユーザー名** を入力します。
   * ユーザー名は半角英数字とハイフンのみ。**今後ずっと使う名前**になるので、本名ベース or 普段使うハンドルネームなどがおすすめです。
3. 登録したメールアドレスに 8 桁の認証コードが届くので、画面に入力します。
4. プランは **Free** で OK です。

### ログインできることを確認する
1. ブラウザで [https://github.com/](https://github.com/) を開きます。
2. 右上にアイコンが表示されていれば、ログイン済みです。

### 2 段階認証（2FA）を有効にする
2023 年以降、GitHub では 2 段階認証が**必須**です。後で push のときに詰まらないように先に設定しておきましょう。

1. 右上のアイコン → **Settings** をクリック。
2. 左メニューから **Password and authentication** を選択。
3. **Two-factor authentication** の項目で **Enable two-factor authentication** をクリック。
4. 「Authenticator app（認証アプリ）」を選ぶのがおすすめです。
   * スマホに **Google Authenticator** や **Authy** などを入れて QR コードを読み取ります。
5. 表示されたリカバリーコードは**必ず保存**しておきましょう。スマホを失くした時の命綱です。

> **Warning:** リカバリーコードを失くすと、アカウントに二度とログインできなくなる可能性があります。テキストファイルに保存する、印刷する、パスワードマネージャに入れるなど、必ず保管してください。

## STEP 3: Git をインストールする
Duration: 0:15:00

Git はコードのバージョン管理ツールです。OS ごとに手順が違うので、自分の環境を選んで進めてください。

### Windows の場合
1. [https://git-scm.com/download/win](https://git-scm.com/download/win) にアクセスします。
2. 自動でインストーラのダウンロードが始まります（始まらなければページのリンクをクリック）。
3. ダウンロードした `.exe` ファイルをダブルクリックして起動します。
4. インストールオプションは**基本的にデフォルトで OK** ですが、以下だけ確認してください。
   * **Adjusting your PATH environment** → "Git from the command line and also from 3rd-party software" を選択
   * **Default editor** → 普段使うエディタ（迷ったら "Use Visual Studio Code as Git's default editor"）
   * **Default branch name** → "Override the default branch name for new repositories" にチェックし、`main` を入力
5. 残りは **Next** を押し続けて **Install** をクリック。

### macOS の場合
macOS には Git が同梱されていますが、最新版を入れるには **Homebrew** がおすすめです。

**Homebrew 未インストールの場合（先にこちら）:**
1. ターミナル（後述の STEP 6 で開き方を説明）を開きます。
2. 以下のコマンドを貼り付けて実行します。
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
3. パスワードを聞かれたら、Mac のログインパスワードを入力（入力中は何も表示されませんが、ちゃんと入力されています）。
4. 完了後、画面の指示に従って `eval "$(/opt/homebrew/bin/brew shellenv)"` などの行をターミナルに貼り付けて実行します。

**Git を入れる:**
```bash
brew install git
```

> **Note:** Homebrew を使わない場合、macOS に最初から入っている Git でも今日のハンズオンには十分です。コマンドラインで `git --version` が動けば OK。

### インストール確認
ターミナル（Mac）または PowerShell / コマンドプロンプト（Windows）を開いて、以下を実行します。

```bash
git --version
```

`git version 2.40.0` のように**バージョン番号が表示されたら成功**です。

### Git に名前とメールを設定する
コミットの履歴に残る情報なので、最初に設定しておきましょう。

```bash
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
```

> **Tip:** メールアドレスは GitHub に登録したものと**同じ**にしておくと、PR で「あなたのアイコン」がコミットに紐づきます。プライベートにしたい人は GitHub の Settings → Emails で `xxxxx+username@users.noreply.github.com` 形式のアドレスを取得できます。

> **Troubleshooting:** `git: command not found` と出た場合、インストールが完了していないか、PATH が通っていません。ターミナルを一度閉じて開き直してから試してみてください。それでもダメなら経験者を呼びましょう。

## STEP 4: Node.js をインストールする
Duration: 0:10:00

Node.js は JavaScript を**ブラウザ以外**で動かすためのランタイムです。今日触る React のビルドや開発サーバー（`npm run dev`）で使います。

### バージョンの選び方
2 種類のバージョンが配布されていますが、迷ったら **LTS（Long Term Support）版** を選んでください。

### Windows / macOS 共通の手順
1. [https://nodejs.org/](https://nodejs.org/) にアクセスします。
2. **LTS** と書かれた緑色のボタンをクリックしてインストーラをダウンロードします。
3. ダウンロードしたファイルを開き、画面の指示通りに **Next** / **続ける** を押していきます。
4. 最後に **Install** / **インストール** をクリック。

### macOS で Homebrew を使う場合
```bash
brew install node
```

### インストール確認
ターミナル / PowerShell を**一度閉じて開き直して**から、以下を実行します。

```bash
node --version
npm --version
```

`v20.x.x` のような表示が両方とも出れば成功です。

> **Troubleshooting:** `node: command not found` が出るときは、ターミナルの再起動が一番効きます。それでもダメな場合は PC 自体を再起動してみてください。

## STEP 5: VS Code をインストールする
Duration: 0:10:00

コードを書くためのエディタです。チーム開発では拡張機能が豊富な VS Code が定番です。

### インストール手順
1. [https://code.visualstudio.com/](https://code.visualstudio.com/) にアクセスします。
2. 自分の OS に合ったボタン（**Download for Windows** / **Download for macOS**）をクリックします。
3. ダウンロードしたファイルを開いてインストールします。
   * Windows: インストーラを実行。「**PATH への追加**」のチェックは入れたままにしておきましょう（デフォルトで ON）。
   * macOS: ダウンロードした `.zip` を解凍し、出てきた **Visual Studio Code.app** を **Applications フォルダ** にドラッグ＆ドロップします。

### おすすめ拡張機能（任意）
VS Code を起動して、左の四角アイコン（拡張機能）から以下を検索してインストールしておくと便利です。

* **Japanese Language Pack** — メニューを日本語化
* **ESLint** — JavaScript のミスを赤線で教えてくれる
* **Prettier** — 保存時に自動整形
* **GitLens** — Git の履歴をエディタ内で見やすく表示

> **Note:** 拡張機能はあとから追加できます。今日は無理して入れなくても OK です。

## STEP 6: ターミナルを開けるようにする
Duration: 0:05:00

「ターミナル」とは、コマンドを打つための黒い画面のことです。Git / npm は基本的にここから操作します。

### macOS の場合
* **Spotlight**（Cmd + Space）を開いて `Terminal` と入力 → Enter
* または **Launchpad** → **その他** → **ターミナル**

### Windows の場合
* **スタートメニュー** で `PowerShell` と検索して起動するのがおすすめ
* または **Windows Terminal**（Windows 11 では標準搭載）

### 最低限のコマンド
| コマンド | 役割 |
| ------ | ---- |
| `pwd` | 今いるフォルダの場所を表示 |
| `ls` (Mac) / `dir` (Windows) | 今いるフォルダのファイル一覧 |
| `cd フォルダ名` | フォルダに移動 |
| `cd ..` | 一つ上のフォルダに戻る |
| `Ctrl + C` | 動いているコマンドを止める |

> **Tip:** `Ctrl + C` は**最強の脱出ボタン**です。何か変なコマンドを実行してしまったとき、固まったときは押せば大抵抜けられます。

これで事前準備は完了です！ここからは当日のハンズオンに入ります。

## STEP 7: リポジトリを clone する
Duration: 0:10:00

ここからが当日のハンズオンです。まずは GitHub にあるリポジトリを自分の PC にコピー（clone）します。

### 作業フォルダの場所を決める
clone したリポジトリは PC のどこかに置かれます。**自分が分かる場所**に置きましょう（例: `~/dev` や Documents の中）。

ターミナルで作業フォルダに移動しておきます。

**macOS の例:**
```bash
mkdir -p ~/dev
cd ~/dev
```

**Windows (PowerShell) の例:**
```powershell
mkdir $HOME\dev -Force
cd $HOME\dev
```

### clone する
以下のコマンドを実行します。

```bash
git clone https://github.com/gdsc-osaka/react-example.git
cd react-example
```

成功すると、`react-example` というフォルダが作られ、その中に移動できます。`ls`（または `dir`）でファイル一覧を見て、`package.json` や `src` フォルダがあれば成功です。

> **Troubleshooting:** `Permission denied` や `fatal: unable to access ...` が出る場合、ネットワーク（Wi-Fi）に繋がっているか確認してください。社内 / 学内ネットワークで proxy がある場合は経験者に相談しましょう。

## STEP 8: 自分のブランチを切る
Duration: 0:05:00

`main` ブランチで作業すると、チーム全員の作業がぶつかって大事故になります。**作業前に必ず**自分専用のブランチを作りましょう。

### ブランチを作る
```bash
git switch -c feature/add-<your-name>
```

`<your-name>` の部分は自分の名前（半角英数字）に置き換えてください。

例: 自分の名前が `taro` なら…
```bash
git switch -c feature/add-taro
```

### 今どのブランチにいるか確認する
```bash
git status
```

最初の行に `On branch feature/add-taro` のように表示されていれば成功です。

> **Note:** ブランチ名は `feature/<何をするか>` の形が分かりやすいです。今日は名前を入れる作業なので `feature/add-<名前>` にしています。

## STEP 9: 開発サーバーを起動する
Duration: 0:10:00

依存パッケージをインストールして、React の開発サーバーを立ち上げます。

### 依存パッケージをインストールする
```bash
npm install
```

`package.json` に書かれたライブラリをまとめてダウンロードします。1〜3 分かかります。

途中で `WARN` がたくさん出ますが、最後に `npm warn` 以外のエラーで止まっていなければ OK です。

### 開発サーバーを起動する
```bash
npm run dev
```

成功すると、ターミナルに以下のような表示が出ます。

```text
  VITE v5.x.x  ready in 312 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
  ➜  press h + enter to show help
```

### ブラウザで開いてみる
ブラウザで [http://localhost:5173](http://localhost:5173) にアクセスしてみましょう。`Participants` というタイトルと、`Alice` だけが表示されたリストが見えれば成功です。

> **Tip:** `npm run dev` で起動した開発サーバーは**起動したまま**にしておきます。ファイルを保存すると自動的にブラウザが更新される（HMR）ので、編集中はずっと立ち上げておくのが便利です。

> **Troubleshooting:** ポート 5173 が既に使われているとエラーが出ることがあります。`Ctrl + C` でいったん止めて、他の `npm run dev` が動いていないか確認してください。

## STEP 10: コードを編集する
Duration: 0:10:00

実際にコードを 1 行追加して、自分の名前を画面に出してみましょう。

### App.jsx を開く
VS Code を起動して、先ほど clone した `react-example` フォルダを開きます。

* **File（ファイル）** → **Open Folder（フォルダーを開く）** から `react-example` を選択
* または、ターミナルから `code .` を実行（VS Code のコマンドが PATH に通っていれば）

開いたら、左のサイドバーから `src/App.jsx` を選んでください。

### 自分の名前を追加する
以下のような `participants` 配列があります。

```jsx
function App() {
  const participants = [
    'Alice',
  ]
  // ...
}
```

ここに自分の名前を**配列の要素として**追加します。

```jsx
function App() {
  const participants = [
    'Alice',
    'YOUR_NAME',  // ← この行を追加
  ]
  // ...
}
```

`'YOUR_NAME'` の部分は自分の名前に書き換えてください。**シングルクォート `'` と末尾のカンマ `,` を忘れずに!**

### 保存する
* Windows: `Ctrl + S`
* macOS: `Cmd + S`

### ブラウザで確認する
`npm run dev` を起動したままなら、ブラウザのタブに切り替えるだけで自動的にリロードされ、リストに自分の名前が増えているはずです。

> **Troubleshooting:** 画面が真っ白になった、エラー画面（赤い枠）が出た、という場合は、編集ミスの可能性が高いです。
> - クォート `'` の閉じ忘れ
> - カンマ `,` の位置ミス
> - 全角スペース・全角クォートの混入
>
> ブラウザを開いた状態で **F12** を押して DevTools の **Console** タブを見ると、エラーの内容が赤文字で出ています。それをそのままコピーして AI に貼り付けると原因が分かりやすいです。

## STEP 11: 変更を commit する
Duration: 0:05:00

ここまでの変更を Git に記録（commit）します。

### 変更内容を確認する
```bash
git status
```

`modified: src/App.jsx` のように表示されれば、Git は「App.jsx が変わったよ」と認識しています。

差分の中身を見たい場合は以下も使えます。
```bash
git diff
```

`Ctrl + C` ではなく **`q`** キーで抜けられます（`less` というコマンドが効いている状態のため）。

### ステージング → commit
```bash
git add src/App.jsx
git commit -m "feat: add <your-name> to participants"
```

`<your-name>` は自分の名前に置き換えてください。

> **Tip:** コミットメッセージは「**何をしたか**」を短く書きます。
> - `feat:` 新機能の追加
> - `fix:` バグ修正
> - `docs:` ドキュメントの修正
>
> このプレフィックスは「Conventional Commits」と呼ばれる慣習で、多くのチームで使われています。

> **Troubleshooting:** `Please tell me who you are` というエラーが出た場合は、STEP 3 の `git config --global user.name / user.email` を実行し忘れています。設定してから再度 commit してください。

## STEP 12: GitHub に push する
Duration: 0:10:00

自分の PC で作った commit を、GitHub のサーバーに送ります。

### 初回 push
```bash
git push -u origin feature/add-<your-name>
```

`-u origin <ブランチ名>` を最初の 1 回だけ付けます。これで「ローカルのブランチを GitHub のどのブランチと連携させるか」が記録され、2 回目以降は `git push` だけで OK になります。

### 認証を求められたら
- ブラウザが自動で開き、GitHub のログインを求められることがあります。表示に従って **Authorize** をクリックしてください。
- HTTPS + パスワード方式は 2021 年から廃止されています。**Personal Access Token（PAT）** または **GitHub CLI / ブラウザ認証** を使います。

**もし PAT を求められた場合の作り方:**
1. ブラウザで [https://github.com/settings/tokens](https://github.com/settings/tokens) を開きます。
2. **Generate new token** → **Generate new token (classic)** をクリック。
3. **Note** に何用か書く（例: `react-example-push`）、**Expiration** を 30 日くらいに設定。
4. **Scopes** で `repo` にチェック。
5. **Generate token** をクリック → 表示されたトークンをコピー（**この画面を閉じると二度と見れません**）。
6. push のときにパスワードを聞かれたら、このトークンを貼り付けます。

### 確認
ブラウザで [https://github.com/gdsc-osaka/react-example](https://github.com/gdsc-osaka/react-example) を開いて、自分のブランチ（`feature/add-<your-name>`）が一覧に出ていれば成功です。

> **Troubleshooting:** `Permission denied` が出る場合、リポジトリに push する権限がない可能性があります。経験者に「コラボレーターに追加してください」と頼みましょう。

## STEP 13: Pull Request を作成する
Duration: 0:10:00

いよいよ最後のステップ、Pull Request（PR）を作ります。PR は「自分のブランチの変更を main に取り込んでほしい」というリクエストです。

### PR 作成画面を開く
push 直後、GitHub のリポジトリページを開くと、画面の上部に黄色いバナーで以下のような表示が出ます。

```
feature/add-taro had recent pushes  [ Compare & pull request ]
```

**Compare & pull request** ボタンをクリックしてください。

> **Note:** バナーが出ない場合は、リポジトリ上部の **Pull requests** タブ → **New pull request** からも作成できます。`base: main` ← `compare: feature/add-<your-name>` を選びましょう。

### タイトルと説明を書く
* **タイトル**: コミットメッセージが自動で入りますが、必要なら短く分かりやすく直します（例: `Add taro to participants`）
* **Description（説明欄）**: 以下のテンプレを参考に書いてみてください。

```markdown
## やったこと
- participants 配列に自分の名前を追加

## 動作確認
- npm run dev でブラウザに自分の名前が表示されることを確認
```

### Create pull request をクリック
画面下の緑のボタンをクリックすれば PR 完成です！

PR が作成されると、URL は `https://github.com/gdsc-osaka/react-example/pull/<番号>` のようになります。これを Discord / Slack でチームに共有してレビューを依頼しましょう。

> **Tip:** PR には「なぜその変更が必要だったか」が書かれていると、レビュアーがとても助かります。今日は練習なので簡単で OK ですが、本番では「目的」「変更内容」「動作確認」を書く習慣をつけましょう。

## STEP 14: お疲れさまでした！
Duration: 0:05:00

ここまでで、チーム開発の基本的な 1 サイクルを体験できました！

```text
clone → branch → 編集 → commit → push → PR
```

### 今日身についたこと
* ✅ Git / Node.js / VS Code が動く環境
* ✅ GitHub に自分のブランチを push できる
* ✅ Pull Request を作れる
* ✅ エラーが出たら DevTools / ターミナルを見るクセ

### 次に学ぶと良いこと
* **コードレビュー**: 他の人の PR を読んでコメントしてみる
* **merge conflict の解消**: 同じファイルを別の人が同時に編集したときの対処
* **git pull / fetch の違い**: 最新を取ってくる正しい手順
* **React の基礎**: コンポーネント / state / props

### 困ったときの心得
1. **エラー文を読む**（赤文字の 1 行目から）
2. **スクショを撮る**（要約しない、そのまま貼る）
3. **AI に聞く**（テンプレに沿って、状況・エラー全文・試したことを書く）
4. **10〜30 分**自分で粘る
5. 進まなければ**経験者**に画面ごと見せて相談

> **最重要:** 30 分詰まったら、迷わず人に聞きましょう。「壊した、分からない」を**隠さない**チームが一番強いです。

ようこそ、チームへ！🎉
