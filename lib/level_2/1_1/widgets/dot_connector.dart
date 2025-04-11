import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../controller/level_2_1_1_think1_controller.dart';
import '../models/dot.dart';
import 'dot_card.dart';
import 'dot_painter.dart';

class DotConnector extends StatefulWidget {
  final LevelTwoOneOneThink1Controller controller;
  final VoidCallback? onCorrect;
  final VoidCallback? onWrong;
  final void Function(int index, bool matched)? onMatched;
  final VoidCallback? onAllCorrect;

  const DotConnector({
    super.key,
    required this.controller,
    this.onMatched,
    this.onCorrect,
    this.onWrong,
    this.onAllCorrect,
  });

  @override
  DotConnectorState createState() => DotConnectorState();
}

class DotConnectorState extends State<DotConnector> with TickerProviderStateMixin {
  Map<Dot, AnimationController> connectedControllers = {};
  late AnimationController wrongController;
  List<Dot> dots = [];
  List<List<Dot>> connections = [];
  Offset? currentDragPosition;
  Dot? startDot;

  @override
  void initState() {
    super.initState();
    wrongController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    for (var controller in connectedControllers.values) {
      controller.dispose();
    }
    wrongController.dispose();
    super.dispose();
  }

  void resetAll() {
    for (var controller in connectedControllers.values) {
      controller.dispose();
    }
    connectedControllers.clear();
    connections.clear();
    currentDragPosition = null;
    startDot = null;
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final problemData = widget.controller.problemLines;

    double cardWidth = MediaQuery.of(context).size.width * 0.25;
    double cardHeight = MediaQuery.of(context).size.height * 0.17;

    double leftX = MediaQuery.of(context).size.width * 0.01;
    double rightX = MediaQuery.of(context).size.width * 0.58;

    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: (details) => onPanEnd(details, problemData.length),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double gap = MediaQuery.of(context).size.height * 0.01;
          double topPadding = 0;
          double cardX = MediaQuery.of(context).size.width * 0.03;
          double cardY = MediaQuery.of(context).size.height * 0.065;
          dots.clear();

          return Stack(
            children: [
              CustomPaint(
                painter: DotPainter(
                  dots: dots,
                  connections: connections,
                  currentDragPosition: currentDragPosition,
                  startDot: startDot,
                ),
                child: Container(),
              ),
              ...List.generate(
                  problemData.length, (index) {
                double top = topPadding + index * (cardHeight + gap);
                double centerY = top + cardHeight / 2;

                Dot leftDot = Dot(
                  id: 'left_$index',
                  position: Offset(leftX + cardWidth * 1.14, centerY),
                  value: problemData[index].left,
                  img: problemData[index].leftImg,
                );
                Dot rightDot = Dot(
                  id: 'right_$index',
                  position: Offset(rightX * 0.95, centerY),
                  value: problemData[index].right,
                  img: problemData[index].rightImg,
                );

                dots.add(leftDot);
                dots.add(rightDot);

                return Stack(
                  children: [
                    Positioned(
                      left: leftX,
                      top: top,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          DotCard(
                            dot: leftDot,
                            width: cardWidth,
                            height: cardHeight,
                            isConnected: isDotConnected(leftDot),
                          ),
                          if (isDotConnected(leftDot) && connectedControllers[leftDot] != null)
                            SizedBox(
                              width: cardWidth * 0.9,
                              height: cardHeight * 0.9,
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.diagonal3Values(1.4, -2.0, 1.0),
                                child: Lottie.asset(
                                  "assets/lottie/correct.json",
                                  controller: connectedControllers[leftDot],
                                  repeat: false,
                                  fit: BoxFit.contain,
                                  onLoaded: (comp) {
                                    connectedControllers[leftDot]?.duration = comp.duration * 0.4;
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: rightX,
                      top: top,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          DotCard(
                            dot: rightDot,
                            width: cardWidth,
                            height: cardHeight,
                            isConnected: isDotConnected(rightDot),
                          ),
                          if (isDotConnected(rightDot) && connectedControllers[rightDot] != null)
                            SizedBox(
                              width: cardWidth * 0.9,
                              height: cardHeight * 0.9,
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.diagonal3Values(1.4, -2.0, 1.0),
                                child: Lottie.asset(
                                  "assets/lottie/correct.json",
                                  controller: connectedControllers[rightDot],
                                  repeat: false,
                                  fit: BoxFit.contain,
                                  onLoaded: (comp) {
                                    connectedControllers[rightDot]?.duration = comp.duration * 0.4;
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }

  bool isDotConnected(Dot dot) {
    for (var connection in connections) {
      if (connection.contains(dot)) {
        return true;
      }
    }
    return false;
  }

  Dot? getNearestDot(Offset pos, {double threshold = 50.0}) {
    for (var dot in dots) {
      if ((dot.position - pos).distance < threshold) {
        return dot;
      }
    }
    return null;
  }

  void onPanStart(DragStartDetails details) {
    final start = details.localPosition;
    final nearest = getNearestDot(start);
    // 이미 연결된 카드라면 드래그를 시작하지 않음
    if (nearest != null && !isDotConnected(nearest)) {
      startDot = nearest;
    } else {
      startDot = null;
    }
    setState(() {
      currentDragPosition = start;
    });
  }

  void onPanUpdate(DragUpdateDetails details) {
    setState(() {
      currentDragPosition = details.localPosition;
    });
  }

  void onPanEnd(DragEndDetails details, int totalCount) {
    if (startDot != null && currentDragPosition != null) {
      final endDot = getNearestDot(currentDragPosition!);
      if (endDot != null && endDot != startDot) {
        if (startDot!.value + endDot.value == 10) {
          connections.add([startDot!, endDot]);

          final leftController = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 800),
          );
          final rightController = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 800),
          );

          leftController.forward(from: 0);
          rightController.forward(from: 0);

          connectedControllers[startDot!] = leftController;
          connectedControllers[endDot] = rightController;

          final leftIndex = _extractIndexFromDot(startDot!);

          if (leftIndex != null) {
            widget.onMatched?.call(leftIndex, true); // 연결 결과 전달
          }

          widget.onCorrect?.call();
        } else {
          widget.onWrong?.call();
        }
      }
    }
    setState(() {
      startDot = null;
      currentDragPosition = null;
    });
  }

  int? _extractIndexFromDot(Dot dot) {
    final match = RegExp(r'left_(\d+)').firstMatch(dot.id);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

}