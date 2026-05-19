import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_instagram/models/post.dart';
import 'package:mini_instagram/widgets/post_card.dart';

void main() {
  testWidgets('PostCard template renders placeholder', (tester) async {
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

    expect(find.text('TODO: 投稿カードを作る'), findsOneWidget);
  });
}
