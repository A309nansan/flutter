import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class DraggableImage extends StatelessWidget {
  final ui.Image image;
  final VoidCallback? onDelete;

  const DraggableImage({
    super.key,
    required this.image,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      alignment: Alignment.topRight,
      children: [
        Draggable<ui.Image>(
          data: image,
          feedback: Opacity(
            opacity: 0.7,
            child: RawImage(image: image, width: screenWidth * 0.5, height: screenHeight * 0.17),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: RawImage(image: image, width: screenWidth * 0.5, height: screenHeight * 0.17),
          ),
          child: ElevatedButton(
            onPressed: () {},
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.white,
                elevation: 2.0,
              ),
            child: RawImage(
              image: image,
              width: screenWidth * 0.5,
              height: screenHeight * 0.17
            )
          ),
        ),
        if (onDelete != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}