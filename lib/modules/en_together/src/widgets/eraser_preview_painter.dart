import 'package:flutter/material.dart';

class EraserPreviewPainter extends CustomPainter {
  final double radius;

  EraserPreviewPainter(this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius / 2, paint);
  }

  @override
  bool shouldRepaint(covariant EraserPreviewPainter oldDelegate) {
    return oldDelegate.radius != radius;
  }
}