// import 'package:flutter/material.dart';
// import '../../../../shared/widgets/button_widget.dart';
// import '../models/m_problem_state_model.dart';
// import '../utils/math_ui_constant.dart';
//
// class BasaMSwitchButton extends StatefulWidget {
//   final MProblemStateModel psm;
//   final VoidCallback onNextProblem;
//   final bool autoMode;
//
//   const BasaMSwitchButton({
//     super.key,
//     required this.psm,
//     required this.onNextProblem,
//     required this.autoMode,
//   });
//
//   @override
//   State<BasaMSwitchButton> createState() => _BasaMSwitchButtonState();
// }
//
// class _BasaMSwitchButtonState extends State<BasaMSwitchButton> {
//   late final MProblemStateModel stateModel;
//
//   @override
//   void initState() {
//     super.initState();
//     stateModel = widget.psm;
//     stateModel.addListener(_onModelChanged);
//     print("AUTOMODE: $widget.autoMode");
//   }
//
//   @override
//   void dispose() {
//     stateModel.removeListener(_onModelChanged);
//     super.dispose();
//   }
//
//   void _onModelChanged() {
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print("📝[SwitchButtonState]📝");
//     print(stateModel.toString());
//
//     Widget button;
//     if (!stateModel.hasAnswer) {
//       button = Row(
//         children: [
//           ButtonWidget(
//             key: const ValueKey("erase"),
//             onPressed: () {
//               print("📌BUTTON CLICKED: 지우기📌");
//               stateModel.triggerErase();
//             },
//
//             buttonText: "지우기",
//
//             fontSize: MathUIConstant.buttonFontSize,
//             height: MathUIConstant.buttonHeight,
//             width: MathUIConstant.buttonWidth,
//           ),
//           const SizedBox(width: 30),
//           ButtonWidget(
//             key: const ValueKey("run"),
//             onPressed: () async {
//               print("📌BUTTON CLICKED: 채점하기📌");
//               await stateModel.triggerRecognitionAndColor();
//               stateModel.setWritingEnabled(false);
//
//               if (widget.autoMode && stateModel.isAnswerCorrect) {
//                 Future.delayed(const Duration(milliseconds: 600), () {
//                   widget.onNextProblem();
//                 });
//               }
//             },
//
//             buttonText: "채점하기",
//
//             fontSize: MathUIConstant.buttonFontSize,
//             height: MathUIConstant.buttonHeight,
//             width: MathUIConstant.buttonWidth,
//           ),
//         ],
//       );
//     } else if (stateModel.isAnswerCorrect == true) {
//       button = ButtonWidget(
//         key: const ValueKey("next"),
//         onPressed: () {
//           print("📌BUTTON CLICKED: 다음으로📌");
//           widget.onNextProblem();
//         },
//         buttonText: "다음으로",
//         fontSize: MathUIConstant.buttonFontSize,
//         height: MathUIConstant.buttonHeight,
//         width: MathUIConstant.buttonWidth,
//       );
//     } else {
//       button = Row(
//         key: const ValueKey("wrong"),
//         mainAxisAlignment: MainAxisAlignment.center,
//
//         children: [
//           //const SizedBox(width: 30),
//           Visibility(
//             visible: stateModel.isShowingUserInput,
//             maintainSize: true,
//             maintainAnimation: true,
//             maintainState: true,
//             replacement: SizedBox(
//               height: MathUIConstant.buttonHeight,
//               width: MathUIConstant.buttonWidth,
//             ),
//             child: ButtonWidget(
//               onPressed:
//                   stateModel.isShowingUserInput
//                       ? () {
//                         print("📌BUTTON CLICKED: 다시풀기📌");
//                         stateModel.setShowingUserInput(true);
//                         stateModel.setWritingEnabled(false);
//                         stateModel.setHasAnswer(false);
//                         stateModel.triggerPurgeColor();
//                       }
//                       : null,
//               // 🔒 비활성화
//               buttonText: "다시풀기",
//               fontSize: MathUIConstant.buttonFontSize,
//               height: MathUIConstant.buttonHeight,
//               width: MathUIConstant.buttonWidth,
//               backgroundColor:
//                   stateModel.isShowingUserInput
//                       ? MathUIConstant.activeButtonColor
//                       : Colors.transparent,
//               // 👻 투명 처리
//               textColor:
//                   stateModel.isShowingUserInput
//                       ? Colors.black
//                       : Colors.transparent, // 👻 텍스트도 투명 처리
//             ),
//           ),
//           const SizedBox(width: 30),
//           ButtonWidget(
//             onPressed: () {
//               print("📌BUTTON CLICKED: 정답보기/다시풀기📌");
//               if (!stateModel.isShowingUserInput) {
//                 stateModel.setShowingUserInput(true);
//                 stateModel.setWritingEnabled(false);
//                 stateModel.setHasAnswer(false);
//               } else {
//                 stateModel.toggleShowingUserInput();
//                 stateModel.toggleWritingEnabled();
//               }
//             },
//             buttonText: stateModel.isShowingUserInput ? "정답보기" : "다시풀기",
//             fontSize: MathUIConstant.buttonFontSize,
//             height: MathUIConstant.buttonHeight,
//             width: MathUIConstant.buttonWidth,
//           ),
//           const SizedBox(width: 30),
//           Visibility(
//             visible: !stateModel.isShowingUserInput,
//             maintainSize: true,
//             maintainAnimation: true,
//             maintainState: true,
//             replacement: SizedBox(
//               height: MathUIConstant.buttonHeight,
//               width: MathUIConstant.buttonWidth,
//             ),
//             child: ButtonWidget(
//               onPressed: () {
//                 print("📌BUTTON CLICKED: 넘어가기📌");
//                 stateModel.isShowingUserInput ? null : widget.onNextProblem();
//               },
//               buttonText: "넘어가기",
//               textColor:
//                   stateModel.isShowingUserInput ? Colors.white : Colors.black,
//               backgroundColor:
//                   stateModel.isShowingUserInput
//                       ? Colors.grey[300]
//                       : MathUIConstant.activeButtonColor,
//               fontSize: MathUIConstant.buttonFontSize,
//               height: MathUIConstant.buttonHeight,
//               width: MathUIConstant.buttonWidth,
//             ),
//           ),
//         ],
//       );
//     }
//
//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 500),
//       switchInCurve: Curves.easeIn,
//       switchOutCurve: Curves.easeOut,
//       transitionBuilder: (Widget child, Animation<double> animation) {
//         return FadeTransition(
//           opacity: animation,
//           child: SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(0.0, 0.2),
//               end: Offset.zero,
//             ).animate(animation),
//             child: child,
//           ),
//         );
//       },
//       child: button,
//     );
//   }
// }
