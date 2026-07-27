import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';

/// Lightweight vector-style spots (greens aligned with FoodScore auth / weekly UI).
enum AppSpotIllustrationKind {
  weeklyReflectionEmpty,
  registrationSuccess,
}

class AppSpotIllustration extends StatelessWidget {
  const AppSpotIllustration({
    super.key,
    required this.kind,
    this.size = 112,
  });

  final AppSpotIllustrationKind kind;
  final double size;

  static const Color _ring = Color(0xFF7FCB8F);
  static const Color _deep = Color(0xFF1A6731);
  static const Color _mid = Color(0xFF4A9E68);
  static const Color _soft = Color(0xFFE8F6E4);
  static const Color _mint = Color(0xFFB8E6C8);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.w,
      height: size.w,
      child: CustomPaint(
        painter: _AppSpotIllustrationPainter(kind: kind),
      ),
    );
  }
}

class _AppSpotIllustrationPainter extends CustomPainter {
  _AppSpotIllustrationPainter({required this.kind});

  final AppSpotIllustrationKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    final bg = Paint()..color = AppSpotIllustration._soft;
    canvas.drawCircle(center, radius * 0.92, bg);

    final ring = Paint()
      ..color = AppSpotIllustration._ring.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.06;
    canvas.drawCircle(center, radius * 0.78, ring);

    switch (kind) {
      case AppSpotIllustrationKind.weeklyReflectionEmpty:
        _paintWeeklyEmpty(canvas, size, center, radius);
      case AppSpotIllustrationKind.registrationSuccess:
        _paintRegistrationSuccess(canvas, size, center, radius);
    }
  }

  void _paintWeeklyEmpty(Canvas canvas, Size size, Offset center, double radius) {
    final bowl = Paint()..color = AppSpotIllustration._mid;
    final bowlRect = Rect.fromCenter(
      center: center.translate(0, radius * 0.08),
      width: radius * 1.05,
      height: radius * 0.52,
    );
    canvas.drawOval(bowlRect, bowl);

    final rim = Paint()
      ..color = AppSpotIllustration._deep
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.05;
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, radius * 0.02),
        width: radius * 1.12,
        height: radius * 0.28,
      ),
      rim,
    );

    final leaf = Paint()..color = AppSpotIllustration._mint;
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(-radius * 0.12, -radius * 0.05),
        width: radius * 0.22,
        height: radius * 0.14,
      ),
      leaf,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(radius * 0.08, -radius * 0.12),
        width: radius * 0.18,
        height: radius * 0.12,
      ),
      leaf,
    );

    final cal = Paint()
      ..color = AppSpotIllustration._deep.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.045
      ..strokeCap = StrokeCap.round;
    final calTop = center.translate(0, -radius * 0.42);
    canvas.drawLine(
      calTop.translate(-radius * 0.2, 0),
      calTop.translate(radius * 0.2, 0),
      cal,
    );
    canvas.drawLine(
      calTop.translate(-radius * 0.12, radius * 0.1),
      calTop.translate(-radius * 0.12, radius * 0.22),
      cal,
    );
    canvas.drawLine(
      calTop.translate(radius * 0.12, radius * 0.1),
      calTop.translate(radius * 0.12, radius * 0.22),
      cal,
    );
  }

  void _paintRegistrationSuccess(
    Canvas canvas,
    Size size,
    Offset center,
    double radius,
  ) {
    final circle = Paint()..color = AppSpotIllustration._mid;
    canvas.drawCircle(center, radius * 0.38, circle);

    final check = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.07
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(center.dx - radius * 0.14, center.dy)
      ..lineTo(center.dx - radius * 0.02, center.dy + radius * 0.12)
      ..lineTo(center.dx + radius * 0.18, center.dy - radius * 0.1);
    canvas.drawPath(path, check);

    final leaf = Paint()..color = AppSpotIllustration._ring;
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(radius * 0.42, -radius * 0.35),
        width: radius * 0.28,
        height: radius * 0.16,
      ),
      leaf,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(-radius * 0.45, radius * 0.38),
        width: radius * 0.24,
        height: radius * 0.14,
      ),
      leaf,
    );
  }

  @override
  bool shouldRepaint(covariant _AppSpotIllustrationPainter oldDelegate) {
    return oldDelegate.kind != kind;
  }
}
