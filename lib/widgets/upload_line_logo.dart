import 'package:flutter/material.dart';

/// 由横线组成的上传/拍照 logo，CustomPaint 绘制。
class UploadLineLogo extends StatelessWidget {
  const UploadLineLogo({
    super.key,
    required this.color,
    this.width = 52,
    this.height = 42,
    this.strokeWidth = 2.8,
  });

  final Color color;
  final double width;
  final double height;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _UploadLineLogoPainter(
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _UploadLineLogoPainter extends CustomPainter {
  _UploadLineLogoPainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    final double w = size.width;
    final double h = size.height;

    // U 形托盘（底部基座）
    final trayTop = h * 0.56;
    final tray = Path()
      ..moveTo(w * 0.05, trayTop)
      ..lineTo(w * 0.05, h * 0.92)
      ..lineTo(w * 0.95, h * 0.92)
      ..lineTo(w * 0.95, trayTop);
    canvas.drawPath(tray, paint);

    // 箭头竖线（向下延伸至托盘开口附近）
    final shaftBottom = h * 0.54;
    final shaftTop = h * 0.06;
    canvas.drawLine(
      Offset(w * 0.5, shaftBottom),
      Offset(w * 0.5, shaftTop),
      paint,
    );

    // 箭头头部（与竖线衔接）
    final head = Path()
      ..moveTo(w * 0.24, h * 0.32)
      ..lineTo(w * 0.5, h * 0.04)
      ..lineTo(w * 0.76, h * 0.32);
    canvas.drawPath(head, paint);
  }

  @override
  bool shouldRepaint(covariant _UploadLineLogoPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
