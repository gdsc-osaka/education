import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book.dart';

class BookListNotifier extends Notifier<List<Book>> {
  @override
  List<Book> build() => const <Book>[];

  void add({
    required String title,
    String author = '',
    String note = '',
    int rating = 0,
  }) {
    final now = DateTime.now();
    final book = Book(
      id: now.microsecondsSinceEpoch.toString(),
      title: title.trim(),
      author: author.trim(),
      note: note.trim(),
      rating: rating,
      createdAt: now,
    );
    state = [book, ...state];
  }

  void update(Book book) {
    state = [
      for (final b in state)
        if (b.id == book.id) book else b,
    ];
  }

  Book? remove(String id) {
    final index = state.indexWhere((b) => b.id == id);
    if (index < 0) return null;
    final removed = state[index];
    state = [
      for (final b in state)
        if (b.id != id) b,
    ];
    return removed;
  }

  void restoreAt(int index, Book book) {
    if (index < 0 || index > state.length) {
      state = [...state, book];
      return;
    }
    state = [
      ...state.sublist(0, index),
      book,
      ...state.sublist(index),
    ];
  }

  int indexOf(String id) => state.indexWhere((b) => b.id == id);

  void toggleFavorite(String id) {
    state = [
      for (final b in state)
        if (b.id == id) b.copyWith(isFavorite: !b.isFavorite) else b,
    ];
  }
}

final bookListProvider =
    NotifierProvider<BookListNotifier, List<Book>>(BookListNotifier.new);

final favoriteFilterProvider = StateProvider<bool>((ref) => false);

final visibleBooksProvider = Provider<List<Book>>((ref) {
  final books = ref.watch(bookListProvider);
  final filterOn = ref.watch(favoriteFilterProvider);
  if (!filterOn) return books;
  return books.where((b) => b.isFavorite).toList();
});
