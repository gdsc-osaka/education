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

| Step | 内容                          | 時間   |
| ---- | ---------------------------- | ----- |
| 1    | 開発環境の準備                 | 30 分 |
| 2    | HTML でページを作る            | 70 分 |
| 3    | CSS で見た目を整える            | 45 分 |
| 4    | GitHub Pages で公開            | 40 分 |
| 5    | まとめ & 次のステップ           | 10 分 |

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

`<body>` の中に書いてみよう。

```html
<h1>ここをあなたの名前に変更</h1>
```

保存 → ブラウザに大きな文字が出れば成功！
中身を **自分の名前** に書き換えてみよう。

---

## Step 2-3: 段落 `<p>`

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

1. `index.html` と同じ場所に **新しいファイル** `style.css` を作成
2. `index.html` の `<head>` に下記を追加 (HTML に CSS を読み込ませる)

```html
<link rel="stylesheet" href="style.css">
```

これで CSS の準備完了！

---

## Step 3-2: 背景色を変える

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

## Next Steps (初心者向け)

- **コンテンツを充実させる**
  - 自己紹介や作品紹介を追加 / `<img>` で画像を表示
- **CSS でデザインを凝る**
  - `border`, `font-size`, `margin`, `padding` などを試す
  - 参考: [MDN — CSS](https://developer.mozilla.org/ja/docs/Web/CSS)
- **Git を学ぶ**
  - 直接アップロードではなく Git コマンドで更新できるように

---

## Next Steps (中級者向け)

- **Flexbox / Grid** を使ったレイアウト
- **メディアクエリ** でレスポンシブ対応
- **JavaScript** で簡単なインタラクション
- `git add` / `git commit` / `git push` で更新を試す

---

## さらなる上へ — フレームワーク

| 名前        | 特徴                                          |
| ---------- | -------------------------------------------- |
| [React](https://react.dev/)     | UI 構築の JS ライブラリ。コンポーネント指向     |
| [Next.js](https://nextjs.org/)  | React ベースのフルスタックフレームワーク         |
| [Vue.js](https://vuejs.org/)    | シンプルで学習しやすい JS フレームワーク         |

コンポーネント再利用 / 動的コンテンツ / API 連携 / 高度な UI へ。

---

<!-- _class: lead -->

# Thank you!
## ぜひ自分だけのポートフォリオに育ててください 🌱
