import 'package:flutter/material.dart';

class EraserGuidePainter extends CustomPainter {
  final Offset? pointerPosition;
  final double radius;
  final bool isVisible;

  EraserGuidePainter({
    required this.pointerPosition,
    required this.radius,
    required this.isVisible,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isVisible || pointerPosition == null) return;

    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(pointerPosition!, radius, paint);
  }

  @override
  bool shouldRepaint(covariant EraserGuidePainter oldDelegate) {
    return oldDelegate.pointerPosition != pointerPosition ||
        oldDelegate.radius != radius ||
        oldDelegate.isVisible != isVisible;
  }
}