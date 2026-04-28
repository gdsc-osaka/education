---
marp: true
theme: gdg
paginate: true
size: 16:9
---

<!-- _class: title -->

# ポートフォリオ Web サイト
## 作成ワークショップ

GDG on Campus University of Osaka
2 時間で完成！はじめての Web サイト公開

---

<!-- _class: lead -->

# ようこそ！

---

## 今日のゴール

2 時間で **自分だけのポートフォリオサイト** を作って、インターネットに公開する。

- 簡単な Web ページの構造 (**HTML**)
- 見た目を整える方法 (**CSS**)
- 開発ツール **VSCode** の基本操作
- **GitHub Pages** で世界に公開

> まずは「動くものを作る達成感」を味わおう！

---

## 進め方

- 駆け足での進行になります
- **最低 Step 3 まで** 完走を目指す
- 余裕があれば Step 4 以降にもチャレンジ
- 困ったら遠慮なく **メンターに声かけ** を！

| 必要なもの |                                |
| --------- | ------------------------------ |
| PC        | Windows / Mac (要インターネット) |
| メール     | GitHub アカウント作成用         |

---

## 全体スケジュール

| Step  | 内容                                    | 時間   |
| ----- | -------------------------------------- | ----- |
| 1     | 開発環境の準備                           | 30 分 |
| 2     | HTML でページを作る                       | 70 分 |
| 3     | CSS で見た目を整える                      | 45 分 |
| 4     | GitHub Pages で公開                      | 40 分 |
| 5     | まとめ & 次のステップ                     | 10 分 |
| 6 〜 9 | 発展編 (デザイン / レスポンシブ / Git / React) | 任意   |

---

<!-- _class: section -->

# Step 1
## 開発環境の準備

---

## Step 1 でやること

1. **VSCode** をインストール (コードを書くエディタ)
2. **作業フォルダ** を作成して VSCode で開く
3. **GitHub アカウント** を作成

> 公式サイト: <https://code.visualstudio.com/download>
> 公式サイト: <https://github.com/>

---

## VSCode のインストール

