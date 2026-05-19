---
marp: true
theme: gdg
paginate: true
size: 16:9
---

<script>
/* PowerPoint-style auto-shrink: iteratively reduce a slide's font size
   until its content stops overflowing. Also keeps the explicit opt-in
   <div class="fit">…</div> wrapper for finer-grained scaling. */
(() => {
  const MIN_FONT_PX = 12;
  const STEP = 0.96;
  const MAX_ITERS = 40;
  const TOLERANCE = 1;

  const overflows = (el) =>
    el.scrollHeight > el.clientHeight + TOLERANCE ||
    el.scrollWidth  > el.clientWidth  + TOLERANCE;

  const shrinkSection = (section) => {
    if (section.dataset.autofit === "skip") return;
    if (!overflows(section)) return;
    const base = parseFloat(getComputedStyle(section).fontSize) || 28;
    let size = base;
    for (let i = 0; i < MAX_ITERS && overflows(section) && size > MIN_FONT_PX; i++) {
      size *= STEP;
      section.style.fontSize = `${size}px`;
    }
  };

  const scaleFitBlocks = () => {
    for (const fit of document.querySelectorAll(".fit")) {
      if (!fit.scrollHeight) continue;
      const ratio = Math.min(1, fit.clientHeight / fit.scrollHeight);
      fit.style.transformOrigin = "top left";
      fit.style.transform = `scale(${ratio})`;
    }
  };

  window.addEventListener("load", () => {
    scaleFitBlocks();
    for (const section of document.querySelectorAll("section")) shrinkSection(section);
  });
})();
</script>

<style>
/* Set once per deck — drives the colored university name on every title slide. */
:root { --gdg-university: 'University of Osaka'; }
</style>

<!-- _class: title -->
<!-- _paginate: false -->

# Flutter でミニ SNS アプリを作ろう

GDG on Campus University of Osaka
2026.05.21 / 2 時間ハンズオン

---

<!-- _class: lead -->

# 今日のゴール

投稿フィードを表示する**ミニ SNS アプリ**を
テンプレートから完成させましょう!

---

## 今日の流れ (120 分)

| #   | 内容                          | 時間  |
| --- | ----------------------------- | ----- |
| 1   | 完成デモ                      | 5 分  |
| 2   | 事前準備チェック              | 10 分 |
| 3   | Flutter 基礎                  | 20 分 |
| 4   | Riverpod 基礎                 | 15 分 |
| 5   | ハンズオン① FeedPage          | 20 分 |
| 6   | ハンズオン② postsProvider     | 20 分 |
| 7   | ハンズオン③ PostCard          | 20 分 |
| 8   | 共有                          | 10 分 |

---

## 今日のスコープ

<div class="container">

<div class="col">

### やること

- Flutter の **最小限の文法**を知る
- **Riverpod** で状態を管理する
- **Firestore** から投稿をリアルタイム取得する
- ミニ SNS の投稿フィードを完成させる

</div>

<div class="col">

### やらないこと

- iOS / Android エミュレータの利用
- 認証・投稿の作成・削除
- Firebase 設定の変更

</div>

</div>

---

<!-- _class: section -->

# 01. 完成デモ

## 5 分

---

## 完成イメージ

縦スクロールで投稿を眺めるフィードアプリです!

<div style="display: flex; gap: 48px; margin-top: 16px; align-items: flex-start;">
<div style="flex: 1;">

- 投稿が **縦にずらっと並ぶ** (TikTok / Reels 風)
- 各投稿に**画像・ユーザー名・テキスト**が表示される
- ❤️ ボタンでその場でいいね!できる
- 引っ張って更新 (Pull to Refresh) もできる

> 完成版のコード: `gdsc-osaka/flutter-workshop-example`

