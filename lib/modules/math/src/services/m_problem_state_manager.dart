import 'package:flutter/foundation.dart';
import '../models/m_problem_state_model.dart';

class MProblemStateManager with ChangeNotifier {
  final List<MProblemStateModel> _stateList = [];

  void initStates(int count) {
    _stateList.clear();
    for (int i = 0; i < count; i++) {
      _stateList.add(MProblemStateModel());
    }
    notifyListeners();
  }

  void addState([MProblemStateModel? state]) {
    _stateList.add(state ?? MProblemStateModel());
    notifyListeners(); // 꼭 필요: Provider나 UI 업데이트 위해
  }

  MProblemStateModel get(int index) {
    if (index < 0 || index >= _stateList.length) {
      throw Exception("잘못된 문제 인덱스 접근: $index");
    }
    return _stateList[index];
  }

  int get length => _stateList.length;
}
