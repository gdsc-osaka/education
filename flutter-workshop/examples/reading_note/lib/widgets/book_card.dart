import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/book.dart';
import '../theme/app_theme.dart';
import 'star_rating.dart';

class BookCard extends StatefulWidget {
  final Book book;
  final int indexNumber;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const BookCard({
    super.key,
    required this.book,
    required this.indexNumber,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final date = DateFormat('yyyy.MM.dd').format(book.createdAt);
    final noStr = widget.indexNumber.toString().padLeft(2, '0');

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
          decoration: BoxDecoration(
            color: _hover
                ? AppPalette.paper.withValues(alpha: 0.6)
                : Colors.transparent,
            border: const Border(
              bottom: BorderSide(color: AppPalette.hairlineSoft, width: 0.6),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No.', style: editorialLabel(size: 9, letter: 1.6)),
                    const SizedBox(height: 4),
                    Text(
                      noStr,
                      style: editorialLabel(
                        size: 26,
                        letter: -0.5,
                        color: AppPalette.ink,
                      ).copyWith(
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(date, style: editorialLabel(size: 10, letter: 1.6)),
                        const SizedBox(width: 10),
                        Container(width: 14, height: 0.6, color: AppPalette.hairline),
                        const SizedBox(width: 10),
                        if (book.rating > 0)
                          StarRatingDisplay(value: book.rating, size: 13),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 22,
                            height: 1.25,
                            color: AppPalette.ink,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (book.author.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                              width: 14,
                              height: 0.8,
                              color: AppPalette.ink),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              book.author,
                              style: editorialItalic(
                                size: 14,
                                color: AppPalette.inkSoft,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (book.note.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        book.note,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppPalette.inkSoft,
                              height: 1.55,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _HeartButton(
                active: book.isFavorite,
                onTap: widget.onToggleFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeartButton extends StatefulWidget {
  final bool active;
  final VoidCallback onTap;
  const _HeartButton({required this.active, required this.onTap});

  @override
  State<_HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<_HeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final t = _ctrl.value;
            final scale = 1 + (math.sin(t * math.pi) * 0.25);
            return Transform.scale(
              scale: scale,
              child: Icon(
                widget.active
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                color: widget.active
                    ? AppPalette.accent
                    : AppPalette.hairline,
                size: 22,
              ),
            );
          },
        ),
      ),
    );
  }
}
