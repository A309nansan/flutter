import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:nansan_flutter/modules/drag_drop2/controllers/draggable2_controller.dart';
import 'package:nansan_flutter/modules/drag_drop2/models/draggable2_drop_zone.dart';
import 'package:nansan_flutter/modules/drag_drop2/models/draggable2_image_card.dart';
import 'package:nansan_flutter/modules/drag_drop2/widgets/draggable2_card.dart';
import 'package:nansan_flutter/modules/drag_drop2/widgets/draggable2_drop_zone_widget.dart';

class DragDrop2DemoScreen extends StatefulWidget {
  const DragDrop2DemoScreen({super.key});

  @override
  State createState() => _DragDrop2DemoScreenState();
}

class _DragDrop2DemoScreenState extends State {
  final DragDrop2Controller dd2controller = DragDrop2Controller();
  late Draggable2DropZone mainDropZone;
  late Draggable2DropZone subDropZone;

  @override
  void initState() {
    super.initState();
  }

  //드래그 앤 드랍2 관련 로직
  void _resetState(Draggable2DropZone zone) {
    setState(() {
      dd2controller.resetState(zone.id);
    });
  }

  void _onCardRemoved(Draggable2DropZone zone, Draggable2ImageCard card) {
    setState(() {
      dd2controller.removeCardFromZone(zone, card);
    });
  }

  void _onCardAdded(Draggable2DropZone zone) {
    setState(() {
      dd2controller.addCardToZone(zone);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 화면 크기에 따라 드롭존 크기 계산
    final dropZoneWidth = screenWidth * 0.9;
    final dropZoneHeight = screenHeight * 0.25;

    // 카드 크기 계산 (화면 크기에 비례)
    final cardSize = screenWidth * 0.15; // 화면 너비의 15%

    // 드롭존 초기화 또는 업데이트
    if (dd2controller.dropZones.isEmpty) {
      mainDropZone = Draggable2DropZone(
        id: 1,
        width: dropZoneWidth,
        height: dropZoneHeight,
      );
      dd2controller.dropZones.add(mainDropZone);
      subDropZone = Draggable2DropZone(
        id: 2,
        width: dropZoneWidth,
        height: dropZoneHeight,
      );
      dd2controller.dropZones.add(subDropZone);
    } else {
      // 이미 존재하는 드롭존 업데이트
      mainDropZone = dd2controller.dropZones[0];
      mainDropZone.width = dropZoneWidth;
      mainDropZone.height = dropZoneHeight;

      subDropZone = dd2controller.dropZones[1];
      subDropZone.width = dropZoneWidth;
      subDropZone.height = dropZoneHeight;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 드래그 원본 카드
          const Text(
            '드래그 할 카드 (원본):',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Draggable(
            data: dd2controller.sourceCard,
            feedback: Material(
              elevation: 4.0,
              color: Colors.transparent,
              child: Draggable2Card(
                imageUrl: dd2controller.sourceCard.imageUrl,
                cardWidth: cardSize,
                cardHeight: cardSize,
                opacity: 0.7,
              ),
            ),
            childWhenDragging: Draggable2Card(
              imageUrl: dd2controller.sourceCard.imageUrl,
              cardWidth: cardSize,
              cardHeight: cardSize,
              opacity: 0.5,
            ),
            child: Draggable2Card(
              imageUrl: dd2controller.sourceCard.imageUrl,
              cardWidth: cardSize,
              cardHeight: cardSize,
            ),
          ),
          const SizedBox(height: 20),
          // 드롭 영역들
          Draggable2DropzoneWidget(
            zone: mainDropZone,
            controller: dd2controller,
            onReset: _resetState,
            onCardRemoved: _onCardRemoved,
            onCardAdded: _onCardAdded,
            width: mainDropZone.width,
            height: mainDropZone.height,
            cardSize: cardSize,
          ),
          Draggable2DropzoneWidget(
            zone: subDropZone,
            controller: dd2controller,
            onReset: _resetState,
            onCardRemoved: _onCardRemoved,
            onCardAdded: _onCardAdded,
            width: subDropZone.width,
            height: subDropZone.height,
            cardSize: cardSize,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