</div>
<div style="border: 2px solid #444; border-radius: 16px; padding: 16px 16px 20px; background: #111; color: #fff; width: 180px; min-width: 180px; font-size: 13px;">
  <div style="font-size: 11px; margin-bottom: 8px; color: #aaa; display: flex; align-items: center; gap: 6px;"><span style="display:inline-block;width:22px;height:22px;border-radius:50%;background:#333;"></span>@gdsc_user</div>
  <div style="background: #2a2a2a; height: 100px; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #555; font-size: 20px; margin-bottom: 8px;">🖼️</div>
  <div style="font-size: 12px; margin-bottom: 10px; color: #e0e0e0;">Flutter で作ったよ!</div>
  <div style="font-size: 12px; color: #f48fb1; text-align: right;">❤ 42</div>
</div>
</div>

---

## アーキテクチャ概観

今日はこの 3 ファイルに手を入れます!

<div style="display: flex; align-items: center; justify-content: center; gap: 20px; margin-top: 28px;">
  <div style="padding: 18px 24px; border: 2px solid var(--gdg-blue); border-radius: 12px; font-weight: 600; text-align: center;">
    FeedPage<br><span style="font-weight: normal; font-size: 0.75em;">ConsumerWidget</span>
  </div>
  <div style="font-size: 32px; color: var(--gdg-blue);">→</div>
  <div style="padding: 18px 24px; border: 2px solid var(--gdg-green); border-radius: 12px; font-weight: 600; text-align: center;">
    postsProvider<br><span style="font-weight: normal; font-size: 0.75em;">StreamProvider</span>
  </div>
  <div style="font-size: 32px; color: var(--gdg-green);">→</div>
  <div style="padding: 18px 24px; border: 2px solid var(--gdg-red); border-radius: 12px; font-weight: 600; text-align: center;">
    PostCard<br><span style="font-weight: normal; font-size: 0.75em;">ConsumerWidget</span>
  </div>
</div>

<div style="display: flex; justify-content: center; gap: 20px; margin-top: 20px; font-size: 0.8em; color: #888;">
  <code>lib/feed_page.dart</code>
  <span>→</span>
  <code>lib/providers/post_providers.dart</code>
  <span>→</span>
  <code>lib/widgets/post_card.dart</code>
</div>

---

<!-- _class: section yellow -->

# 02. 事前準備チェック

## 10 分

---

## 必要なツール

| ツール       | 確認方法            | 用途                 |
| ------------ | ------------------- | -------------------- |
| Flutter SDK  | `flutter --version` | アプリのビルド・実行 |
| VS Code      | アプリを起動できる  | コードを書くエディタ |
| Chrome       | アプリを起動できる  | アプリの実行先       |
| Git          | `git --version`     | リポジトリのクローン |

---

## Flutter SDK の確認

ターミナルで以下を実行してください!

```bash
flutter --version
flutter doctor
```

- `flutter --version` でバージョンが出れば OK
- `flutter doctor` は **Chrome の項目に ✓** が付いていれば今日は十分
- Android / iOS の項目に ✗ が付いていても今日は無視して OK!

---

## リポジトリをクローンしよう

ターミナルで以下を順に実行してください!

```bash
git clone https://github.com/gdsc-osaka/flutter-workshop.git
cd flutter-workshop
flutter pub get
flutter run -d chrome
```

- Chrome が起動して「**TODO: 投稿一覧を表示する**」が出たら成功!
- VS Code で `flutter-workshop/` フォルダを開いておきましょう

---

<!-- _class: section -->

# 03. Flutter 基礎

## 20 分

---

## Flutter とは

![bg right:35% fit](../img/flutter-logo.png)

Google が作っている **マルチプラットフォーム UI フレームワーク**です

- 1 つのコードで **iOS / Android / Web / デスクトップ**に対応
- 言語は **Dart**
- 描画は Skia / Impeller で自前 (ネイティブ部品ではない)
- 今日は **Web ターゲット**だけ使います!

---

## Web 開発との対比

すでに知っている概念と紐付けると速いです!

| Web (HTML/CSS/JS)               | Flutter                                   |
| ------------------------------- | ----------------------------------------- |
| DOM ツリー                      | Widget ツリー                             |
| `<div>` / `<button>` などの要素 | `Container` / `ElevatedButton` 等の Widget |
| CSS のスタイル                  | Widget のプロパティ (色・余白・角丸など)   |
| useState などのフック           | StatefulWidget / Riverpod                 |
| Vite の HMR                     | ホットリロード                            |

