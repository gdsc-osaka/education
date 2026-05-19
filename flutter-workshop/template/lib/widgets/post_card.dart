import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';

final currentPostProvider = Provider<Post>((ref) {
  throw UnimplementedError('PostCard requires currentPostProvider override.');
});

class PostCard extends ConsumerWidget {
  const PostCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO
    ref.watch(currentPostProvider);

    return const AspectRatio(
      aspectRatio: 9 / 16,
      child: ColoredBox(
        color: Color(0xFF1D1D21),
        child: Center(
          child: Text('TODO: 投稿カードを作る'),
        ),
      ),
    );
  }
}
