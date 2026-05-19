import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StarRatingInput extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  const StarRatingInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final index = i + 1;
        final filled = index <= value;
        return _StarButton(
          filled: filled,
          size: size,
          onTap: () {
            if (value == index) {
              onChanged(0);
            } else {
              onChanged(index);
            }
          },
        );
      }),
    );
  }
}

class _StarButton extends StatefulWidget {
  final bool filled;
  final double size;
  final VoidCallback onTap;

  const _StarButton({
    required this.filled,
    required this.size,
    required this.onTap,
  });

  @override
  State<_StarButton> createState() => _StarButtonState();
}

class _StarButtonState extends State<_StarButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.filled ? AppPalette.accent : AppPalette.hairline;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: AnimatedScale(
            scale: _hover ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: Tween(begin: 0.7, end: 1.0).animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(
                widget.filled ? Icons.star_rounded : Icons.star_outline_rounded,
                key: ValueKey(widget.filled),
                color: color,
                size: widget.size,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StarRatingDisplay extends StatelessWidget {
  final int value;
  final double size;
  final Color? color;

  const StarRatingDisplay({
    super.key,
    required this.value,
    this.size = 14,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (value <= 0) return const SizedBox.shrink();
    final c = color ?? AppPalette.accent;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < value;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: filled ? c : AppPalette.hairlineSoft,
            size: size,
          ),
        );
      }),
    );
  }
}
