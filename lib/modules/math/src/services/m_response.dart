import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import '../../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
import '../models/m_problem_metadata.dart';
import '../_legacy_/recognition_state.dart';


/// 메인 MProblemPractice 위젯에서 분리한 로직 모음
class MResponse {
  /// 1) 인식 영역 초기화
  List<List<String>> recognitionCarryResults = [];
  List<List<String>> recognitionProgressResults = [];
  List<List<String>> recognitionAnswerResults = [];
  List<List<List<Stroke>>> carryStrokes = [];
  List<List<List<Stroke>>> progressStrokes = [];
  List<List<List<Stroke>>> answerStrokes = [];
  List<List<GlobalKey<HandwritingRecognitionZoneState>>>
  recognitionCarryZoneKeys = [];
  List<List<GlobalKey<HandwritingRecognitionZoneState>>>
  recognitionProgressZoneKeys = [];
  List<List<GlobalKey<HandwritingRecognitionZoneState>>>
  recognitionAnswerZoneKeys = [];
  List<int> matrixVolume = [];

  MResponse.initLite(List<List<List<String>>> storedResponse, List<int> matrixVolume){
    this.matrixVolume = matrixVolume;
    this.recognitionCarryResults = storedResponse[0];
    this.recognitionProgressResults = storedResponse[1];
    this.recognitionAnswerResults = storedResponse[2];
  }
  MResponse.init(
    List<List<List<String>>> initialResults,
    List<int> matrixVolume,
  ) {
    this.matrixVolume = matrixVolume;
    print("${this.matrixVolume}믿는다");
    recognitionCarryResults = List.generate(
      matrixVolume[0],
      (_) => List.generate(matrixVolume[1], (_) => ''),
    );
    recognitionProgressResults = List.generate(
      matrixVolume[2],
      (_) => List.generate(matrixVolume[3], (_) => ''),
    );
    recognitionAnswerResults = List.generate(
      matrixVolume[4],
      (_) => List.generate(matrixVolume[5], (_) => ''),
    );
    carryStrokes = List.generate(
      matrixVolume[0],
      (_) => List.generate(matrixVolume[1], (_) => <Stroke>[]),
    );
    progressStrokes = List.generate(
      matrixVolume[2],
      (_) => List.generate(matrixVolume[3], (_) => <Stroke>[]),
    );
    answerStrokes = List.generate(
      matrixVolume[4],
      (_) => List.generate(matrixVolume[5], (_) => <Stroke>[]),
    );
    recognitionCarryZoneKeys = generateGlobalKey2D(
      matrixVolume[0],
      matrixVolume[1],
      "carry",
    );
    recognitionProgressZoneKeys = generateGlobalKey2D(
      matrixVolume[2],
      matrixVolume[3],
      "progress",
    );
    recognitionAnswerZoneKeys = generateGlobalKey2D(
      matrixVolume[4],
      matrixVolume[5],
      "answer",
    );
    if (initialResults.isNotEmpty) {
      // 초기 결과를 복사해 옴
      for (int i = 0; i < matrixVolume[0]; i++) {
        for (int j = 0; j < matrixVolume[1]; j++) {
          recognitionCarryResults[i][j] = initialResults[0][i][j];
        }
      }
      for (int i = 0; i < matrixVolume[2]; i++) {
        for (int j = 0; j < matrixVolume[3]; j++) {
          recognitionProgressResults[i][j] = initialResults[1][i][j];
        }
      }
      for (int i = 0; i < matrixVolume[4]; i++) {
        for (int j = 0; j < matrixVolume[5]; j++) {
          recognitionAnswerResults[i][j] = initialResults[2][i][j];
        }
      }
    }
  }

  bool hasAnyInput(){
    // for (int i = 0; i < matrixVolume[0]; i++) {
    //   for (int j = 0; j < matrixVolume[1]; j++) {
    //     if (recognitionCarryResults[i][j] != "") return true;
    //   }
    // }
    // for (int i = 0; i < matrixVolume[2]; i++) {
    //   for (int j = 0; j < matrixVolume[3]; j++) {
    //     if (recognitionProgressResults[i][j] != "") return true;
    //   }
    // }
    for (int i = 0; i < matrixVolume[4]; i++) {
      for (int j = 0; j < matrixVolume[5]; j++) {
        if (recognitionAnswerResults[i][j] != "") return true;
      }
    }
    return false;
  }

