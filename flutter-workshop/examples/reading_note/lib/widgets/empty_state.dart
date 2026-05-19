import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final bool isFiltered;
  const EmptyState({super.key, this.isFiltered = false});

  @override
  Widget build(BuildContext context) {
    final headline = isFiltered ? 'お気に入りはまだありません' : 'まだ何も書いていません';
    final subtitle = isFiltered
        ? 'ハートをタップして、お気に入りを選んでみましょう。'
        : '下の「＋ 新しいエントリー」から、\n最初の一冊を書きとめてみましょう。';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StampedIcon(icon: isFiltered ? Icons.favorite_rounded : Icons.menu_book_rounded),
              const SizedBox(height: 28),
              Text(
                isFiltered ? 'FAVORITES · 空' : 'JOURNAL · 空白の頁',
                style: editorialLabel(size: 11, letter: 2.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                headline,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 40,
                child: Container(height: 1, color: AppPalette.hairline),
              ),
              const SizedBox(height: 18),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StampedIcon extends StatelessWidget {
  final IconData icon;
  const _StampedIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppPalette.accent.withValues(alpha: 0.55), width: 1.4),
        color: AppPalette.accent.withValues(alpha: 0.04),
      ),
      child: Center(
        child: Icon(icon, size: 40, color: AppPalette.accent.withValues(alpha: 0.85)),
      ),
    );
  }
}
