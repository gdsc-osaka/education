import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  const Post({
    required this.id,
    required this.imageUrl,
    required this.authorUrl,
    required this.authorId,
    required this.text,
    required this.likes,
    required this.createdAt,
  });

  final String id;
  final String imageUrl;
  final String authorUrl;
  final String authorId;
  final String text;
  final int likes;
  final DateTime createdAt;

  factory Post.fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? <String, dynamic>{};
    final createdAt = data['createdAt'];

    return Post(
      id: document.id,
      imageUrl: data['imageUrl'] as String? ?? '',
      authorUrl: data['authorUrl'] as String? ?? '',
      authorId: data['authorId'] as String? ?? 'unknown_user',
      text: data['text'] as String? ?? '',
      likes: (data['likes'] as num?)?.toInt() ?? 0,
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
