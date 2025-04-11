import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../../shared/widgets/appbar_widget.dart';
import '../../../../shared/widgets/new_header_widget.dart';
import '../../../../shared/widgets/new_question_text.dart';
import '../../../../shared/widgets/successful_popup.dart';
import '../models/evaluation_status.dart';
import '../services/basa_math_decoder.dart';
import '../services/basa_math_encoder.dart';
import '../services/feedback_animator_service.dart';
import '../services/m_problem_manager.dart';
import '../services/m_problem_state_manager.dart';
import '../utils/math_ui_constant.dart';
import '../widgets/m_animator/m_feedback_lottie_widget.dart';
import '../widgets/m_index_presenter.dart';
import '../widgets/m_index_presenter_new.dart';
import '../widgets/m_lecture_loading_screen.dart';
import 'm_lecture_continue_dialog.dart';
import 'm_problem_display.dart';
import 'm_problem_switch_button.dart';
import '../_legacy_/m_lecture_stats_screen.dart';
import 'm_lecture_tutorial_dialog.dart';


class MLectureScreen extends StatefulWidget {
  final int categoryIndex;
  final String categoryName;
  final String categoryDescription;
  final String imageURL;
  final bool isTeachingMode;
  final int problemCount;

  const MLectureScreen({
    super.key,
    required this.categoryIndex,
    required this.categoryName,
    required this.categoryDescription,
    required this.imageURL,
    required this.isTeachingMode,
    this.problemCount = 5,
  });

  @override
  State<MLectureScreen> createState() => _MLectureScreenState();
}

