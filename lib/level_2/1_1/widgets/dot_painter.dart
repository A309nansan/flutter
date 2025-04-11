import 'package:flutter/material.dart';import '../models/dot.dart';

class DotPainter extends CustomPainter {
  final List<Dot> dots;
  final List<List<Dot>> connections;
  final Offset? currentDragPosition;
  final Dot? startDot;

  DotPainter({
    required this.dots,
    required this.connections,
    this.currentDragPosition,
    this.startDot,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 10.0;

    // 이미 연결된 도트들의 선
    for (var connection in connections) {
      canvas.drawLine(connection[0].position, connection[1].position, linePaint);
    }

    // 드래그 중일 때 라인 미리 보여주기
    if (startDot != null && currentDragPosition != null) {
      final nearest = getNearestDotForPainting(currentDragPosition!, threshold: 20.0);
      final endPoint = nearest != null ? nearest.position : currentDragPosition!;
      canvas.drawLine(startDot!.position, endPoint, linePaint);
    }

    // 도트들 (작은 원)
    final dotPaint = Paint()..color = Colors.blue;
    for (var dot in dots) {
      canvas.drawCircle(dot.position, 7.0, dotPaint);
    }
  }

  Dot? getNearestDotForPainting(Offset pos, {double threshold = 20.0}) {
    for (var dot in dots) {
      if ((dot.position - pos).distance < threshold) {
        return dot;
      }
    }
    return null;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}