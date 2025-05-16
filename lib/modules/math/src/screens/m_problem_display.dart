import 'package:flutter/material.dart';
import 'package:nansan_flutter/modules/math/src/widgets/return_answer_page.dart';
import 'package:nansan_flutter/modules/math/src/widgets/return_problem_page.dart';
import '../models/m_problem_metadata.dart';
import '../models/m_problem_state_model.dart';
import '../services/m_response.dart';

class MProblemDisplay extends StatefulWidget {
  final MProblemMetadata problemMetaData;
  final bool isLectureMode;
  final Function(bool isCorrect) onCheckCorrect;
  final List<List<List<String>>> correctResponse3DList;
  final MResponse userResponse;
  final MProblemStateModel stateModel;

  const MProblemDisplay({
    super.key,
    required this.problemMetaData,
    required this.isLectureMode,
    required this.onCheckCorrect,
    required this.correctResponse3DList,
    required this.userResponse,
    required this.stateModel,
  });

  @override
  MProblemDisplayState createState() => MProblemDisplayState();
}

class MProblemDisplayState extends State<MProblemDisplay> {
  int get number1 => widget.problemMetaData.num1;
  int get number2 => widget.problemMetaData.num2;
  bool get isOneDigit => widget.problemMetaData.type == "SingleLine";
  bool get isAddSub => widget.problemMetaData.type == "AddSub";
  bool get isMultiplication => widget.problemMetaData.type == "Multiplication";
  bool get isDivision => widget.problemMetaData.type == "Division";
  bool get isDivisionRemainder =>
      widget.problemMetaData.type == "DivisionRemainder";
  List<List<List<String>>> recognitionTotalResults = [];

  ///인식된 결과를 바탕으로 userResponse 상태를 업데이트함.
  void _updateUserResponseResults(List<List<List<String>>> newResults) {
    setState(() {
      widget.userResponse.recognitionCarryResults = newResults[0];
      widget.userResponse.recognitionProgressResults = newResults[1];
      widget.userResponse.recognitionAnswerResults = newResults[2];
      recognitionTotalResults = [newResults[0], newResults[1], newResults[2]];
    });
  }

  ///responseBlock들을 적절히 색칠함.
  Future<void> colorResponseBlocks() async {
    debugPrint("🎨버튼 색깔을 입힙니다.🎨");
    widget.userResponse.setBgColorByAnswer(widget.correctResponse3DList);
  }

  ///responseBlock들을 지움(초기화)함.
  Future<void> clearResponseBlocks() async {
    if (!widget.stateModel.isShowingUserInput) {
      return;
    }
    widget.userResponse.clearAll();
    widget.stateModel.setHasAnswer(false);
  }

  Future<bool> recognizeAndValidate() async {
    await widget.userResponse.runRecognition(_updateUserResponseResults);
    final bool hasUnrecognized = widget.userResponse.findUnknownInputAndClear();
    if (hasUnrecognized) return false;
    if (widget.userResponse.hasAnyInput()) {
      widget.stateModel.setHasAnswer(true);
      final isCorrect = _evaluateUserAnswer();
      widget.stateModel.setAnswerCorrect(isCorrect);
      widget.onCheckCorrect(isCorrect);
    }

    return true;
  }

  ///유저의 답안이 제공된 정답과 일치하는지 확인
  bool _evaluateUserAnswer() {
    if (!widget.userResponse.hasAnyInput()) return false;
    //debugPrint("LET ME CHECK");
    for (int i = 0; i < widget.problemMetaData.matrixVolume[5]; i++) {
      if (!widget.userResponse.isAnswerValid(
        recognitionTotalResults[2][0][i],
        widget.correctResponse3DList[2][0][i],
      )) {
        return false;
      }
    }
    //debugPrint("LET ME CHECK FINISH");
    if (widget.problemMetaData.matrixVolume[1] == 1) {
      if (!widget.userResponse.isAnswerValid(
        recognitionTotalResults[0][0][0],
        widget.correctResponse3DList[0][0][0],
      )) {
        return false;
      }
    }
    return true;
  }


  Future<void> purgeColor() async {
    widget.userResponse.purgeBgColor();
  }

  void erase() {
    widget.userResponse.clearAll();
  }

  ///Recognition을 실행하고, 오류 판단과 display까지 진행함. 리팩토링 필요.
  Future<void> runRecognitionAndColor() async {
    debugPrint("RECOGNITION START");

    showRecognitionDialog(); // 👉 로딩 시작

    try {
      final success = await recognizeAndValidate();
      debugPrint("TRY CATCH 1, success: $success");
      if (!success) {
        debugPrint("TRY CATCH 2");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("인식 안 된 칸이 있습니다.")));
        return;
      }
      if (!widget.userResponse.hasAnyInput()) {
        debugPrint("TRY CATCH has no input");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("아무 입력도 하지 않았습니다.")));
        return;
      }

      debugPrint("TRY CATCH 3");
      // 인식 성공 + 입력 있음 👉 색칠
      await colorResponseBlocks();
      debugPrint("TRY CATCH 4");
      debugPrint("RESULT: ${widget.stateModel.isAnswerCorrect}");
      debugPrint("TRY CATCH 5");
    } finally {
      debugPrint("HIDE DIALOG start");
      hideRecognitionDialog(); // ✅ 무조건 마지막에 닫힘!
      debugPrint("HIDE DIALOG end");
    }
  }

  void showRecognitionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (_) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 8),
                Text("로딩 중..."),
              ],
            ),
          ),
        );
      },
    );
  }

  void hideRecognitionDialog() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
  @override
  void initState() {
    super.initState();
    recognitionTotalResults = [
      widget.userResponse.recognitionCarryResults,
      widget.userResponse.recognitionProgressResults,
      widget.userResponse.recognitionAnswerResults,
    ];
    widget.stateModel.addListener(_onModelChanged);
    widget.stateModel.runRecognitionAndColor = runRecognitionAndColor;
    widget.stateModel.purgeColor = purgeColor;
    widget.stateModel.erase = erase;
    if (widget.userResponse.hasAnyInput()) {
      debugPrint("이미 작성된 정답이 있습니다");
      colorResponseBlocks();
    } else {
      debugPrint("아직 작성된 답이 없습니다");
    }
  }

  @override
  void didUpdateWidget(covariant MProblemDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userResponse.hasAnyInput()) {
      debugPrint("이미 작성된 정답이 있습니다-didupdatewidget");
      colorResponseBlocks();
    } else {
      debugPrint("아직 작성된 답이 없습니다-didupdatewidget");
    }
  }

  void _onModelChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.stateModel.removeListener(_onModelChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent, // 배경색 (필요에 따라 변경 가능)
        border: Border.all(
          color: Colors.transparent, // 테두리 색상
          width: 3, // 테두리 두께
        ),
        borderRadius: BorderRadius.circular(16), // 둥근 모서리
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝 정렬
        children: [
          if (widget.stateModel.isShowingUserInput)
            buildProblemWidget(
              mathData: widget.problemMetaData,
              initialResult: recognitionTotalResults,
              onResultUpdated: _updateUserResponseResults,
              userResponse: widget.userResponse,
              onCleared: () {
                setState(() {
                  widget.stateModel.setHasAnswer(false);
                });
              },
            ),
          if (!widget.stateModel.isShowingUserInput)
            buildAnswerWidget(
              mathData: widget.problemMetaData,
              userResponse: widget.userResponse,
              answer: widget.correctResponse3DList,
              isShowingUserInput: false,
              onCleared: () {
                setState(() {
                  widget.stateModel.setHasAnswer(false);
                });
              },
            ),
        ],
      ),
    );
  }
}
