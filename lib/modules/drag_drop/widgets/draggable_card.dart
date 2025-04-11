import 'package:flutter/material.dart';

import 'package:nansan_flutter/modules/drag_drop/models/card_data.dart';

class DraggableCard extends StatelessWidget {
  final CardData cardData;
  final double width;
  final double height;
  final VoidCallback? onRemove;
  final bool showRemoveButton;

  const DraggableCard({
    super.key,
    required this.cardData,
    required this.width,
    required this.height,
    this.onRemove,
    required this.showRemoveButton,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<CardData>(
      data: cardData,
      feedback: Material(child: _buildCard(Colors.white)),
      childWhenDragging: _buildCard(Colors.grey),
      child: _buildCard(Colors.white),
    );
  }

  Widget _buildCard(Color color) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black),
          ),
          child:
              cardData.imageUrl.isNotEmpty
                  ? FractionallySizedBox(
                    widthFactor: 0.85,
                    heightFactor: 0.85,
                    child: Image.network(
                      cardData.imageUrl,
                      fit: BoxFit.contain,
                    ),
                  )
                  : Center(
                    child: Text(
                      cardData.imageName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
        ),
        if (showRemoveButton)
          Positioned(
            right: -6,
            top: -6,
            width: 20,
            height: 20,
            child: SizedBox(
              width: 15,
              height: 15,
              child: ElevatedButton(
                onPressed: onRemove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: CircleBorder(),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'X',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
