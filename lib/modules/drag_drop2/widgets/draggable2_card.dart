import 'package:flutter/material.dart';

class Draggable2Card extends StatelessWidget {
  final String imageUrl;
  final double cardWidth;
  final double cardHeight;
  final double opacity;
  final VoidCallback? onTap;

  const Draggable2Card({
    super.key,
    required this.imageUrl,
    required this.cardWidth,
    required this.cardHeight,
    this.opacity = 1.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardWidget = Opacity(
      opacity: opacity,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
          image: DecorationImage(
            image: AssetImage(imageUrl),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: cardWidget);
    }

    return cardWidget;
  }
}
