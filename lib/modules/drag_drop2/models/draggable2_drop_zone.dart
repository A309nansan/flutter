import 'package:nansan_flutter/modules/drag_drop2/models/draggable2_image_card.dart';

class Draggable2DropZone {
  final int id;
  final List<Draggable2ImageCard> cards = [];
  double width;
  double height;

  Draggable2DropZone({
    required this.id,
    required this.width,
    required this.height,
  });
}
