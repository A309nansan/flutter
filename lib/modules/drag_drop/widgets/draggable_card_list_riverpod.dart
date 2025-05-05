import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nansan_flutter/modules/drag_drop/controllers/drag_drop_controller_riverpod.dart';
import 'package:nansan_flutter/modules/drag_drop/models/card_data.dart';
import 'draggable_card.dart';

class DraggableCardListRiverpod extends ConsumerStatefulWidget {
  final List<Map<String, String>> candidates;
  final double boxWidth;
  final double boxHeight;
  final double cardWidth;
  final double cardHeight;
  final bool showRemoveButton;

  const DraggableCardListRiverpod({
    super.key,
    required this.candidates,
    required this.boxWidth,
    required this.boxHeight,
    required this.cardWidth,
    required this.cardHeight,
    required this.showRemoveButton,
  });

  @override
  ConsumerState<DraggableCardListRiverpod> createState() => _DraggableCardListState();
}

class _DraggableCardListState extends ConsumerState<DraggableCardListRiverpod> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(dragDropControllerProvider.notifier);
      final available = ref.read(dragDropControllerProvider).availableCards;
      if (available.isEmpty) {
        final initialCards = widget.candidates
            .where((c) => c['image_name'] != null && c['image_url'] != null)
            .map((c) => CardData(
          id: c['image_name']!,
          imageName: c['image_name']!,
          imageUrl: c['image_url']!,
        ))
            .toList();
        controller.initializeCards(initialCards);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableCards = ref.watch(dragDropControllerProvider).availableCards;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      width: widget.boxWidth,
      height: widget.boxHeight,
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: availableCards
                  .map((card) => DraggableCard(
                showRemoveButton: widget.showRemoveButton,
                cardData: card,
                width: widget.cardWidth,
                height: widget.cardHeight,
              ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