  void toggleWritableState(bool enabled) {
    // carry
    print("✅✅✅✅✅✅✅✅✅");
    for (int i = 0; i < matrixVolume[0]; i++) {
      for (int j = 0; j < matrixVolume[1]; j++) {
        recognitionCarryZoneKeys[i][j].currentState?.updateEnableState(enabled);
      }
    }

    // progress
    for (int i = 0; i < matrixVolume[2]; i++) {
      for (int j = 0; j < matrixVolume[3]; j++) {
        recognitionProgressZoneKeys[i][j].currentState?.updateEnableState(enabled);
      }
    }

    // answer
    for (int i = 0; i < matrixVolume[4]; i++) {
      for (int j = 0; j < matrixVolume[5]; j++) {
        recognitionAnswerZoneKeys[i][j].currentState?.updateEnableState(enabled);
      }
    }
  }
  /// 2) 필기 결과를 숫자(String)으로 기록합니다.
  void setResults() {
    for (int i = 0; i < matrixVolume[0]; i++) {
      for (int j = 0; j < matrixVolume[1]; j++) {
        recognitionCarryResults[i][j] =
            recognitionCarryZoneKeys[i][j].currentState?.recognizedText ?? '';
      }
    }

    for (int i = 0; i < matrixVolume[2]; i++) {
      for (int j = 0; j < matrixVolume[3]; j++) {
        recognitionProgressResults[i][j] =
            recognitionProgressZoneKeys[i][j].currentState?.recognizedText ??
            '';
      }
    }

    for (int i = 0; i < matrixVolume[4]; i++) {
      for (int j = 0; j < matrixVolume[5]; j++) {
        recognitionAnswerResults[i][j] =
            recognitionAnswerZoneKeys[i][j].currentState?.recognizedText ?? '';
      }
    }
  }

  ///모든 칸을 비웁니다.
  void clearAll() {
    for (int i = 0; i < matrixVolume[0]; i++) {
      for (int j = 0; j < matrixVolume[1]; j++) {
        recognitionCarryZoneKeys[i][j].currentState?.clear();
        recognitionCarryZoneKeys[i][j].currentState?.updateBackgroundColor(Colors.transparent);
      }
    }
    // progress
    for (int i = 0; i < matrixVolume[2]; i++) {
      for (int j = 0; j < matrixVolume[3]; j++) {
        recognitionProgressZoneKeys[i][j].currentState?.clear();
        recognitionProgressZoneKeys[i][j].currentState?.updateBackgroundColor(Colors.transparent);
      }
    }
    // answer
    for (int i = 0; i < matrixVolume[4]; i++) {
      for (int j = 0; j < matrixVolume[5]; j++) {
        recognitionAnswerZoneKeys[i][j].currentState?.clear();
        recognitionAnswerZoneKeys[i][j].currentState?.updateBackgroundColor(Colors.transparent);
      }
    }
  }

  /// 결과값을 모르는 칸들의 내용을 표시하고 지웁니다.
  bool findUnknownInputAndClear() {
    bool hasWrong = false;
    // carry
    for (int i = 0; i < matrixVolume[0]; i++) {
      for (int j = 0; j < matrixVolume[1]; j++) {
        if (recognitionCarryResults[i][j] == "?") {
          hasWrong = true;

          recognitionCarryZoneKeys[i][j].currentState?.clear();
        }
      }
    }
    // progress
    for (int i = 0; i < matrixVolume[2]; i++) {
      for (int j = 0; j < matrixVolume[3]; j++) {
        if (recognitionProgressResults[i][j] == "?") {
          hasWrong = true;
          recognitionProgressZoneKeys[i][j].currentState?.clear();
        }
      }
    }
    // answer
    for (int i = 0; i < matrixVolume[4]; i++) {
      for (int j = 0; j < matrixVolume[5]; j++) {
        if (recognitionAnswerResults[i][j] == "?") {
          hasWrong = true;
          recognitionAnswerZoneKeys[i][j].currentState?.clear();
        }
      }
    }
    return hasWrong;
  }

  ///정답인지 아닌지 확인합니다.
  bool isAnswerValid(String response, String answer) {
    if (answer == "-1" ){
      if (response == "") {
        return true;
      } else {
        return false;
      }
    }
    if (answer != response) return false;
    return true;
  }

  void copyAnswer(List<List<List<String>>> answer) {}

  ///정답 여부를 바탕으로 다양한 색상을 입힙니다.
  void setBgColor(GlobalKey<HandwritingRecognitionZoneState> zoneKey,
      String result, String answer, bool isAnswer){
      if (!isAnswerValid(result, answer)){
        isAnswer ?
        zoneKey.currentState?.updateBackgroundColor(Colors.red.withOpacity(0.1)):
        zoneKey.currentState?.updateBackgroundColor(Colors.yellow.withOpacity(0.1));
      } else{
        if (answer != "-1") {
          zoneKey.currentState?.updateBackgroundColor(Colors.green.withOpacity(0.1));
        } else {
          zoneKey.currentState?.updateBackgroundColor(Colors.transparent);
        }
      }
      if (answer != "-1" && result == "" && !isAnswer) zoneKey.currentState?.updateBackgroundColor(Colors.lightGreenAccent.withOpacity(0.1));
    }

    void purgeBgColor(){
      for (int i = 0; i < matrixVolume[0]; i++) {
        for (int j = 0; j < matrixVolume[1]; j++) {
          recognitionCarryZoneKeys[i][j].currentState?.updateBackgroundColor(Colors.transparent);
        }
      }
      // progress
      for (int i = 0; i < matrixVolume[2]; i++) {
        for (int j = 0; j < matrixVolume[3]; j++) {
          recognitionProgressZoneKeys[i][j].currentState?.updateBackgroundColor(Colors.transparent);
        }
      }
      // answer
      for (int i = 0; i < matrixVolume[4]; i++) {
        for (int j = 0; j < matrixVolume[5]; j++) {
          recognitionAnswerZoneKeys[i][j].currentState?.updateBackgroundColor(Colors.transparent);
        }
      }
    }