---

## すべては Widget

![bg right:45% fit](../img/widget-tree.png)

Flutter では **画面のすべてが Widget** です

- ボタンも文字も余白も Widget
- Widget が**入れ子になって 1 本のツリー**を作る
- ツリーのルートが `MaterialApp`
- 親 Widget が子 Widget を `child` / `children` で持つ

---

## Stateless と Stateful

<div class="container">

<div class="col">

### StatelessWidget

- 状態を持たない
- 渡された値を表示するだけ
- ボタンやラベルなど
- React の純粋なコンポーネント相当

</div>

<div class="col">

### StatefulWidget

- 内部で状態を持つ
- 値が変わると **再描画**する
- カウンター / チェックボックスなど
- 今回は **Riverpod に任せる**

</div>

</div>

---

<!-- _class: invert -->

## main.dart の最小構造

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(...);
  runApp(const ProviderScope(child: MiniInstagramApp()));
}

class MiniInstagramApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: FeedPage());
  }
}
```

> 入り口は `main()` → `runApp()` → ルートの Widget の順です

---

## Dart 文法 (JS との差分だけ)

| やりたいこと      | JavaScript             | Dart                         |
| ----------------- | ---------------------- | ---------------------------- |
| 変数 (再代入あり) | `let x = 1;`           | `var x = 1;` / `int x = 1;` |
| 変数 (再代入なし) | `const x = 1;`         | `final x = 1;`               |
| 関数              | `function add(a,b){…}` | `int add(int a, int b) {…}`  |
| 文末              | `;` 省略 OK            | `;` **必須**                 |
| null チェック     | `x?.y`                 | `x?.y` (同じ!)               |

---

## ホットリロードを使い倒しましょう!

- ファイルを保存するだけで **約 1 秒**で画面が更新される
- 状態を保ったまま更新される (`r` キー)
- 状態をリセットしたいときは **ホットリスタート** (`R` キー)
- `flutter run -d chrome` で起動するとターミナルから操作できます

---

<!-- _class: section red -->

# 04. Riverpod 基礎

## 15 分

---

## なぜ状態管理が必要?

![bg right:50% fit](../img/state-problem.png)

- StatefulWidget だけだと、状態が **その Widget の中**に閉じる
- 離れた Widget で同じ状態を見たいとき、**親から子へバケツリレー**になる
- Widget が増えると爆発的に書きづらくなる
- → **Riverpod** で「どこからでも触れる場所」に置きます

---

## Riverpod の三要素

![bg right:45% fit](../img/riverpod-flow.png)

今日覚えるのはこの 3 つだけです!

- **Notifier**: 状態とロジックの入れ物
- **NotifierProvider**: 状態を公開する窓口
- **ref**: Widget から状態を読む手段 (`watch` / `read`)

---

<!-- _class: invert -->

## ① Notifier — 状態とロジック

```dart
class LikedPostIds extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};   // 初期値: 空のセット

  void setLiked(String postId, {required bool liked}) {
    if (liked) {
      state = <String>{...state, postId};
    } else {
      state = state.where((id) => id != postId).toSet();
    }
  }
}
```

- `Notifier<T>` の `T` が状態の型
- `build()` で初期値を返す
- `state = ...` と書き換えると **自動で再描画**される

---

<!-- _class: invert -->

## ② Provider — 公開する窓口

今日は **NotifierProvider** と **StreamProvider** を使います

```dart
// いいね済み ID を管理する
final likedPostIdsProvider =
    NotifierProvider<LikedPostIds, Set<String>>(LikedPostIds.new);

