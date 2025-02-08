# 第1回: Web 開発の基礎とセットアップ

## 目次
1. Web の仕組み
2. HTML の基礎
3. CSS の基礎
4. JavaScript の基礎
5. 開発環境のセットアップ (VSCode と Chrome)
6. 簡単なウェブページを作成

---

## 1. Web の仕組み

### Web サイトがどう動くか
- Webサイトは **クライアント**（ブラウザ）と **サーバー** のやりとりで動きます。
- ユーザーがブラウザで URL を入力すると、ブラウザがその URL に対して **リクエスト** を送信し、サーバーが **レスポンス** を返します。

### HTTPの仕組み
- **HTTP (Hypertext Transfer Protocol)** は、クライアントとサーバーが情報をやり取りするためのプロトコルです。
- HTTPリクエストには以下のようなメソッドがあります：
  - `GET`: データを取得する
  - `POST`: データを送信する

### ドメインとIPアドレス
- **ドメイン名**（例: `example.com`）は人間が覚えやすい名前で、実際には **IPアドレス**（例: `192.168.0.1`）という数字に変換されます。
- **DNS (Domain Name System)** がドメインをIPアドレスに変換してくれます。

---

## 2. HTML の基礎

### HTML の基本構造
- **HTML (Hypertext Markup Language)** は、Web ページの構造を作るための言語です。
- 基本的な HTML の構造：
  ```html
  <!DOCTYPE html>
  <html lang="ja">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My First Web Page</title>
  </head>
  <body>
    <h1>ようこそ、私のサイトへ</h1>
    <p>これは最初のHTMLページです。</p>
  </body>
  </html>
  ```
  - `<html>` タグ: ページ全体を囲む
  - `<head>` タグ: メタデータ（ページ情報）
  - `<body>` タグ: ページの内容（見出しや文章）

### 基本的なタグ
- `<h1>` - `<h6>`: 見出し
- `<p>`: 段落
- `<a href="URL">`: リンク
- `<img src="URL" alt="説明">`: 画像

---

## 3. CSS の基礎

### CSS の役割
- **CSS (Cascading Style Sheets)** は、HTML のスタイル（見た目）を定義するための言語です。
- HTML の構造にデザイン（色、レイアウトなど）を追加します。

### CSSの基本構文
- CSS の基本は、**セレクタ** と **プロパティ** です。
  ```css
  h1 {
    color: blue;
    font-size: 24px;
  }
  ```
  - **セレクタ**: `h1`（適用する要素）
  - **プロパティ**: `color`, `font-size`
  - **値**: `blue`, `24px`

### CSS の適用方法
1. **外部CSSファイル**を使う方法
   - ファイル名：`styles.css`
   ```html
   <link rel="stylesheet" href="styles.css">
   ```
2. **内部CSS**を使う方法
   ```html
   <style>
     h1 {
       color: red;
     }
   </style>
   ```

---

## 4. JavaScript の基礎

### JavaScript とは
- **JavaScript** は Web ページに動きをつけるためのプログラミング言語です。
- ブラウザ内で実行され、ユーザーとページがインタラクティブにやり取りできるようになります。

### 基本的な文法
- 変数の宣言:
  ```javascript
  let name = "太郎";
  const age = 20;
  ```
- 関数の定義:
  ```javascript
  function greet() {
    alert("こんにちは！");
  }
  ```
- イベントリスナーを使ったクリックイベント:
  ```javascript
  document.querySelector("button").addEventListener("click", function() {
    alert("ボタンがクリックされました！");
  });
  ```

---

## 5. 開発環境のセットアップ (VSCode と Chrome)

### Visual Studio Code (VSCode) のインストールと基本設定
1. **VSCode のインストール**: [ダウンロードページ](https://code.visualstudio.com/)
2. インストール後、基本設定を行う（テーマ、拡張機能の導入）。
3. 新規フォルダを作成し、その中に HTML ファイル（例：`index.html`）を作成。

### Chrome の開発者ツール
1. **Chrome** を開いて、任意のページで `F12` キーを押して **開発者ツール** を開く。
2. 「Elements」タブでは、ページのHTMLとCSSを確認・編集できる。
3. 「Console」タブでは、JavaScriptを実行して確認できる。

---

## 6. 簡単なウェブページを作成

### Step 1: HTML ファイルを作成
- `index.html` というファイルを作成し、以下のコードを追加します。
  ```html
  <!DOCTYPE html>
  <html lang="ja">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My First Web Page</title>
  </head>
  <body>
    <h1>ようこそ、私のサイトへ</h1>
    <p>これは最初のHTMLページです。</p>
    <button>クリックしてね</button>

    <script>
      document.querySelector("button").addEventListener("click", function() {
        alert("ボタンがクリックされました！");
      });
    </script>
  </body>
  </html>
  ```

### Step 2: Chrome で表示
1. 作成した `index.html` ファイルを保存し、Chrome で開きます。
2. ボタンをクリックすると、アラートが表示されます。

---

## まとめ
- Web サイトの基本的な構造を理解し、HTML/CSS/JavaScript の基礎を学びました。
- 次回は、プログラミングをより安全かつ効率的に行うために、**TypeScript** を学びます。
