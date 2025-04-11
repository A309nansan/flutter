import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nansan_flutter/modules/drag_drop/controllers/drag_drop_controller.dart';
import 'package:nansan_flutter/modules/drag_drop/models/card_data.dart';
import 'draggable_card.dart';

class DraggableCardList extends StatefulWidget {
  final List<Map<String, String>> candidates;
  final double boxWidth;
  final double boxHeight;
  final double cardWidth;
  final double cardHeight;
  final DragDropController controller;
  final bool showRemoveButton;

  const DraggableCardList({
    super.key,
    required this.candidates,
    required this.boxWidth,
    required this.boxHeight,
    required this.cardWidth,
    required this.cardHeight,
    required this.controller,
    required this.showRemoveButton,
  });

  @override
  State<DraggableCardList> createState() => _DraggableCardListState();
}

class _DraggableCardListState extends State<DraggableCardList> {
  late final DragDropController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _initializeController();
  }

  void _initializeController() {
    if (_controller.availableCards.isEmpty) {
      final initialCards =
          widget.candidates
              .where(
                (c) => c['image_name'] != null && c['image_url'] != null,
              ) // null 체크
              .map(
                (c) => CardData(
                  id: c['image_name']!,
                  imageName: c['image_name']!,
                  imageUrl: c['image_url']!,
                ),
              )
              .toList();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.availableCards.isEmpty) {
          _controller.initializeCards(initialCards);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DragDropController>(
      builder: (context, controller, _) {
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
                  children:
                      controller.availableCards
                          .map(
                            (card) => DraggableCard(
                              showRemoveButton: widget.showRemoveButton,
                              cardData: card,
                              width: widget.cardWidth,
                              height: widget.cardHeight,
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