// Firestore の変更をリアルタイムで受け取る
final postsProvider = StreamProvider<List<Post>>((ref) {
  // Firestore のストリームを返す (ハンズオン② で実装!)
  return const Stream<List<Post>>.empty();
});
```

- `StreamProvider` は**非同期のストリーム**を扱うプロバイダ
- `AsyncValue<T>` として Widget 側に届く

---

## ③ ref.watch と ref.read

| やりたいこと               | 使うもの               | 例                                                       |
| -------------------------- | ---------------------- | -------------------------------------------------------- |
| **画面に表示**する値を取る | `ref.watch(p)`         | `final posts = ref.watch(postsProvider);`                |
| **ボタンを押して**操作する | `ref.read(p.notifier)` | `ref.read(likedPostIdsProvider.notifier).setLiked(…);`   |
| 再描画される?              | watch → ○ / read → ×   | —                                                        |

> 「**表示は watch、操作は read**」と覚えましょう!

---

<!-- _class: invert -->

## ConsumerWidget での使い方

```dart
class MyWidget extends ConsumerWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedIds = ref.watch(likedPostIdsProvider); // 表示用
    return Text('いいね数: ${likedIds.length}');
  }
}
```

- `StatelessWidget` → `ConsumerWidget` に変えるだけ
- `build` に `WidgetRef ref` が加わる
- `ref.watch()` で値が変わると自動で再描画される

---

<!-- _class: section green -->

# 05. ハンズオン① FeedPage

## 20 分

---

<!-- _class: lead -->

# Step 1 のゴール

`postsProvider` から投稿リストを受け取り、
**縦スクロールのリストとして表示**しましょう!

---

<!-- _class: invert -->

## 現在の FeedPage (template)

`lib/feed_page.dart` を開いてみましょう

```dart
class FeedPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO
    ref.watch(postsProvider);

    return const Scaffold(
      body: Center(child: Text('TODO: 投稿一覧を表示する')),
    );
  }
}
```

`postsProvider` を watch しているが、まだ UI に活かせていない状態です

---

## `AsyncValue.when()` の使い方

`StreamProvider` が返す `AsyncValue<T>` は 3 状態を持ちます

```dart
final posts = ref.watch(postsProvider);

return Scaffold(
  body: posts.when(
    data:    (items) => /* データがある場合の Widget */,
    error:   (e, st) => /* エラーが起きた場合の Widget */,
    loading: ()      => const CircularProgressIndicator(),
  ),
);
```

- **data**: Firestore からデータが届いた
- **error**: 読み込みに失敗した
- **loading**: まだデータが届いていない (ぐるぐる表示)

---

## ListView + ProviderScope のパターン

`data` コールバックの中で `ListView.builder` を返しましょう

```dart
data: (items) => ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ProviderScope(
      overrides: [
        currentPostProvider.overrideWithValue(items[index]),
      ],
      child: const PostCard(),
    );
  },
),
```

- `ProviderScope` で投稿データを **1 件ずつ PostCard に注入**する
- `currentPostProvider` は `post_card.dart` に定義済み

---

<!-- _class: section -->

# 06. ハンズオン② postsProvider

## 20 分

---

<!-- _class: lead -->

# Step 2 のゴール

`postsProvider` を Firestore に接続して、
**リアルタイムで投稿を取得**しましょう!

---

<!-- _class: invert -->

## 現在の postsProvider (template)

`lib/providers/post_providers.dart` を開いてみましょう

```dart
final postsProvider = StreamProvider<List<Post>>((ref) {
  // TODO
  return const Stream<List<Post>>.empty();
});
```

空のストリームを返しているため、Step 1 の `data` コールバックが空リストのまま

---

<!-- _class: invert -->

## Firestore からストリームを取得する

`firestoreProvider` は既に定義済みです

```dart
final postsProvider = StreamProvider<List<Post>>((ref) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map(Post.fromDocument).toList());
});
```

- `.collection('posts')` で posts コレクションを指定
- `.orderBy('createdAt', descending: true)` で新着順にソート
- `.snapshots()` でリアルタイムストリームに変換
- `.map()` で `List<Post>` に変換

---

## Post モデルのフィールド

`lib/models/post.dart` で定義されています

| フィールド  | 型         | 内容                      |
| ----------- | ---------- | ------------------------- |
| `id`        | `String`   | Firestore ドキュメント ID |
| `imageUrl`  | `String`   | 投稿画像の URL            |
| `authorId`  | `String`   | 投稿者のユーザー名        |
| `authorUrl` | `String`   | 投稿者のアイコン URL      |
| `text`      | `String`   | 投稿テキスト              |
| `likes`     | `int`      | いいね数                  |
| `createdAt` | `DateTime` | 投稿日時                  |

`Post.fromDocument()` で Firestore ドキュメントから自動変換されます

---

<!-- _class: section yellow -->

# 07. ハンズオン③ PostCard

## 20 分

---

<!-- _class: lead -->

# Step 3 のゴール

`currentPostProvider` から投稿データを受け取り、
**フルスクリーンのカード UI** を作りましょう!

---

<!-- _class: invert -->

## 現在の PostCard (template)

`lib/widgets/post_card.dart` を開いてみましょう

```dart
class PostCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO
    ref.watch(currentPostProvider);

    return const AspectRatio(
      aspectRatio: 9 / 16,
      child: ColoredBox(
        color: Color(0xFF1D1D21),
        child: Center(child: Text('TODO: 投稿カードを作る')),
      ),
    );
  }
}
```

---

## Stack + Positioned で UI を重ねる

PostCard は複数の要素を**重ねて表示**します

<div class="container">

<div class="col">

```dart
Stack(
  fit: StackFit.expand,
  children: [
    // ① 背景画像
    Image.network(post.imageUrl, ...),
    // ② グラデーションオーバーレイ
    const DecoratedBox(decoration: ...),
    // ③ ユーザー情報 (上)
    Positioned(top: 12, left: 12, ...),
    // ④ テキスト (下左)
    Positioned(bottom: 28, left: 16, ...),
    // ⑤ いいねボタン (下右)
    Positioned(right: 8, bottom: 20, ...),
  ],
)
```

</div>

<div class="col">

- `Stack` で子を重ねる
- `Positioned` で位置を指定
- `AspectRatio(9/16)` で縦長に固定
- `StackFit.expand` で全体に広げる

</div>

</div>

---

## いいねボタンの実装

`likedPostIdsProvider` でいいね状態を管理します

```dart
final post = ref.watch(currentPostProvider);
final likedPostIds = ref.watch(likedPostIdsProvider);
final isLiked = likedPostIds.contains(post.id);

