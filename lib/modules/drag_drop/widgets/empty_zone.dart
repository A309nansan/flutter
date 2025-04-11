import 'package:flutter/material.dart';
import 'package:nansan_flutter/modules/drag_drop/controllers/drag_drop_controller.dart';
import 'package:nansan_flutter/modules/drag_drop/models/card_data.dart';
import 'package:provider/provider.dart';
import 'draggable_card.dart';

class EmptyZone extends StatelessWidget {
  final int zoneKey;
  final double width;
  final double height;
  final VoidCallback? onDrop;

  const EmptyZone({
    super.key,
    required this.zoneKey,
    this.width = 200,
    this.height = 200,
    this.onDrop,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DragDropController>(context, listen: true);
    final card = controller.zoneCards[zoneKey];

    return DragTarget<CardData>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        controller.handleCardDropped(details.data, zoneKey);
        onDrop?.call();
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color:
                candidateData.isNotEmpty
                    ? Colors.blue.shade100
                    : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  candidateData.isNotEmpty ? Colors.blue : Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: _buildZoneContent(card, controller),
        );
      },
    );
  }

  Widget _buildZoneContent(CardData? card, DragDropController controller) {
    if (card != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DraggableCard(
          width: 100,
          height: 100,
          cardData: card,
          showRemoveButton: true,
          onRemove: () => controller.handleCardRemoved(zoneKey),
        ),
      );
    }

    return const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: []),
    );
  }
}
