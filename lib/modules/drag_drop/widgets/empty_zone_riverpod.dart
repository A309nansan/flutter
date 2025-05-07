import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nansan_flutter/modules/drag_drop/controllers/drag_drop_controller_riverpod.dart';
import 'package:nansan_flutter/modules/drag_drop/models/card_data.dart';
import 'draggable_card.dart';

class EmptyZoneRiverpod extends ConsumerWidget {
  final int zoneKey;
  final double width;
  final double height;
  final VoidCallback? onDrop;

  const EmptyZoneRiverpod({
    super.key,
    required this.zoneKey,
    this.width = 200,
    this.height = 200,
    this.onDrop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dragDropControllerProvider);
    final controller = ref.read(dragDropControllerProvider.notifier);
    final card = state.zoneCards[zoneKey];

    return DragTarget<CardData>(
      onWillAcceptWithDetails: (_) => true,
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
            color: candidateData.isNotEmpty ? Colors.blue.shade100 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: candidateData.isNotEmpty ? Colors.blue : Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: card != null
              ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: DraggableCard(
              width: 100,
              height: 100,
              cardData: card,
              showRemoveButton: true,
              onRemove: () => controller.handleCardRemoved(zoneKey),
            ),
          )
              : const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [])),
        );
      },
    );
  }
}
