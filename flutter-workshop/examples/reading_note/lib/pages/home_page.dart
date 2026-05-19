import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book.dart';
import '../state/book_list.dart';
import '../theme/app_theme.dart';
import '../widgets/book_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/masthead.dart';
import '../widgets/paper_layer.dart';
import 'book_edit_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBooks = ref.watch(bookListProvider);
    final visible = ref.watch(visibleBooksProvider);
    final filterOn = ref.watch(favoriteFilterProvider);

    return Scaffold(
      backgroundColor: AppPalette.cream,
      body: PaperLayer(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Masthead(
                      total: allBooks.length,
                      favoriteCount:
                          allBooks.where((b) => b.isFavorite).length,
                      filterOn: filterOn,
                      onToggleFilter: () => ref
                          .read(favoriteFilterProvider.notifier)
                          .state = !filterOn,
                    ),
                  ),
                  if (visible.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        isFiltered: filterOn && allBooks.isNotEmpty,
                      ),
                    )
                  else
                    SliverList.builder(
                      itemCount: visible.length + 1,
                      itemBuilder: (context, index) {
                        if (index == visible.length) {
                          return const _ListColophon();
                        }
                        final book = visible[index];
                        final number = visible.length - index;
                        return _StaggeredEntry(
                          index: index,
                          child: _DismissibleEntry(
                            book: book,
                            child: BookCard(
                              book: book,
                              indexNumber: number,
                              onTap: () => _openEdit(context, book),
                              onToggleFavorite: () => ref
                                  .read(bookListProvider.notifier)
                                  .toggleFavorite(book.id),
                            ),
                          ),
                        );
                      },
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _NewEntryButton(
        onPressed: () => _openEdit(context, null),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _openEdit(BuildContext context, Book? book) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 360),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, a, b) => BookEditPage(existing: book),
        transitionsBuilder: (_, anim, sec, child) {
          final curved =
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _StaggeredEntry extends StatelessWidget {
  final int index;
  final Widget child;
  const _StaggeredEntry({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (context, t, c) {
        return Opacity(
          opacity: t.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 14),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}

class _DismissibleEntry extends ConsumerWidget {
  final Book book;
  final Widget child;
  const _DismissibleEntry({required this.book, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('dismiss-${book.id}'),
      direction: DismissDirection.endToStart,
      background: const SizedBox.shrink(),
      secondaryBackground: const _DeleteBackground(),
      onDismissed: (_) {
        final notifier = ref.read(bookListProvider.notifier);
        final idx = notifier.indexOf(book.id);
        final removed = notifier.remove(book.id);
        if (removed == null) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text('「${removed.title}」を削除しました'),
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            action: SnackBarAction(
              label: '元に戻す',
              onPressed: () => notifier.restoreAt(idx, removed),
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      color: AppPalette.accent.withValues(alpha: 0.92),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'REMOVE',
            style: editorialLabel(
              size: 11,
              letter: 2.4,
              color: AppPalette.cream,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.delete_outline_rounded,
              color: AppPalette.cream, size: 20),
        ],
      ),
    );
  }
}

class _ListColophon extends StatelessWidget {
  const _ListColophon();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Container(height: 0.6, color: AppPalette.hairline)),
              const SizedBox(width: 12),
              Text('— fin —',
                  style: editorialItalic(size: 13, color: AppPalette.inkMuted)),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 0.6, color: AppPalette.hairline)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Printed with care · Riverpod × Flutter',
            style: editorialLabel(size: 9, letter: 2.4),
          ),
        ],
      ),
    );
  }
}

class _NewEntryButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _NewEntryButton({required this.onPressed});

  @override
  State<_NewEntryButton> createState() => _NewEntryButtonState();
}

class _NewEntryButtonState extends State<_NewEntryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding:
                const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
            decoration: BoxDecoration(
              color: AppPalette.ink,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              boxShadow: [
                BoxShadow(
                  color: AppPalette.ink.withValues(alpha: _hover ? 0.30 : 0.18),
                  blurRadius: _hover ? 24 : 14,
                  offset: Offset(0, _hover ? 8 : 4),
                ),
              ],
              border: Border.all(color: AppPalette.ink),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedRotation(
                  turns: _hover ? 0.125 : 0,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                  child: const Icon(Icons.add_rounded,
                      color: AppPalette.cream, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  '新しいエントリー',
                  style: editorialLabel(
                    size: 12,
                    letter: 1.8,
                    color: AppPalette.cream,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppPalette.highlight,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
