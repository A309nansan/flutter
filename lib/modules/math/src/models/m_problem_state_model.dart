import 'package:flutter/material.dart';

class MProblemStateModel extends ChangeNotifier {
  bool _hasAnswer = false;
  bool _isAnswerCorrect = false;
  bool _isShowingUserInput = true;
  bool _isWritingEnabled = true;
  bool get hasAnswer => _hasAnswer;
  bool get isAnswerCorrect => _isAnswerCorrect;
  bool get isShowingUserInput => _isShowingUserInput;
  bool get isWritingEnabled => _isWritingEnabled;
  bool _isFreeDrawingEnabled = false;
  bool get isFreeDrawingEnabled => _isFreeDrawingEnabled;

  late Future<void> Function() runRecognitionAndColor;
  late Future<void> Function() purgeColor;
  late void Function() erase;
  // 🔔 실행 함수
  Future<void> triggerRecognitionAndColor() async {
    await runRecognitionAndColor();
  }
  Future<void> triggerPurgeColor() async {
    await purgeColor();
  }
  void triggerErase() {
    print("TriggerEraseCalled");
    erase();
  }

  void setFreeDrawing(bool value) {
    _isFreeDrawingEnabled = value;
    notifyListenersWithDebug();
  }

  void toggleFreeDrawing() {
    _isFreeDrawingEnabled = !_isFreeDrawingEnabled;
    notifyListenersWithDebug();
  }

  void setHasAnswer(bool value) {
    _hasAnswer = value;
    notifyListenersWithDebug();
  }

  void toggleHasAnswer() {
    _hasAnswer = !_hasAnswer;
    notifyListenersWithDebug();
  }

  void setAnswerCorrect(bool value) {
    _isAnswerCorrect = value;
    notifyListenersWithDebug();
  }

  void toggleAnswerCorrect() {
    _isAnswerCorrect = !_isAnswerCorrect;
    notifyListenersWithDebug();
  }

  void setShowingUserInput(bool value) {
    _isShowingUserInput = value;
    notifyListenersWithDebug();
  }

  void toggleShowingUserInput() {
    _isShowingUserInput = !_isShowingUserInput;
    notifyListenersWithDebug();
  }

  void setWritingEnabled(bool value) {
    _isWritingEnabled = value;
    notifyListenersWithDebug();
  }

  void toggleWritingEnabled() {
    _isWritingEnabled = !_isWritingEnabled;
    notifyListenersWithDebug();
  }

  void notifyListenersWithDebug() {
    final stackTrace = StackTrace.current;
    final callerFunction = _getCallerFunctionName(stackTrace);
    print("🔔 notifyListeners called from: $callerFunction");
    print(toString());
    notifyListeners();
  }
  void printState(){

  }

  String toString() {
    return "hasAnswer: $_hasAnswer, isAnswerCorrect: $_isAnswerCorrect, isShowingUserInput: $isShowingUserInput, isWritingEnabled: $_isWritingEnabled";
  }

  String _getCallerFunctionName(StackTrace stack) {
    final lines = stack.toString().split('\n');
    if (lines.length > 1) {
      final match = RegExp(r'#1\s+([^(]+)').firstMatch(lines[1]);
      if (match != null) {
        return match.group(1)?.trim() ?? 'Unknown';
      }
    }
    return 'Unknown';
  }
}
