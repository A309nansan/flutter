import 'package:practice3/models/draggable2_drop_zone.dart';
import 'package:practice3/models/draggable2_image_card.dart';

class DragDrop2Controller {
  final Draggable2ImageCard sourceCard;

  DragDrop2Controller({String imageUrl = 'https://picsum.photos/seed/1/100'})
    : sourceCard = Draggable2ImageCard(id: 'source_card', imageUrl: imageUrl);

  final List<Draggable2DropZone> dropZones = [];
  int dropZoneCounter = 0;
  int cardCounter = 0;
  final double rowGap = 12.0;
  final int maxCardsPerZone = 10;

  void resetState([int? zoneId]) {
    if (zoneId != null) {
      final zones = dropZones.where((zone) => zone.id == zoneId);
      if (zones.isNotEmpty) {
        zones.first.cards.clear();
      }
    } else {
      for (var zone in dropZones) {
        zone.cards.clear();
      }
    }
  }

  void addCardToZone(Draggable2DropZone zone) {
    if (zone.cards.length < maxCardsPerZone) {
      final newCard = Draggable2ImageCard(
        id: 'card_${cardCounter++}',
        imageUrl: sourceCard.imageUrl,
      );
      zone.cards.add(newCard);
    }
  }

  void removeCardFromZone(Draggable2DropZone zone, Draggable2ImageCard card) {
    zone.cards.remove(card);
  }

  List<List<Draggable2ImageCard>> chunkCards(
    List<Draggable2ImageCard> cards,
    int chunkSize,
  ) {
    List<List<Draggable2ImageCard>> chunks = [];
    for (int i = 0; i < cards.length; i += chunkSize) {
      int end = (i + chunkSize < cards.length) ? i + chunkSize : cards.length;
      chunks.add(cards.sublist(i, end));
    }
    return chunks;
  }
}