class _MLectureScreenState extends State<MLectureScreen>
    with TickerProviderStateMixin {
  late final MProblemManager _PM;
  late final MProblemStateManager _PSM;
  List<EvaluationStatus> evaluationResults = [];

  //0:아직 안품,

  //자료 구조
  double iconSize = MathUIConstant.iconSize;

  int get categoryRaw => widget.categoryIndex;
  late int parentCategory = categoryRaw ~/ 100;
  late int childCategory = categoryRaw % 10;

  //인덱스
  int idx = 0;
  bool _minLoadingTimePassed = false;

  //비동기 데이터
  final BasaMathDecoder _bmDecode = BasaMathDecoder();
  final BasaMathEncoder _bmEncode = BasaMathEncoder();

  bool _isLoading = true;
  bool _autoMode = false;
  bool showSubmitPopup = false;
  bool submitPopupIsCorrect = false;
  late AnimationController submitController;
  late Animation<double> submitAnimation;
  @override
  void initState() {
    super.initState();
    _PM = MProblemManager(_bmDecode, _bmEncode);
    _PSM = MProblemStateManager();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepareFirstProblem(); // async 초기화 따로 호출
    });
    submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    submitAnimation = CurvedAnimation(
      parent: submitController,
      curve: Curves.easeOutBack,
    );
  }

  Future<void> _prepareFirstProblem() async {
    setState(() {
      _isLoading = true;
      _minLoadingTimePassed = false;
    });

    Future.delayed(Duration(milliseconds: MathUIConstant.loadingTime), () {
      setState(() {
        _minLoadingTimePassed = true;
      });
    });
    await prepareNextProblem(); // 꼭 await 해야 합니다!
    setState(() {
      _isLoading = false; // 이제 진짜 준비 끝났을 때만 false
    });
  }

  bool _isPreparingNextProblem = false;

  Future<void> prepareNextProblem() async {
    if (_isPreparingNextProblem) return; // 중복 호출 방지
    _isPreparingNextProblem = true;
    try {
      await _PM.load(parentCategory, childCategory, idx, widget.categoryIndex);
      _PSM.addState();
      evaluationResults.add(EvaluationStatus.unSolved);
      setState(() {}); // 새 문제 반영
    } catch (e) {
      // 여기에 SnackBar 또는 AlertDialog 넣을 수도 있음
    } finally {
      _isPreparingNextProblem = false;
    }
  }

  void _activateAutoMode() {
    setState(() {
      _autoMode = !_autoMode;

      // ✅ 애니메이션 트리거 상태 초기화
      if (_autoMode) {
        FeedbackAnimatorService().clear();
      }
    });
  }
  Future<void> _incrementCounter() async {
    if (idx >= _PM.history.length - 1) return;
    setState(() {
      idx++;
    });
  }

  Future<void> _getNextProblem() async {
    final nextIndex = idx + 1;
    if (nextIndex % widget.problemCount == 0 && nextIndex != 0) {
      final shouldContinue = await showContinueDialog(
        widget.categoryIndex,
        widget.categoryName,
        widget.imageURL,
        widget.categoryDescription,
        widget.isTeachingMode,
        context,
      );
      if (!shouldContinue) {
        Navigator.of(context).pop(); // 화면 나가기
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    if (_PM.history.length <= nextIndex) {
      await prepareNextProblem();
    }
    setState(() {
      idx = nextIndex;

      _isLoading = false;
    });
  }

  void _decrementCounter() {
    if (idx <= 0) return;
    setState(() {
      idx--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    double unitSize = MathUIConstant.hSize;
    return Scaffold(
      appBar: AppbarWidget(
        title: null,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 40.0),
          onPressed: () => Modular.to.pop(),
        ),
      ),

      body: Container(
        //Screenshot으로 감쌀 수 있음.
        margin: EdgeInsets.fromLTRB(
          unitSize * 0.15,
          unitSize * 0.2,
          unitSize * 0.15,
          unitSize * 0.1,
        ),
        decoration: BoxDecoration(
          color: Colors.white, // 배경색 (필요에 따라 변경 가능)
          border: Border.all(
            color: MathUIConstant.boundaryPurple,
            width: 3, // 테두리 두께
          ),
          borderRadius: BorderRadius.circular(16), // 둥근 모서리
        ),
        child: Stack(
          children: [
            if (evaluationResults.isNotEmpty && idx < evaluationResults.length- 1)
              Positioned(
                bottom: 0,
                left: 0,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _buildStatusImage(evaluationResults[idx]),
                ),
              ),
            Center(
              child:
                  !_minLoadingTimePassed
                      ? MLectureLoadingScreen(
                        isTeachingMode: widget.isTeachingMode,
                      )
                      : (_isLoading || _PM.history.length <= idx)
                      ? const CircularProgressIndicator()
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IndexPresenterNew(
                                      indexLabel:
                                          widget.isTeachingMode
                                              ? idx + 1
                                              : _PM
                                                  .get(idx)
                                                  .problemMetaData
                                                  .index,
                                    ),
                                    SizedBox(width: unitSize * 0.2),
                                    Text(
                                      widget.categoryName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.fast_forward),
                                      onPressed: _activateAutoMode,
                                      iconSize:
                                          MathUIConstant.helperIconSizeSmall,
                                      color:
                                          _autoMode
                                              ? Colors.green
                                              : Color(0xFF999797),
                                    ),
                                    SizedBox(width: unitSize * 0.1),
                                    IconButton(
                                      onPressed:
                                          () => showTutorialDialog(
                                            context,
                                            widget.isTeachingMode,
                                            widget.categoryIndex,
                                          ),
                                      icon: Icon(
                                        Icons.lightbulb,
                                        size:
                                            MathUIConstant.helperIconSizeSmall,
                                        color: Colors.yellow,
                                        shadows: [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(77),
                                            blurRadius: 3,
                                            offset: const Offset(1, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 50),

                          Spacer(flex: 4),
                          Column(
                            children: [
                              MProblemDisplay(
                                key: _PM.get(idx).problemDisplayKey,
                                problemMetaData: _PM.get(idx).problemMetaData,
                                isLectureMode: false,
                                correctResponse3DList:
                                    _PM.get(idx).correctResponse3DList,
                                userResponse: _PM.get(idx).userResponse,
                                onCheckCorrect: (bool isCorrect) {
                                  final currentPM = _PM.get(idx);
                                  final currentUserResponse =
                                      currentPM.userResponse;

                                  if (!currentUserResponse.hasAnyInput()) {
                                    return;
                                  }

                                  final prevStatus = evaluationResults[idx];
                                  EvaluationStatus newStatus;

                                  if (isCorrect) {
                                    newStatus =
                                        (prevStatus ==
                                                EvaluationStatus.unSolved)
                                            ? EvaluationStatus.correct
                                            : EvaluationStatus.checked;
                                  } else {
                                    newStatus = EvaluationStatus.wrong;
                                  }

                                  evaluationResults[idx] = newStatus;


                                  // 👉 후처리: 애니메이션, 전송 등
                                  handleAfterEvaluation(idx, newStatus);

                                  if (!widget.isTeachingMode) {
                                    currentPM.sendResultOnceIfNeeded(_bmEncode);
                                  }
                                },
                                stateModel: _PSM.get(idx),
                              ),
                            ],
                          ),
                          Spacer(flex: 6),
                          Container(
                            margin: EdgeInsets.only(
                              bottom: MathUIConstant.hSize * 0.2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent, // 배경색 (필요에 따라 변경 가능)
                              border: Border.all(
                                color: MathUIConstant.boundaryPurple,
                                width: 3, // 테두리 두께
                              ),
                              borderRadius: BorderRadius.circular(16), // 둥근 모서리
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: MathUIConstant.wSize * 0.1),
                                    if (idx == evaluationResults.length - 1) BasaMSwitchButton(
                                      psm: _PSM.get(idx),
                                      onNextProblem: () {
                                        _getNextProblem();
                                      },
                                      autoMode: _autoMode,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back),
                                      onPressed: _decrementCounter,
                                      iconSize: MathUIConstant.helperIconSize,
                                      color: const Color(0xFF999797),
                                    ),
                                    SizedBox(width: MathUIConstant.wSize * 0.3),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward),
                                      onPressed: _incrementCounter,
                                      iconSize: MathUIConstant.helperIconSize,
                                      color: const Color(0xFF999797),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
            ),
            // 🎉 정답 애니메이션
            if (_autoMode && evaluationResults.isNotEmpty && idx < evaluationResults.length)
              ValueListenableBuilder<String?>(
                valueListenable: FeedbackAnimatorService().currentAsset,
                builder: (context, asset, child) {
                  if (asset == null)
                    return const SizedBox.shrink(); // 애니메이션 안띄움
                  return FeedbackLottieWidget(asset: asset); // 애니메이션 실행
                },
              ),
            if (showSubmitPopup && !_autoMode)
              Positioned.fill(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (mounted) {
                          setState(() => showSubmitPopup = false);
                        }
                      },
                      child: Container(color: Colors.black54),
                    ),
                    Center(
                      child: FadeTransition(
                        opacity: submitAnimation,
                        child: ScaleTransition(
                          scale: submitAnimation,
                          child: Material(
                            type: MaterialType.transparency,
                            child: SuccessfulPopup(
                              scaleAnimation: const AlwaysStoppedAnimation(1.0),
                              isCorrect: submitPopupIsCorrect,
                              customMessage: submitPopupIsCorrect
                                  ? "🎉 정답이에요!"
                                  : "틀렸어요...",
                              onClose: () async {
                                if (mounted) {
                                  setState(() => showSubmitPopup = false);
                                  if (submitPopupIsCorrect) _getNextProblem();
                                }
                              },
                              closePopup: () async{
                                if (mounted) {
                                  setState(() => showSubmitPopup = false);
                                  //if (submitPopupIsCorrect) _getNextProblem();
                                }
                              }
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

          ],
        ),
      ),
    );
  }
  Widget _buildStatusImage(EvaluationStatus status) {
    String? assetPath;

    switch (status) {
      case EvaluationStatus.correct:
        assetPath = 'assets/images/basa_math/bunny_correct.webp'; // ✅ 정답 마크
        break;
      case EvaluationStatus.checked:
        assetPath = 'assets/images/basa_math/bunny_check.webp'; // ✅ 정답 마크
        break;
      case EvaluationStatus.wrong:
        assetPath = 'assets/images/basa_math/bunny_wrong.webp'; // ✅ 정답 마크
        break;
      case EvaluationStatus.unSolved:
      default:
        return const SizedBox.shrink(); // 아무것도 표시하지 않음
    }

    return Image.asset(
      assetPath,
      key: ValueKey<String>(assetPath), // AnimatedSwitcher 식별을 위한 key
      width: 200,
      fit: BoxFit.contain,
    );
  }
  void handleAfterEvaluation(int idx, EvaluationStatus status) {
    // 🎯 기존 애니메이션 연출
    final asset = getAnimationAsset(status);
    if (asset.isNotEmpty) {
      FeedbackAnimatorService().setAnimatorStatus(asset);
    }

    // ✅ 추가: 팝업 띄우기
    setState(() {
      if (!_autoMode) showSubmitPopup = true;
      submitPopupIsCorrect = (status == EvaluationStatus.correct || status == EvaluationStatus.checked);
    });
    submitController.forward(from: 0);
  }

}
