import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'draggable_image.dart';

class GridImage extends StatelessWidget {
  final List<ui.Image> images;
  final bool isFromDrawn;
  final void Function(int index)? onDelete;

  const GridImage({
    super.key,
    required this.images,
    required this.isFromDrawn,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
      child: images.isEmpty ?
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Opacity(
                  opacity: 0.3,
                  child: Image.asset(
                    "assets/empty_rabbit.png",
                    scale: screenWidth * 0.003,
                    color: Colors.black
                  )
                ),
                ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Image.asset(
                      "assets/empty_rabbit.png",
                      scale: screenWidth * 0.003,
                    )
                  )
                )
              ]
            ),
            Text(
              "그림이 없어요...",
              style: TextStyle(
                fontSize: screenWidth * 0.025,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      )
       :
      GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 20,
          mainAxisSpacing: 0
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final reversedIndex = images.length - index - 1;
          final image = images[reversedIndex];
          return Stack(
            alignment: Alignment.topRight,
            children: [
              DraggableImage(image: image),
              if (isFromDrawn)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => onDelete?.call(reversedIndex),
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
