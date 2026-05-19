# Mini Instagram Flutter Workshop Template

画像とテキストが縦に並ぶタイムライン型の Flutter アプリを作るためのハンズオン用テンプレートです。Firebase 初期化、Firestore 更新処理、モデルなどは事前に用意済みです。

参加者が主に編集するファイル:

- `lib/providers/post_providers.dart`: Firestore から投稿一覧を購読する `postsProvider` を作る
- `lib/feed_page.dart`: `postsProvider` から届いた投稿一覧を画面に並べる
- `lib/widgets/post_card.dart`: 1件分の投稿 UI といいねボタンを作る

`TODO` コメントを順番に確認しながら編集してください。

## Setup

```bash
cd flutter-workshop/template
flutter pub get
```

講師側で Firebase プロジェクトを設定済みの場合、この手順は不要です。自分の Firebase プロジェクトに接続する場合だけ、Firebase CLI と FlutterFire CLI にログイン済みの状態で設定してください。

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --platforms=web,android,ios
```

`lib/firebase_options.dart` は設定済みのサンプルです。自分の Firebase プロジェクトを使う場合は、上の `flutterfire configure` で生成された内容に置き換えてください。

## Firestore Data

Firestore に `posts` コレクションを作成し、次のフィールドを持つドキュメントを数件追加します。

| field | type | example |
| --- | --- | --- |
| `imageUrl` | string | `https://images.unsplash.com/...` |
| `authorUrl` | string | `https://images.unsplash.com/...` |
| `authorId` | string | `flutter_workshop` |
| `text` | string | `Flutter でフィード画面を作っています！` |
| `likes` | number | `12` |
| `createdAt` | timestamp | Firestore timestamp |

Seed examples:

```json
[
  {
    "imageUrl": "https://images.unsplash.com/photo-1515879218367-8466d910aaa4?auto=format&fit=crop&w=1200&q=80",
    "authorUrl": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=256&q=80",
    "authorId": "flutter_taro",
    "text": "Flutter で UI を組み立て中。Column と Row が見えてきた！",
    "likes": 8,
    "createdAt": "2026-05-20T10:00:00+09:00"
  },
  {
    "imageUrl": "https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=1200&q=80",
    "authorUrl": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=256&q=80",
    "authorId": "riverpod_hana",
    "text": "Firestore からリアルタイムで投稿を読み込んでいます。",
    "likes": 15,
    "createdAt": "2026-05-20T10:05:00+09:00"
  },
  {
    "imageUrl": "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80",
    "authorUrl": "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=256&q=80",
    "authorId": "firebase_ken",
    "text": "ハートをタップすると、いいね数が連動します。",
    "likes": 21,
    "createdAt": "2026-05-20T10:10:00+09:00"
  }
]
```

## Run

```bash
flutter run -d chrome
```

Android/iOS emulator:

```bash
flutter run -d android
flutter run -d ios
```

## Verify

```bash
flutter analyze
flutter test
flutter build web
```

## Workshop Scope

このテンプレートで講師側が用意済みの部分:

- `lib/main.dart`: Firebase 初期化と Riverpod の `ProviderScope`
- `lib/firebase_options.dart`: Firebase 設定
- `lib/models/post.dart`: Firestore ドキュメントを Dart の `Post` に変換する model
- `lib/providers/post_providers.dart`: Firestore 接続、いいね済み投稿IDの管理、いいね更新処理

ハンズオンで編集する中心部分:

- `lib/providers/post_providers.dart`: `postsProvider` の中身
- `lib/widgets/post_card.dart`: 1件分の投稿 UI
- `lib/feed_page.dart`: `ListView.builder` で投稿を並べる画面