    ///잘못된 입력값이 있는지를 확인합니다.
  bool setBgColorByAnswer(List<List<List<String>>> answer) {
    print("SETBGCOLORBYANSWER");
    printStrokes(answerStrokes);
    bool hasWrong = false;
    // carry
    for (int i = 0; i < matrixVolume[0]; i++) {
      for (int j = 0; j < matrixVolume[1]; j++) {
        setBgColor(
            recognitionCarryZoneKeys[i][j],
            recognitionCarryResults[i][j],
          answer[0][i][j],
          false);
      }
    }
    // progress
    for (int i = 0; i < matrixVolume[2]; i++) {
      for (int j = 0; j < matrixVolume[3]; j++) {
        setBgColor(
            recognitionProgressZoneKeys[i][j],
            recognitionProgressResults[i][j],
            answer[1][i][j],
            false);
      }
    }
    // answer
    for (int i = 0; i < matrixVolume[4]; i++) {
      for (int j = 0; j < matrixVolume[5]; j++) {
        setBgColor(
            recognitionAnswerZoneKeys[i][j],
            recognitionAnswerResults[i][j],
            answer[2][i][j],
            true);
      }
    }
    print(matrixVolume.toString() + " MATRIXVOLUME");
    if (matrixVolume[1] == 1){
      if (!isAnswerValid(recognitionCarryResults[0][0], answer[0][0][0])){
        recognitionCarryZoneKeys[0][0].currentState?.updateBackgroundColor(Colors.red.withOpacity(0.1));
      }
      if (matrixVolume[2] == 2){
        recognitionProgressZoneKeys[1][0].currentState?.updateBackgroundColor(Colors.transparent);
        recognitionProgressZoneKeys[1][1].currentState?.updateBackgroundColor(Colors.transparent);
      }
      if (matrixVolume[2] == 4){
        recognitionProgressZoneKeys[3][0].currentState?.updateBackgroundColor(Colors.transparent);
        recognitionProgressZoneKeys[3][0].currentState?.updateBackgroundColor(Colors.transparent);

      }


    }
    return hasWrong;

  }

  /// 4) _runRecognition
  Future<void> runRecognition(
    Function(List<List<List<String>>>) updateResults,
  ) async {
    // 1) 모든 키의 recognize() 호출
    final allKeys = [
      ...recognitionCarryZoneKeys.expand((row) => row),
      ...recognitionProgressZoneKeys.expand((row) => row),
      ...recognitionAnswerZoneKeys.expand((row) => row),
    ];
    for (int i = 0; i < matrixVolume[0]; i++) {
      for (int j = 0; j < matrixVolume[1]; j++) {
        final state = recognitionCarryZoneKeys[i][j].currentState;
        carryStrokes[i][j] = state?.getStrokes() ?? [];
      }
    }
    for (int i = 0; i < matrixVolume[2]; i++) {
      for (int j = 0; j < matrixVolume[3]; j++) {
        final state = recognitionProgressZoneKeys[i][j].currentState;
        progressStrokes[i][j] = state?.getStrokes() ?? [];
      }
    }
    for (int i = 0; i < matrixVolume[4]; i++) {
      for (int j = 0; j < matrixVolume[5]; j++) {
        final state = recognitionAnswerZoneKeys[i][j].currentState;
        answerStrokes[i][j] = state?.getStrokes() ?? [];
      }
    }
    await Future.wait(
      allKeys.map((key) => key.currentState?.recognize() ?? Future.value()),
    );
    setResults();
    updateResults([
      recognitionCarryResults,
      recognitionProgressResults,
      recognitionAnswerResults,
    ]);
  }
}

List<List<GlobalKey<HandwritingRecognitionZoneState>>> generateGlobalKey2D(
  int x,
  int y,
  String labelName,
) {
  return List.generate(
    x,
    (i) => List.generate(
      y,
      (j) => GlobalKey<HandwritingRecognitionZoneState>(
        debugLabel: 'problem${labelName}_col${i}_row${j}',
      ),
    ),
  );
}

void clearDrawingState(

  List<List<List<GlobalKey<HandwritingRecognitionZoneState>>>> totalKeyList,
) {
  print("CLEARDRAWINGSTATE");
  for (int i = 0; i < totalKeyList.length; i++) {
    for (var row in totalKeyList[i]) {
      for (var key in row) {
        key.currentState?.clear();
        key.currentState?.updateBackgroundColor(Colors.white54);
      }
    }
  }
}

void printStrokes(List<List<List<Stroke>>> strokeData) {
  for (int i = 0; i < strokeData.length; i++) {
    for (int j = 0; j < strokeData[i].length; j++) {
      print('[$i][$j]:');
      for (int k = 0; k < strokeData[i][j].length; k++) {
        print('  Stroke $k:');
      }
    }
  }
}
