import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';

class Masthead extends StatelessWidget {
  final int total;
  final int favoriteCount;
  final bool filterOn;
  final VoidCallback onToggleFilter;

  const Masthead({
    super.key,
    required this.total,
    required this.favoriteCount,
    required this.filterOn,
    required this.onToggleFilter,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy . MM . dd').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('JOURNAL  ·  No. ${total.toString().padLeft(2, '0')}',
                  style: editorialLabel(size: 11, letter: 2.4)),
              const Spacer(),
              Text(today, style: editorialLabel(size: 11, letter: 2.4)),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: AppPalette.ink),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '読書メモ',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: AppPalette.ink,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'a  reading  notebook',
                      style: editorialItalic(size: 16, color: AppPalette.accent),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _FavoriteFilterChip(
                active: filterOn,
                count: favoriteCount,
                onTap: onToggleFilter,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 0.6, color: AppPalette.hairlineSoft),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                filterOn ? 'お気に入りのみ表示中' : '所蔵：$total 件',
                style: editorialLabel(size: 10, letter: 2.0, color: AppPalette.inkMuted),
              ),
              Text(
                'GDG · UoO',
                style: editorialLabel(size: 10, letter: 2.0, color: AppPalette.inkMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FavoriteFilterChip extends StatefulWidget {
  final bool active;
  final int count;
  final VoidCallback onTap;

  const _FavoriteFilterChip({
    required this.active,
    required this.count,
    required this.onTap,
  });

  @override
  State<_FavoriteFilterChip> createState() => _FavoriteFilterChipState();
}

class _FavoriteFilterChipState extends State<_FavoriteFilterChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppPalette.ink : Colors.transparent,
            border: Border.all(
              color: active
                  ? AppPalette.ink
                  : (_hover ? AppPalette.ink : AppPalette.hairline),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                size: 14,
                color: active ? AppPalette.cream : AppPalette.ink,
              ),
              const SizedBox(width: 8),
              Text(
                active ? 'お気に入り' : 'すべて',
                style: editorialLabel(
                  size: 10,
                  letter: 1.8,
                  color: active ? AppPalette.cream : AppPalette.ink,
                ),
              ),
              if (widget.count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: active ? AppPalette.highlight : AppPalette.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
