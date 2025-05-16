import 'package:flutter_riverpod/flutter_riverpod.dart';

final problemProgressProvider =
StateNotifierProvider<ProblemProgressNotifier, Map<String, bool>>(
        (ref) => ProblemProgressNotifier());

class ProblemProgressNotifier extends StateNotifier<Map<String, bool>> {
  ProblemProgressNotifier() : super({});

  void record(String problemCode, bool isCorrect) {
    state = {
      ...state,
      problemCode: isCorrect,
    };
  }

  void setFromStorage(Map<String, bool> saved) {
    state = {...saved};
  }

  void clear() {
    state = {};
  }

  String? get lastProblemCode {
    if (state.isEmpty) return null;
    return state.keys.last;
  }

  int get totalCount => state.length;
  int get correctCount =>
      state.values.where((result) => result == true).length;
}