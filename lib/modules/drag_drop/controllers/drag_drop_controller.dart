import 'package:flutter/material.dart';
import 'package:nansan_flutter/modules/drag_drop/models/card_data.dart';

class DragDropController extends ChangeNotifier {
  List<CardData> _availableCards = [];
  final Map<int, CardData?> _zoneCards = {1: null, 2: null, 3: null, 4: null};

  List<CardData> get availableCards => _availableCards;
  Map<int, CardData?> get zoneCards => _zoneCards;

  void initializeCards(List<CardData> cards) {
    _availableCards = List.from(cards);
    notifyListeners();
  }

  void handleCardDropped(CardData card, int zoneKey) {
    _availableCards.removeWhere((c) => c.id == card.id);
    final sourceZone = _findSourceZone(card.id);
    final targetZoneCard = _zoneCards[zoneKey];

    sourceZone != null
        ? _swapCards(sourceZone, zoneKey, targetZoneCard)
        : _moveFromAvailable(card, zoneKey, targetZoneCard);

    notifyListeners();
  }

  void resetAll() {
    _zoneCards.forEach((key, _) => _zoneCards[key] = null);
    _availableCards.clear();
    notifyListeners();
  }

  int? _findSourceZone(String cardId) {
    for (final entry in _zoneCards.entries) {
      if (entry.value?.id == cardId) return entry.key;
    }
    return null;
  }

  void _swapCards(int srcKey, int tgtKey, CardData? tgtCard) {
    final srcCard = _zoneCards[srcKey];
    _zoneCards[srcKey] = tgtCard;
    _zoneCards[tgtKey] = srcCard;
  }

  void _moveFromAvailable(CardData card, int zoneKey, CardData? existing) {
    if (existing != null) _availableCards.add(existing);
    _availableCards.removeWhere((c) => c.id == card.id);
    _zoneCards[zoneKey] = card;
  }

  void handleCardRemoved(int zoneKey) {
    final removed = _zoneCards[zoneKey];
    if (removed != null) {
      _availableCards.add(removed);
      _zoneCards[zoneKey] = null;
      notifyListeners();
    }
  }

  void updateZoneCount(int newCount) {
    if (newCount > 0) {
      _zoneCards.clear();
      for (int i = 1; i <= newCount; i++) {
        _zoneCards[i] = null;
      }
      notifyListeners();
    }
  }
}
