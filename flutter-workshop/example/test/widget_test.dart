import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_instagram/models/post.dart';
import 'package:mini_instagram/providers/post_providers.dart';
import 'package:mini_instagram/widgets/post_card.dart';

void main() {
  testWidgets('PostCard shows a post and toggles local like state', (
    tester,
  ) async {
    final post = Post(
      id: 'post-1',
      imageUrl: 'https://example.com/image.jpg',
      authorUrl: '',
      authorId: 'flutter_workshop',
      text: 'Flutter workshop day!',
      likes: 12,
      createdAt: DateTime(2026, 5, 20),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentPostProvider.overrideWithValue(post),
          postActionsProvider.overrideWith((ref) {
            return _FakePostActions(ref.read(likedPostIdsProvider.notifier));
          }),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(width: 360, child: PostCard()),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Flutter workshop day!'), findsOneWidget);
    expect(find.text('flutter_workshop'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byTooltip('いいね'));
    await tester.pump();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });
}

class _FakePostActions implements PostActions {
  const _FakePostActions(this._likedPostIds);

  final LikedPostIds _likedPostIds;

  @override
  Future<void> toggleLike(Post post, {required bool isLiked}) async {
    _likedPostIds.setLiked(post.id, liked: !isLiked);
  }
}
