import 'dart:math';
import 'package:flutter/material.dart';
import '../models/draw_line_models.dart';

class DrawLinesPainter extends CustomPainter {
  final List<DrawLineConnection> connections;
  final DrawLineDot? startDot;
  final Offset? currentPosition;
  final bool isDrawingTemporaryLine;

  // dotAbsoluteOffsets 파라미터 제거

  DrawLinesPainter({
    required this.connections,
    this.startDot,
    this.currentPosition,
    this.isDrawingTemporaryLine = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final permanentPaint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    for (var connection in connections) {
      // 상대 위치를 캔버스 크기에 맞게 변환
      final p1 = _getPositionOnCanvas(connection.dot1.position, size);
      final p2 = _getPositionOnCanvas(connection.dot2.position, size);

      canvas.drawLine(p1, p2, permanentPaint);
    }

    if (isDrawingTemporaryLine && startDot != null && currentPosition != null) {
      final tempPaint =
          Paint()
            ..color = Colors.grey
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round;

      // 시작점을 상대 위치에서 변환
      final p1 = _getPositionOnCanvas(startDot!.position, size);

      drawDashedLine(
        canvas: canvas,
        p1: p1,
        p2: currentPosition!,
        dashWidth: 5,
        dashSpace: 3,
        paint: tempPaint,
      );
    }
  }

  // 상대 위치를 캔버스 위치로 변환하는 메서드 추가
  Offset _getPositionOnCanvas(Offset relativePosition, Size size) {
    return Offset(
      relativePosition.dx * size.width,
      relativePosition.dy * size.height,
    );
  }

  void drawDashedLine({
    required Canvas canvas,
    required Offset p1,
    required Offset p2,
    required int dashWidth,
    required int dashSpace,
    required Paint paint,
  }) {
    var dx = p2.dx - p1.dx;
    var dy = p2.dy - p1.dy;
    final magnitude = sqrt(dx * dx + dy * dy);
    if (magnitude == 0) return;

    dx = dx / magnitude;
    dy = dy / magnitude;

    final steps = magnitude ~/ (dashWidth + dashSpace);
    final int gap = dashWidth + dashSpace;

    var startX = p1.dx;
    var startY = p1.dy;

    for (int i = 0; i < steps; i++) {
      final endX = startX + dx * dashWidth;
      final endY = startY + dy * dashWidth;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);

      startX += dx * gap;
      startY += dy * gap;
    }

    final remaining = magnitude - steps * gap;
    if (remaining > 0) {
      final endX = startX + dx * min(remaining, dashWidth.toDouble());
      final endY = startY + dy * min(remaining, dashWidth.toDouble());

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(DrawLinesPainter oldDelegate) {
    return oldDelegate.connections != connections ||
        oldDelegate.startDot != startDot ||
        oldDelegate.currentPosition != currentPosition ||
        oldDelegate.isDrawingTemporaryLine != isDrawingTemporaryLine;
  }
}
