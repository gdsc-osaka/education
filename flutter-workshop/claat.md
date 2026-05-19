summary: Flutter ワークショップ 事前準備ガイド
id: flutter-workshop-prep
categories: Flutter, Dart, Web
environments: Web
status: Published
author: GDG on Campus University of Osaka

# Flutter ワークショップ 事前準備ガイド

## はじめに
Duration: 0:02:00

このガイドでは、**Flutter ワークショップ当日までに済ませておく環境構築**をすべて説明します。

当日は次の 4 つのツールが揃っていれば参加できます。

| ツール | 用途 |
| --- | --- |
| Flutter SDK | アプリのビルド・実行 |
| Visual Studio Code | コードを書くエディタ |
| Google Chrome | アプリの実行先（Web ターゲット） |
| Git | リポジトリのクローン |

> **Notice:** 今回のワークショップは **Web (Chrome) のみ**をターゲットにします。Android エミュレータや iOS シミュレータは不要です。Xcode や Android Studio もインストールしなくて大丈夫です。

> **Tip:** 途中で詰まったら Discord の **`#260521-flutter-workshop`** チャンネルで質問してください！

---

## Chrome のインストール
Duration: 0:03:00

Flutter Web アプリの実行先として **Google Chrome** を使います。すでにインストール済みの方はスキップしてください。

