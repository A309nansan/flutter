import 'package:flutter/material.dart';
import '../models/draw_line_models.dart';

class DrawLineDotWidget extends StatelessWidget {
  final DrawLineDot dot;
  final Size parentSize;
  final bool isSelected;
  final bool isHovered;
  final bool isConnected;
  final Function(PointerDownEvent, DrawLineDot) onPointerDown;

  const DrawLineDotWidget({
    super.key,
    required this.dot,
    required this.parentSize,
    required this.isSelected,
    required this.isHovered,
    required this.isConnected,
    required this.onPointerDown,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor = Colors.blue;
    if (isConnected) {
      dotColor = Colors.grey;
    } else if (isSelected) {
      dotColor = Colors.orange;
    } else if (isHovered) {
      dotColor = Colors.green;
    }

    final absolutePosition = Offset(
      dot.position.dx * parentSize.width,
      dot.position.dy * parentSize.height,
    );

    return Positioned(
      left: absolutePosition.dx - 15,
      top: absolutePosition.dy - 15,
      child: Listener(
        onPointerDown:
            isConnected ? null : (event) => onPointerDown(event, dot),
        child: MouseRegion(
          cursor:
              isConnected ? SystemMouseCursors.basic : SystemMouseCursors.click,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Center(
              child: Text(
                dot.key,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
