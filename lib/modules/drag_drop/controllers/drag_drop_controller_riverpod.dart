import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nansan_flutter/modules/drag_drop/models/card_data.dart';

final dragDropControllerProvider =
NotifierProvider<DragDropControllerRiverpod, DragDropState>(
    DragDropControllerRiverpod.new);

class DragDropState {
  final List<CardData> availableCards;
  final Map<int, CardData?> zoneCards;

  const DragDropState({
    this.availableCards = const [],
    this.zoneCards = const {1: null, 2: null, 3: null, 4: null},
  });

  DragDropState copyWith({
    List<CardData>? availableCards,
    Map<int, CardData?>? zoneCards,
  }) {
    return DragDropState(
      availableCards: availableCards ?? this.availableCards,
      zoneCards: zoneCards ?? this.zoneCards,
    );
  }
}

class DragDropControllerRiverpod extends Notifier<DragDropState> {
  @override
  DragDropState build() => const DragDropState();

  void initializeCards(List<CardData> cards) {
    state = state.copyWith(availableCards: List.from(cards));
  }

  void handleCardDropped(CardData card, int zoneKey) {
    final available = [...state.availableCards]..removeWhere((c) => c.id == card.id);
    final zones = {...state.zoneCards};

    final sourceZone = _findSourceZone(card.id);
    final targetCard = zones[zoneKey];

    if (sourceZone != null) {
      // swap
      final tmp = zones[sourceZone];
      zones[sourceZone] = targetCard;
      zones[zoneKey] = tmp;
    } else {
      // move from available
      if (targetCard != null) {
        available.add(targetCard);
      }
      zones[zoneKey] = card;
    }

    state = state.copyWith(
      availableCards: available,
      zoneCards: zones,
    );
  }

  void handleCardRemoved(int zoneKey) {
    final removed = state.zoneCards[zoneKey];
    if (removed != null) {
      final updatedAvailable = [...state.availableCards, removed];
      final updatedZones = {...state.zoneCards}..[zoneKey] = null;
      state = state.copyWith(
        availableCards: updatedAvailable,
        zoneCards: updatedZones,
      );
    }
  }

  void resetAll() {
    final resetZones = <int, CardData?>{};
    for (final key in state.zoneCards.keys) {
      resetZones[key] = null;
    }
    state = state.copyWith(
      availableCards: [],
      zoneCards: resetZones,
    );
  }

  void updateZoneCount(int newCount) {
    final newZones = <int, CardData?>{};
    for (int i = 1; i <= newCount; i++) {
      newZones[i] = null;
    }
    state = state.copyWith(zoneCards: newZones);
  }

  int? _findSourceZone(String cardId) {
    for (final entry in state.zoneCards.entries) {
      if (entry.value?.id == cardId) return entry.key;
    }
    return null;
  }
}