IconButton.filledTonal(
  onPressed: () async {
    await ref
        .read(postActionsProvider)
        .toggleLike(post, isLiked: isLiked);
  },
  icon: Icon(
    isLiked ? Icons.favorite : Icons.favorite_border,
    color: isLiked ? Colors.pinkAccent : Colors.white,
  ),
),
```

> 表示は `watch`、操作は `read` のパターンです!

---

<!-- _class: section red -->

# 08. 共有

## 10 分

---

## 発表してみましょう!

時間が残ったら、隣の人や全体に共有してください!

<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-top: 32px;">
  <div style="padding: 24px; border-top: 4px solid var(--gdg-blue); background: #F8F9FA; border-radius: 8px;">
    <h3 style="margin-top: 0;">どこまで実装できた?</h3>
    <p>完成したステップと現在の画面</p>
  </div>
  <div style="padding: 24px; border-top: 4px solid var(--gdg-green); background: #F8F9FA; border-radius: 8px;">
    <h3 style="margin-top: 0;">どこで詰まった?</h3>
    <p>解決方法もセットで共有!</p>
  </div>
  <div style="padding: 24px; border-top: 4px solid var(--gdg-yellow); background: #F8F9FA; border-radius: 8px;">
    <h3 style="margin-top: 0;">改善してみたいこと</h3>
    <p>追加したい機能やデザイン</p>
  </div>
</div>

---

## 今日のまとめ

- Flutter は **Widget ツリー**で画面を組みます
- Riverpod の **StreamProvider** で非同期データを扱えます
- **AsyncValue.when()** でデータ / エラー / 読み込み状態を切り替えます
- **ProviderScope** で親から子に値を注入できます
- 詰まったらすぐに **Discord `#260521-flutter-workshop` で共有**してください!

---

<!-- _class: lead -->

# Thank you!

楽しいアプリ作りを!
質問は `#260521-flutter-workshop` で待っています!
