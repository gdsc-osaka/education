import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/post_providers.dart';

class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO
    ref.watch(postsProvider);

    return const Scaffold(
      body: Center(
        child: Text('TODO: 投稿一覧を表示する'),
      ),
    );
  }
}
