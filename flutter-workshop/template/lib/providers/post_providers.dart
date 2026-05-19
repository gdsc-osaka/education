import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final postsProvider = StreamProvider<List<Post>>((ref) {
  // TODO
  return const Stream<List<Post>>.empty();
});

final likedPostIdsProvider = NotifierProvider<LikedPostIds, Set<String>>(
  LikedPostIds.new,
);

class LikedPostIds extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return <String>{};
  }

  void setLiked(String postId, {required bool liked}) {
    if (liked) {
      state = <String>{...state, postId};
      return;
    }

    state = state.where((id) => id != postId).toSet();
  }
}

final postActionsProvider = Provider<PostActions>((ref) {
  return FirestorePostActions(
    firestore: ref.watch(firestoreProvider),
    likedPostIds: ref.read(likedPostIdsProvider.notifier),
  );
});

abstract class PostActions {
  Future<void> toggleLike(Post post, {required bool isLiked});
}

class FirestorePostActions implements PostActions {
  const FirestorePostActions({
    required FirebaseFirestore firestore,
    required LikedPostIds likedPostIds,
  }) : _firestore = firestore,
       _likedPostIds = likedPostIds;

  final FirebaseFirestore _firestore;
  final LikedPostIds _likedPostIds;

  @override
  Future<void> toggleLike(Post post, {required bool isLiked}) async {
    final nextLiked = !isLiked;
    final likeDelta = nextLiked ? 1 : -1;

    _likedPostIds.setLiked(post.id, liked: nextLiked);

    try {
      await _firestore.collection('posts').doc(post.id).update({
        'likes': FieldValue.increment(likeDelta),
      });
    } catch (_) {
      _likedPostIds.setLiked(post.id, liked: isLiked);
      rethrow;
    }
  }
}
