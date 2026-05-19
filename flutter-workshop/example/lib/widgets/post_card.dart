import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';
import '../providers/post_providers.dart';

final currentPostProvider = Provider<Post>((ref) {
  throw UnimplementedError('PostCard requires currentPostProvider override.');
});

class PostCard extends ConsumerWidget {
  const PostCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(currentPostProvider);
    final likedPostIds = ref.watch(likedPostIdsProvider);
    final isLiked = likedPostIds.contains(post.id);

    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            post.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }

              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const ColoredBox(
                color: Color(0xFF1D1D21),
                child: Center(
                  child: Icon(Icons.broken_image_outlined, size: 48),
                ),
              );
            },
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Color(0xB0000000),
                ],
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filledTonal(
                  tooltip: isLiked ? 'いいねを取り消す' : 'いいね',
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
                Text(
                  '${post.likes}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 80,
            bottom: 28,
            child: Text(
              post.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                shadows: const [Shadow(color: Colors.black87, blurRadius: 8)],
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: const Color(0xFF2A2A2E),
                      backgroundImage: post.authorUrl.isEmpty
                          ? null
                          : NetworkImage(post.authorUrl),
                      child: post.authorUrl.isEmpty
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    post.authorId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
