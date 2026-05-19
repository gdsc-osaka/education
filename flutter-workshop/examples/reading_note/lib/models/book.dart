import 'package:flutter/foundation.dart';

@immutable
class Book {
  final String id;
  final String title;
  final String author;
  final String note;
  final int rating;
  final bool isFavorite;
  final DateTime createdAt;

  const Book({
    required this.id,
    required this.title,
    this.author = '',
    this.note = '',
    this.rating = 0,
    this.isFavorite = false,
    required this.createdAt,
  });

  Book copyWith({
    String? title,
    String? author,
    String? note,
    int? rating,
    bool? isFavorite,
  }) {
    return Book(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      note: note ?? this.note,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
    );
  }
}
