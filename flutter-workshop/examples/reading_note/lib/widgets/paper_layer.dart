import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PaperLayer extends StatelessWidget {
  final Widget child;
  const PaperLayer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.5, -0.85),
                radius: 1.6,
                colors: [
                  AppPalette.paper,
                  AppPalette.cream,
                  AppPalette.creamDeep,
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),
        const Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _PaperGrainPainter()),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 220,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppPalette.ink.withValues(alpha: 0.05),
                    AppPalette.cream.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _PaperGrainPainter extends CustomPainter {
  const _PaperGrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paintDark = Paint()..color = const Color(0x18000000);
    final paintLight = Paint()..color = const Color(0x22FFF6E0);
    final rng = math.Random(7);
    final count = (size.width * size.height / 1200).round();
    for (var i = 0; i < count; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height;
      final r = 0.3 + rng.nextDouble() * 0.5;
      canvas.drawCircle(Offset(dx, dy), r, rng.nextBool() ? paintDark : paintLight);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
