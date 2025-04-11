import 'package:flutter/material.dart';
import '../../../../shared/widgets/button_widget.dart';
import '../models/m_problem_state_model.dart';
import '../utils/math_ui_constant.dart';

class BasaMSwitchButton extends StatefulWidget {
  final MProblemStateModel psm;
  final VoidCallback onNextProblem;
  final bool autoMode;

  const BasaMSwitchButton({
    super.key,
    required this.psm,
    required this.onNextProblem,
    required this.autoMode,
  });

  @override
  State<BasaMSwitchButton> createState() => _BasaMSwitchButtonState();
}

class _BasaMSwitchButtonState extends State<BasaMSwitchButton> {
  late final MProblemStateModel stateModel;
  @override
  void initState() {
    super.initState();
    stateModel = widget.psm;
    stateModel.addListener(_onModelChanged);
  }

  @override
  void dispose() {
    stateModel.removeListener(_onModelChanged);
    super.dispose();
  }

  void _onModelChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget button;


    if (!stateModel.hasAnswer) {
      button = Row(
        children: [
          ButtonWidget(
            key: const ValueKey("erase"),
            onPressed: () {
              stateModel.triggerErase();
            },

            buttonText: "전부 지우기",

            fontSize: MathUIConstant.buttonFontSize,
            height: MathUIConstant.buttonHeight,
            width: MathUIConstant.buttonWidth,
            borderRadius: 10,
          ),
          const SizedBox(width: 30),
          ButtonWidget(
            key: const ValueKey("run"),
            onPressed: () async {
              await stateModel.triggerRecognitionAndColor();
              stateModel.setWritingEnabled(false);
              if (widget.autoMode && stateModel.isAnswerCorrect) {
                Future.delayed(const Duration(milliseconds: 600), () {
                  widget.onNextProblem();
                });
              }
            },
            buttonText: "채점하기",
            fontSize: MathUIConstant.buttonFontSize,
            height: MathUIConstant.buttonHeight,
            width: MathUIConstant.buttonWidth,
            borderRadius: 10,
          ),
        ],
      );
    } else if (stateModel.isAnswerCorrect == true) {
      button = Row(
        children: [
          SizedBox(
              height: MathUIConstant.buttonHeight,
              width: MathUIConstant.buttonWidth,
            ),
          const SizedBox(width: 30),
          ButtonWidget(
            key: const ValueKey("next"),
            onPressed: () {
              widget.onNextProblem();
            },
            buttonText: "다음으로",
            fontSize: MathUIConstant.buttonFontSize,
            height: MathUIConstant.buttonHeight,
            width: MathUIConstant.buttonWidth,
            borderRadius: 10,
          ),
        ],
      );
    } else {
      if (stateModel.isShowingUserInput) {
        button = Row(
          key: const ValueKey("wrong"),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonWidget(
              onPressed: () {
                stateModel.setShowingUserInput(true);
                stateModel.setWritingEnabled(false);
                stateModel.setHasAnswer(false);
                stateModel.triggerPurgeColor();
              },
              buttonText: "다시풀기",
              fontSize: MathUIConstant.buttonFontSize,
              height: MathUIConstant.buttonHeight,
              width: MathUIConstant.buttonWidth,
              backgroundColor: MathUIConstant.activeButtonColor,
              textColor: Colors.black,
              borderRadius: 10,
            ),
            const SizedBox(width: 30),
            ButtonWidget(
              onPressed: () {
                stateModel.toggleShowingUserInput();
                stateModel.toggleWritingEnabled();
              },
              buttonText: "정답보기",
              fontSize: MathUIConstant.buttonFontSize,
              height: MathUIConstant.buttonHeight,
              width: MathUIConstant.buttonWidth,
              borderRadius: 10,
            ),
          ],
        );
      } else {
        button = Row(
          key: const ValueKey("userInfoViewer"),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonWidget(
              onPressed: () {
                stateModel.setShowingUserInput(true);
                stateModel.setWritingEnabled(false);
                stateModel.setHasAnswer(false);
              },
              buttonText: "다시풀기",
              fontSize: MathUIConstant.buttonFontSize,
              height: MathUIConstant.buttonHeight,
              width: MathUIConstant.buttonWidth,
              borderRadius: 10,
            ),
            const SizedBox(width: 30),
            ButtonWidget(
              onPressed: () {
                widget.onNextProblem();
              },
              buttonText: "넘어가기",
              textColor: Colors.black,
              backgroundColor: MathUIConstant.activeButtonColor,
              fontSize: MathUIConstant.buttonFontSize,
              height: MathUIConstant.buttonHeight,
              width: MathUIConstant.buttonWidth,
              borderRadius: 10,
            ),
          ],
        );
      }
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: button,
    );
  }
}
