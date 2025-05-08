import 'package:flutter/material.dart';
import 'package:nansan_flutter/modules/drag_drop2/controllers/draggable2_controller.dart';
import 'package:nansan_flutter/modules/drag_drop2/models/draggable2_drop_zone.dart';
import 'package:nansan_flutter/modules/drag_drop2/models/draggable2_image_card.dart';
import 'package:nansan_flutter/modules/drag_drop2/widgets/draggable2_card.dart';

class Draggable2DropzoneWidget extends StatelessWidget {
  final Draggable2DropZone zone;
  final DragDrop2Controller controller;
  final Function(Draggable2DropZone) onReset;
  final Function(Draggable2DropZone, Draggable2ImageCard) onCardRemoved;
  final Function(Draggable2DropZone) onCardAdded;
  final double width;
  final double height;
  final double cardSize;

  const Draggable2DropzoneWidget({
    super.key,
    required this.zone,
    required this.controller,
    required this.onReset,
    required this.onCardRemoved,
    required this.onCardAdded,
    required this.width,
    required this.height,
    required this.cardSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => onReset(zone),
                tooltip: '이 영역만 초기화',
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildDragTarget(),
        ],
      ),
    );
  }

  Widget _buildDragTarget() {
    return DragTarget<Draggable2ImageCard>(
      builder: (context, candidateData, rejectedData) {
        final isFull = zone.cards.length >= controller.maxCardsPerZone;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color:
                isFull
                    ? Colors.red[100]
                    : candidateData.isNotEmpty
                    ? Colors.lightBlue[100]
                    : Colors.grey[200],
            border: Border.all(
              color:
                  isFull
                      ? Colors.red
                      : candidateData.isNotEmpty
                      ? Colors.blue
                      : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              zone.cards.isEmpty
                  ? Center(
                    child: Text(
                      isFull ? '최대 개수 도달 (더 이상 추가 불가)' : '여기에 카드 놓기 (최대 10개)',
                      style: TextStyle(
                        color: isFull ? Colors.red : Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  )
                  : _buildCardList(),
        );
      },
      onWillAcceptWithDetails: (data) {
        return zone.cards.length < controller.maxCardsPerZone;
      },
      onAcceptWithDetails: (data) {
        if (data.data.id == controller.sourceCard.id) {
          onCardAdded(zone);
        }
      },
    );
  }

  Widget _buildCardList() {
    // 화면 크기에 맞게 한 줄에 표시할 카드 수 계산
    int cardsPerRow = (width / (cardSize + 16)).floor();
    cardsPerRow = cardsPerRow > 0 ? cardsPerRow : 1;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (
              int i = 0;
              i < controller.chunkCards(zone.cards, cardsPerRow).length;
              i++
            ) ...[
              Row(
                children:
                    controller
                        .chunkCards(zone.cards, cardsPerRow)[i]
                        .map(
                          (card) => Draggable2Card(
                            imageUrl: card.imageUrl,
                            cardWidth: cardSize,
                            cardHeight: cardSize,
                            onTap: () => onCardRemoved(zone, card),
                          ),
                        )
                        .toList(),
              ),
              if (i < controller.chunkCards(zone.cards, cardsPerRow).length - 1)
                SizedBox(height: controller.rowGap),
            ],
          ],
        ),
      ),
    );
  }
}
