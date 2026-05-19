# Mini Instagram Flutter Workshop App

画像とテキストが縦に並ぶタイムライン型の Flutter アプリです。Firestore の `posts` コレクションを読み込み、各投稿のハートボタンで `likes` を増減します。

## Setup

```bash
cd flutter-workshop/example
flutter pub get
```

Firebase CLI と FlutterFire CLI にログイン済みの状態で、実際に使う Firebase プロジェクトを選んで設定してください。

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --platforms=web,android,ios
```

`lib/firebase_options.dart` はプレースホルダーです。上の `flutterfire configure` で生成された内容に置き換えてください。

## Firestore Data

Firestore に `posts` コレクションを作成し、次のフィールドを持つドキュメントを数件追加します。

| field | type | example |
| --- | --- | --- |
| `imageUrl` | string | `https://images.unsplash.com/...` |
| `author_url` | string | `https://images.unsplash.com/...` |
| `author_id` | string | `flutter_workshop` |
| `text` | string | `Flutter でフィード画面を作っています！` |
| `likes` | number | `12` |
| `createdAt` | timestamp | Firestore timestamp |

Seed examples:

```json
[
  {
    "imageUrl": "https://images.unsplash.com/photo-1515879218367-8466d910aaa4?auto=format&fit=crop&w=1200&q=80",
    "author_url": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=256&q=80",
    "author_id": "flutter_taro",
    "text": "Flutter で UI を組み立て中。Column と Row が見えてきた！",
    "likes": 8,
    "createdAt": "2026-05-20T10:00:00+09:00"
  },
  {
    "imageUrl": "https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=1200&q=80",
    "author_url": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=256&q=80",
    "author_id": "riverpod_hana",
    "text": "Firestore からリアルタイムで投稿を読み込んでいます。",
    "likes": 15,
    "createdAt": "2026-05-20T10:05:00+09:00"
  },
  {
    "imageUrl": "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80",
    "author_url": "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=256&q=80",
    "author_id": "firebase_ken",
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

## Workshop Focus

ハンズオンで説明しやすい中心部分は次のファイルです。

- `lib/widgets/post_card.dart`: 1件分の投稿 UI
- `lib/feed_page.dart`: `ListView.builder` で投稿を並べる画面
- `lib/providers/post_providers.dart`: Riverpod と Firestore の接続、いいね更新処理