1. ブラウザで [VSCode 公式サイト](https://code.visualstudio.com/download) を開く
2. お使いの OS (Windows / Mac) のインストーラーをダウンロード
3. ダウンロードしたファイルを開いて画面の指示通りに進める

> **困ったら:** インストールがうまくいかない場合はメンターに声をかけて！

---

## 作業フォルダを作る

1. パソコン上の好きな場所に新規フォルダを作成
2. VSCode を起動
3. 「ファイル」→「フォルダを開く…」で今作ったフォルダを開く

これからすべての作業はこのフォルダで行います。

---

## GitHub アカウント作成

1. <https://github.com/> にアクセス → 右上 **Sign up**
2. ユーザー名・メール・パスワードを入力
   - **ユーザー名は半角英数字とハイフンのみ** (URL の一部になります！)
3. パズル認証 → Free プランを選択
4. 届いた確認メールの **Verify email address** をクリック

> **困ったら:** 確認メールが届かない / 手順で迷ったらメンターへ。

---

<!-- _class: section yellow -->

# Step 2
## HTML でページを作る

---

## HTML とは？

**HTML (HyperText Markup Language)** = Web ページの「構造」を作る言語

「タグ」で囲んでコンテンツを意味づけする。

```html
<h1>これは見出し</h1>
<p>これは段落</p>
```

---

## Step 2-1: 主要な 3 つのタグ

| タグ      | 役割                                         |
| -------- | ------------------------------------------- |
| `<html>` | HTML 文書全体を囲む                          |
| `<head>` | ページの設定 (タイトル / CSS リンクなど)       |
| `<body>` | ブラウザに **表示される中身**                  |

これからこの 3 つのタグでページの土台を作ります。

---

## Step 2-1: `index.html` を作成

![bg right:35% fit](../img/step2-1.png)

1. エクスプローラーで「**新しいファイル**」をクリック
2. ファイル名を `index.html` に
3. 下のコードを貼り付けて **保存** (`Ctrl/Cmd + S`)

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>わたしのポートフォリオ</title>
</head>
<body>
</body>
</html>
```

---

## Step 2-1: ブラウザで表示してみる

VSCode の拡張機能 **Live Server** を使うと、編集内容がリアルタイムで反映されます。

1. 左の **拡張機能** アイコンをクリック
2. `Live Server` を検索 → **Install**
3. `index.html` を開いた状態で右下の **Go Live** をクリック

> 真っ白な画面が表示されたら OK！VSCode とブラウザを **並べて表示** すると便利です。

---

## Step 2-2: 見出し `<h1>`

![bg right:35% fit](../img/step2-2.png)

`<body>` の中に書いてみよう。

```html
<h1>ここをあなたの名前に変更</h1>
```

保存 → ブラウザに大きな文字が出れば成功！
中身を **自分の名前** に書き換えてみよう。

---

## Step 2-3: 段落 `<p>`

![bg right:35% fit](../img/step2-3.png)

`<h1>` の下に追加。

```html
<p>ここをあなたの自己紹介文に変更。Web開発に興味があります！</p>
```

保存して反映を確認 → 自己紹介に書き換えよう。

---

## Step 2-4: 表を作る (少し難しめ)

| タグ        | 役割                |
| ---------- | ------------------ |
| `<table>`  | 表全体              |
| `<thead>`  | 見出し部分          |
| `<tbody>`  | データ部分          |
| `<tr>`     | 行 (table row)     |
| `<th>`     | 見出しセル          |
| `<td>`     | データセル          |

> **難しい場合は** とりあえずコピーだけして次へ進んで OK！

---

## Step 2-4: 表のサンプル

![bg right:35% fit](../img/step2-4.png)

```html
<table>
  <thead>
    <tr><th>とくせい</th><th>value</th></tr>
  </thead>
  <tbody>
    <tr><td>すきなもの</td><td>Google</td></tr>
    <tr>
      <td>サークル</td>
      <td>GDG on Campus University of Osaka</td>
    </tr>
  </tbody>
</table>
```

`<th>` `<td>` の中身を変えて自分のプロフィールに！

---

## Step 2-5: リンク `<a>`

![bg right:35% fit](../img/step2-5.png)

```html
<a href="リンク先のURL">リンクのテキスト</a>
```

表のセルにリンクを入れてみよう。

```html
<td>
  <a href="https://www.google.com/">Google</a>
</td>
```

> **入れ子:** タグの中にタグを入れることができます。
> 自分の SNS などへのリンクも貼ってみましょう！

---

<!-- _class: section -->

# Step 3
## CSS で見た目を整える

---

## CSS とは？

**CSS (Cascading Style Sheets)** = Web ページの **見た目** を決める言語

```css
セレクタ {
  プロパティ: 値;
}
```

| 要素        | 例                                    |
| ---------- | ------------------------------------ |
| セレクタ    | `body`, `h1`, `p`                    |
| プロパティ  | `background-color`, `color`, `font-size` |
| 値         | `red`, `20px`, `bold`                |

---

## Step 3-1: `style.css` を作る

![bg right:35% fit](../img/step3-1.png)

1. `index.html` と同じ場所に **新しいファイル** `style.css` を作成
2. `index.html` の `<head>` に下記を追加 (HTML に CSS を読み込ませる)

```html
<link rel="stylesheet" href="style.css">
```

これで CSS の準備完了！

---

## Step 3-2: 背景色を変える

![bg right:35% fit](../img/step3-2.png)

`style.css` に追加。

```css
body {
  background-color: #d0f0ff; /* 薄い水色 */
}
```

> **色の表現:** `#RRGGBB` で赤・緑・青を 00〜ff の 256 段階で指定。
> `#000000` 黒 / `#ff0000` 赤 / `#00ffff` 水色

色見本: <https://htmlcolorcodes.com/>

---

## Step 3-3: 文字色を変える

![bg right:35% fit](../img/step3-3.png)

```css
h1 {
  color: #229954; /* 見出しを緑に */
}
p {
  color: #2e86c1; /* 段落を青に */
}
```

セレクタごとに別々の色を設定できる！

---

## Step 3-4: フォントを変える

![bg right:35% fit](../img/step3-4.png)

```css
body {
  font-family: serif; /* セリフ体 (≒ 明朝体) */
}
```

| 総称名         | だいたいの見た目                |
| ------------- | ----------------------------- |
| `serif`       | 明朝体っぽい                  |
| `sans-serif`  | ゴシック体っぽい               |
| `monospace`   | 等幅 (プログラミング向け)      |

参考: [MDN — font-family](https://developer.mozilla.org/ja/docs/Web/CSS/font-family)

---

<!-- _class: section green -->

# Step 4
## GitHub Pages で公開

---

## GitHub って何？

**バージョン管理** と **共同作業** を支えるプラットフォーム。

- **Git** = 変更履歴を管理するシステム (パソコン上で動く)
- **GitHub** = Git を使ったプロジェクトを共有する場所

今日は GitHub の **無料の公開機能 = GitHub Pages** を使います。

---

## Step 4-1: リポジトリを作る

![bg right:35% fit](../img/step4-1.png)

1. GitHub にログイン → 右上 **+** → **New repository**
2. 設定はここがポイント！
   - **Repository name:** `あなたのユーザー名.github.io` と **正確に** 入力
     - 例: `taro-yamada` → `taro-yamada.github.io`
   - **Public** を選択 (Private だと Pages が使えない)
   - 下のチェックボックスは **すべて外す**
3. **Create repository** をクリック

---

## Step 4-1: ファイルをアップロード

1. 作成画面の **uploading an existing file** をクリック
2. `index.html` と `style.css` の **2 ファイル** を点線枠にドラッグ&ドロップ
   - **フォルダごとアップロードしないように注意！**
3. 緑色の **Commit changes** をクリック

> **コミット (commit)** = リポジトリに変更を「記録」する操作。

---

## Step 4-2: GitHub Pages を有効化

1. リポジトリ上部の **Settings** タブへ
2. 左メニューから **Pages** を選択
3. **Source** = `Deploy from a branch` を確認
4. **Branch** = `main` (または `master`) / **Folder** = `/ (root)` で **Save**

---

## Step 4-2: 公開を確認！

しばらくすると **"Your site is live at ..."** と表示されます。

URL: `https://あなたのユーザー名.github.io`

> **404 が出たら:**
> - 数分待つ
> - リポジトリ名が `ユーザー名.github.io` と完全一致しているか
> - フォルダごとアップロードしていないか
> - ファイル名 `index.html` が正しいか

---

<!-- _class: lead -->

# 🎉 おめでとう！
## あなたのポートフォリオが世界に公開されました

---

<!-- _class: section yellow -->

# Step 5
## まとめ & 次のステップ

---

## 今日達成したこと

- VSCode で **HTML** と **CSS** ファイルを作成・編集した
- Web ページの **構造** と **見た目** を作った
- **GitHub アカウント** とリポジトリを作成
- **GitHub Pages** で Web サイトをインターネットに公開！

---

## この先の学び方

ここからは **発展編 (Step 6 〜 9)**。気になるテーマから自分のペースで！

| Step | テーマ                              |
| ---- | ---------------------------------- |
| 6    | コンテンツとデザインを充実させる        |
| 7    | レスポンシブ対応 & JavaScript で動き    |
| 8    | Git でバージョン管理する                |
| 9    | React の世界に飛び込もう              |

> さらに先へ: **Next.js / Vue.js** などのフレームワーク。

---

<!-- _class: section -->

# Step 6
## コンテンツとデザインを充実させよう

---

## Step 6 でやること

`index.html` と `style.css` をもう一段グレードアップ！

- 見出し `<h2>` で **セクション分け**
- 箇条書き `<ul>` `<li>` で **リスト表示**
- `<img>` で **プロフィール画像** を表示
- CSS で **レイアウト** をきれいに整える

---

## セクション分け `<h2>` & リスト

`</table>` の下に追加。

```html
<h2>自己紹介</h2>
<p>
  大阪大学に通う 1 年生です。
  好きな食べ物はラーメンです。
</p>

<h2>作品紹介</h2>
<ul>
  <li>はじめてのポートフォリオサイト (今ここ！)</li>
  <li>大学の課題で作った Python のじゃんけんゲーム</li>
</ul>
```

> **補足:** 番号付きリストは `<ul>` の代わりに `<ol>` を使う。

---

## 画像を表示しよう `<img>`

1. プロフィール画像を 1 枚用意 (写真 / アイコン OK)
2. `index.html` と同じ場所に `img` フォルダを作って画像を入れる
   - 例: `img/profile.png`
3. `<h1>` の下に追加

```html
<img src="img/profile.png" alt="プロフィール画像">
```

> **困ったら:** `index.html` から見た **相対パス** が正しいか / 大文字・小文字が合っているかを確認。

---

## CSS でレイアウトを整える

`style.css` の末尾に追加。

```css
body {
  max-width: 720px;          /* 横幅を制限して読みやすく */
  margin: 0 auto;            /* 左右中央揃え */
  padding: 24px;             /* 内側に余白 */
  line-height: 1.7;          /* 行間を広めに */
}
h2 {
  border-bottom: 2px solid #229954;
  padding-bottom: 4px;
  margin-top: 32px;
}
img { max-width: 200px; border-radius: 50%; }
table { border-collapse: collapse; }
th, td { border: 1px solid #888; padding: 6px 12px; }
```

> `margin` = **外側** の余白 / `padding` = **内側** の余白

---

<!-- _class: section yellow -->

# Step 7
## レスポンシブ対応と JavaScript で動きをつけよう

---

## Step 7 でやること

PC では OK でも、スマホで見ると崩れる…を解消！

- `<meta viewport>` で **スマホ表示** を整える
- **メディアクエリ** で画面サイズ別の CSS
- **JavaScript** でボタンに動きを
- **CSS だけ** でホバーアニメーション

---

## viewport の設定

`<head>` 内に 1 行追加するだけ。

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

> **補足:** ブラウザに「画面の幅にあわせて表示してね」と伝えるおまじない。
> スマホ対応サイトには **必ず** 入れる。

---

## メディアクエリで画面サイズ別 CSS

`style.css` の末尾に追加。

```css
/* 画面の横幅が 600px 以下のときだけ適用 */
@media (max-width: 600px) {
  body {
    padding: 12px;
    font-size: 14px;
  }
  img { max-width: 120px; }
  h1  { font-size: 24px; }
}
```

ブラウザの **ウィンドウ幅** を変えて、切り替わるか確認！

---

## JavaScript でボタンに動きを

`</body>` の直前に追加。

```html
<button onclick="sayHello()">クリックしてね</button>

<script>
  function sayHello() {
    alert('こんにちは！ポートフォリオを見てくれてありがとう。');
  }
</script>
```

ボタンを押してメッセージが出れば成功！

> `function 〜() { … }` = 「関数」のまとまり / `onclick` = クリック時に呼ぶ関数を指定

---

## CSS だけでホバーアニメーション

```css
button {
  background-color: #229954;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  transition: transform 0.2s, background-color 0.2s;
}
button:hover {
  background-color: #1e8449;
  transform: scale(1.05); /* 少し大きくする */
}
```

> `transition` で変化を **なめらか** に。`opacity` や `color` にも使える。

---

<!-- _class: section green -->

# Step 8
## Git を使ってバージョン管理しよう

---

## Step 8 でやること

Step 4 では Web 画面から直接アップロードしました。
ここでは **プロも使う Git** でスマートに管理しよう！

- **Git** をインストール & 初期設定
- リポジトリを **clone** (パソコンに持ってくる)
- **add → commit → push** の流れを覚える

---

## Git のインストール

**Windows:**
1. [Git for Windows 公式サイト](https://git-scm.com/download/win) からインストーラーをダウンロード
2. 基本的に **デフォルトのまま** Next を押し進める

**Mac:** 多くの場合は最初から入っています。ターミナルで確認:

```bash
git --version
```

`git version 2.xx.x` のように表示されれば OK！

---

## Git の初期設定

「誰が変更したか」を記録するため、名前とメールを設定。
Windows は **Git Bash**、Mac は **ターミナル** を開いて実行。

```bash
git config --global user.name "あなたの名前"
git config --global user.email "あなたのメールアドレス"
```

> GitHub に登録した名前 / メールに揃えるのがおすすめ。

---

## リポジトリを clone する

GitHub 上のリポジトリをパソコンにダウンロードする = **clone**。

1. リポジトリページの緑色 **Code** ボタン → URL をコピー
2. 置きたいフォルダにターミナルで移動 (例: `cd Desktop`)
3. clone を実行

```bash
git clone https://github.com/[your-username]/[your-username].github.io.git
```

4. できたフォルダを VSCode で開く

---

## add → commit → push の流れ

ファイルを編集して GitHub に反映するまでの **基本 3 ステップ**。

```bash
# 1. どのファイルが変わったか確認
git status

# 2. 変更を「次のコミットに含める」状態に
git add .

# 3. 変更を 1 つの履歴として記録
git commit -m "自己紹介を更新"

# 4. ローカルの履歴を GitHub に送信
git push
```

数十秒〜数分待つと `https://[your-username].github.io` に反映されます。

---

## add / commit / push まとめ

| コマンド       | 役割                                      |
| ------------- | ---------------------------------------- |
| `git add`     | 「この変更を記録対象にする」と Git に伝える     |
| `git commit`  | ステージングされた変更を **1 つの履歴** に保存   |
| `git push`    | ローカルの履歴を **GitHub に送信**             |

> **困ったら:** push 時にパスワードを聞かれたら **Personal Access Token (PAT)** が必要。
> [GitHub 公式ドキュメント](https://docs.github.com/ja/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) を参照、またはメンターへ。

---

<!-- _class: section -->

# Step 9
## React の世界に飛び込もう

---

## Step 9 でやること

世界中で使われる **React** に触れてみよう！

- **React** = UI を「コンポーネント」として組み立てる JavaScript ライブラリ
- **Node.js** をインストール
- **Vite** で React プロジェクトを作成
- **state** を使ってボタンに動きをつける

---

## React って何？

Meta (旧 Facebook) が開発した JavaScript ライブラリ。

- **コンポーネントベース:** UI を小さな部品に分けて再利用しやすい
- **宣言的 (declarative):** 「こういう状態のときはこう表示」と書くだけ
- **エコシステムが豊富:** Next.js などのフレームワークや便利ライブラリが多数

---

## Node.js のインストール

React を動かすには JavaScript の実行環境 **Node.js** が必要。

1. [Node.js 公式サイト](https://nodejs.org/) にアクセス
2. **LTS** (長期サポート版) をダウンロードしてインストール
3. ターミナルで以下を実行してバージョン表示を確認

```bash
node --version
npm --version
```

---

## Vite で React プロジェクトを作る

プロジェクトを手早く立ち上げる **Vite (ヴィート)** を使う。

```bash
npm create vite@latest my-react-portfolio
```

画面の指示で `React` → `JavaScript` を選択。

```bash
cd my-react-portfolio
npm install
npm run dev
```

表示された `http://localhost:5173/` を開いて、React のサンプルが出れば成功！

---

## コンポーネントを編集してみよう

`src/App.jsx` を開いて中身をまるごと書き換え。

```jsx
function App() {
  return (
    <div>
      <h1>いたこすのポートフォリオ (React 版)</h1>
      <p>React で作り直してみました！</p>
    </div>
  );
}

export default App;
```

保存するとブラウザが自動更新 (Hot Reload)！

> **補足:** `return ( ... )` の中の HTML 風の記法は **JSX**。
> `class` の代わりに `className` を使うなど、HTML と少し違う点があります。

---

## state でボタンに動きを

```jsx
import { useState } from 'react';

function App() {
  const [count, setCount] = useState(0);

  return (
    <div>
      <h1>いたこすのポートフォリオ</h1>
      <p>ボタンが押された回数: {count}</p>
      <button onClick={() => setCount(count + 1)}>+1 する</button>
    </div>
  );
}

export default App;
```

- `useState(0)` = 初期値 `0` の状態を作る
- `setCount(...)` を呼ぶと React が自動で再描画
- `{count}` で JSX に JavaScript の値を埋め込み

---

## さらに学ぶには？

- [React 公式ドキュメント (日本語)](https://ja.react.dev/learn) がとてもおすすめ
- 公開するには **ビルド** や `vite.config.js` の `base` 設定など追加作業が必要
  - 「**Vite GitHub Pages デプロイ**」で検索 / メンターに質問

> ここまでお疲れさまでした！今日のワークショップから始まった皆さんの Web 開発の旅が、これからどんどん広がっていきますように 🌱

---

<!-- _class: lead -->

# Thank you!
## ぜひ自分だけのポートフォリオに育ててください 🌱