1. [https://www.google.com/chrome/](https://www.google.com/chrome/) にアクセスします。
2. 「Chrome をダウンロード」ボタンをクリックします。
3. インストーラーを起動して画面の指示に従います。

インストール後、Chrome が起動することを確認してください。

---

## Git のインストール
Duration: 0:05:00

ワークショップのテンプレートリポジトリをクローンするために **Git** が必要です。

### macOS

macOS には Git が最初から入っているケースがほとんどです。ターミナルで次のコマンドを実行して確認してください。

```bash
git --version
```

`git version X.X.X` のような出力が出れば OK です。もしインストールを求めるダイアログが表示された場合は「インストール」を押して完了させてください（Xcode Command Line Tools が導入されます）。

### Windows

1. [https://git-scm.com/download/win](https://git-scm.com/download/win) から **Git for Windows** のインストーラーをダウンロードします。
2. インストーラーを起動し、すべての設定をデフォルトのまま「Next」を押し続けて「Install」をクリックします。
3. インストール完了後、**スタートメニュー → Git Bash** を開いて次のコマンドで確認します。

```bash
git --version
```

### Linux (Ubuntu / Debian)

```bash
sudo apt update
sudo apt install -y git
git --version
```

---

## Flutter SDK のインストール
Duration: 0:20:00

お使いの OS に合わせた手順を選んでください。

### macOS — Homebrew を使う（推奨）

Homebrew がインストールされていれば最も簡単です。

```bash
brew install --cask flutter
```

インストール完了後、新しいターミナルを開いて次のコマンドでバージョンを確認します。

```bash
flutter --version
```

`Flutter X.X.X` が表示されれば成功です。

---

### macOS — 手動インストール

Homebrew を使わない場合は以下の手順で行います。

**1. SDK をダウンロードする**

[https://docs.flutter.dev/get-started/install/macos/web](https://docs.flutter.dev/get-started/install/macos/web) にアクセスし、お使いの Mac に合ったアーカイブをダウンロードします。

- **Apple Silicon (M1/M2/M3/M4)** → `flutter_macos_arm64_stable.tar.xz`
- **Intel** → `flutter_macos_stable.tar.xz`

**2. 展開してインストールする**

```bash
# ホームディレクトリに development フォルダを作成
mkdir -p ~/development

# ダウンロードしたファイルを展開（ファイル名は実際のものに合わせてください）
tar xf ~/Downloads/flutter_macos_arm64_stable.tar.xz -C ~/development
```

**3. PATH を設定する**

`~/.zshrc` に次の行を追加します（テキストエディタで開くか、以下のコマンドを使ってください）。

```bash
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**4. インストールを確認する**

```bash
flutter --version
```

`Flutter X.X.X` が表示されれば成功です。

---

### Windows — winget を使う（推奨）

Windows 10 以降には **winget**（Windows パッケージマネージャー）が標準搭載されています。**PowerShell** または **コマンドプロンプト** を開いて以下を実行してください。

```powershell
winget install Google.Flutter
```

インストール完了後、**ターミナルを再起動**して確認します。

```powershell
flutter --version
```

`Flutter X.X.X` が表示されれば成功です。

---

### Windows — 手動インストール

**1. SDK をダウンロードする**

[https://docs.flutter.dev/get-started/install/windows/web](https://docs.flutter.dev/get-started/install/windows/web) にアクセスし、`flutter_windows_stable.zip` をダウンロードします。

**2. 展開する**

ダウンロードした zip ファイルを解凍し、`C:\flutter` に配置します。

> **Notice:** `C:\Program Files\` には置かないでください。管理者権限の問題でビルドが失敗することがあります。

**3. PATH を設定する**

1. スタートメニューで「環境変数」と検索し、「システム環境変数の編集」を開きます。
2. 「環境変数(N)...」ボタンをクリックします。
3. 「ユーザー環境変数」の `Path` をダブルクリックします。
4. 「新規(N)」をクリックして `C:\flutter\bin` を追加します。
5. すべてのダイアログで「OK」をクリックして閉じます。

**4. インストールを確認する**

新しい **PowerShell** を開いて確認します。

```powershell
flutter --version
```

`Flutter X.X.X` が表示されれば成功です。

---

### Linux (Ubuntu / Debian) — snap を使う（推奨）

```bash
sudo snap install flutter --classic
flutter --version
```

`Flutter X.X.X` が表示されれば成功です。

---

### Linux — 手動インストール

**1. SDK をダウンロードする**

[https://docs.flutter.dev/get-started/install/linux/web](https://docs.flutter.dev/get-started/install/linux/web) にアクセスし、`flutter_linux_stable.tar.xz` をダウンロードします。

**2. 展開してインストールする**

```bash
mkdir -p ~/development
tar xf ~/Downloads/flutter_linux_stable.tar.xz -C ~/development
```

**3. PATH を設定する**

```bash
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**4. インストールを確認する**

```bash
flutter --version
```

---

## VS Code のセットアップ
Duration: 0:07:00

コードを書くエディタとして **Visual Studio Code (VS Code)** を使います。

### VS Code のインストール

[https://code.visualstudio.com/](https://code.visualstudio.com/) にアクセスし、お使いの OS 向けのインストーラーをダウンロードしてインストールします。

### Flutter 拡張機能のインストール

VS Code を起動し、以下の手順で Flutter 拡張機能を追加します。

1. 左サイドバーの **拡張機能アイコン**（四角いブロックのマーク）をクリックします。
2. 検索ボックスに `Flutter` と入力します。
3. **Dart Code 作の「Flutter」** 拡張機能が上位に表示されるので、「インストール」をクリックします（Dart 拡張機能も自動でインストールされます）。

> **Tip:** Flutter 拡張機能をインストールすると、コードの補完・エラー検出・ホットリロードのボタンなど、開発に便利な機能がすべて有効になります。

---

## flutter doctor で環境を確認する
Duration: 0:05:00

Flutter SDK のインストールが正しくできているか確認します。ターミナルで次のコマンドを実行してください。

```bash
flutter doctor
```

出力の中で **Chrome の行に `[✓]`** が付いていれば、今回のワークショップに参加する準備は完了です。

```
[✓] Flutter (Channel stable, X.X.X, ...)
[✓] Chrome - develop for the web
```

> **Tip:** Android や iOS の行に `[✗]` や `[!]` が付いていても、今回は Web のみを使うため **まったく問題ありません**。無視して次のステップに進んでください。

> **Troubleshooting:** `flutter: command not found` と表示される場合は、PATH の設定が反映されていない可能性があります。ターミナルを完全に閉じて再度開いてから再試行してください。それでも解決しない場合は Discord でメンターに声をかけてください。

---

## リポジトリのクローンと動作確認
Duration: 0:05:00

ワークショップで使うテンプレートコードを手元にダウンロードして、アプリが起動できることを確認します。

ターミナルで以下のコマンドを順に実行してください。

```bash
git clone https://github.com/gdsc-osaka/flutter-workshop.git
cd flutter-workshop
flutter pub get
flutter run -d chrome
```

Chrome が自動で起動し、**「TODO: 投稿一覧を表示する」** という文字が画面に表示されれば成功です！

> **Troubleshooting:** `flutter pub get` でエラーが出た場合は、Flutter SDK のインストールが完了しているか `flutter --version` で再確認してください。

> **Troubleshooting:** Chrome が起動しない場合は、`flutter devices` を実行して Chrome がデバイス一覧に表示されているか確認してください。

最後に VS Code でフォルダを開いておきましょう。

```bash
code flutter-workshop
```

または VS Code のメニュー「**ファイル → フォルダーを開く**」から `flutter-workshop` フォルダを選択します。

---

## 準備完了！
Duration: 0:01:00

以上で事前準備はすべて完了です。当日お会いしましょう！

**チェックリスト:**

- [x] Google Chrome が起動できる
- [x] `git --version` でバージョンが表示される
- [x] `flutter --version` でバージョンが表示される
- [x] `flutter doctor` で Chrome の行に `[✓]` が付いている
- [x] VS Code に Flutter 拡張機能がインストールされている
- [x] `flutter run -d chrome` でアプリが Chrome に表示される

困ったことがあれば Discord の **`#260521-flutter-workshop`** チャンネルへ！
