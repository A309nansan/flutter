import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nansan_flutter/modules/math/src/utils/math_ui_constant.dart';
import 'package:nansan_flutter/shared/digit_recognition/widgets/handwriting_recognition_zone.dart';

class CaterpillarWidget extends StatefulWidget {
  final String rowId;
  final List<dynamic> data;
  final List<dynamic> text;
  final Map<String, GlobalKey<HandwritingRecognitionZoneState>> zoneKeys;

  const CaterpillarWidget({
    super.key,
    required this.rowId,
    required this.data,
    required this.text,
    required this.zoneKeys,
  });

  @override
  State<CaterpillarWidget> createState() => _CaterpillarWidgetState();
}

class _CaterpillarWidgetState extends State<CaterpillarWidget> {
  late List<double> topOffsets;

  @override
  void initState() {
    super.initState();
    final random = Random();
    final size = MathUIConstant.screenWidth * 0.14;
    topOffsets = List.generate(widget.data.length + 1, (_) {
      final verticalOffset = random.nextDouble() * (size * 0.18);
      final moveUp = random.nextBool();
      return moveUp ? size * 0.3 - verticalOffset : size * 0.3 + verticalOffset;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double size = MathUIConstant.screenWidth * 0.14;
    final double totalWidth = size * 0.9 * (widget.data.length - 1) + size + size * 0.9;
    final double totalHeight = size * 2;

    return SizedBox(
      height: totalHeight,
      width: double.infinity,
      child: Center(
        child: SizedBox(
          width: totalWidth,
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Head
              Positioned(
                top: topOffsets[0] + 24,
                child: Container(
                  width: size,
                  height: size,
                  decoration: const BoxDecoration(
                    color: Colors.lightGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: -size * 0.2,
                        left: size * 0.3,
                        child: Transform.rotate(
                          angle: -pi / 6,
                          child: Container(
                            width: 2,
                            height: size * 0.4,
                            color: Colors.lightGreen,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -size * 0.3,
                        left: size * 0.6,
                        child: Transform.rotate(
                          angle: -pi / 12,
                          child: Container(
                            width: 2,
                            height: size * 0.5,
                            color: Colors.lightGreen,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -size * 0.3,
                        left: size * 0.1,
                        child: Container(
                          width: size * 0.18,
                          height: size * 0.18,
                          decoration: const BoxDecoration(
                            color: Colors.lightGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -size * 0.4,
                        left: size * 0.45,
                        child: Container(
                          width: size * 0.18,
                          height: size * 0.18,
                          decoration: const BoxDecoration(
                            color: Colors.lightGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        top: size * 0.16,
                        left: size * 0.28,
                        child: SizedBox(
                          width: size * 0.15,
                          height: size * 0.22,
                          child: Center(
                            child: Transform.scale(
                              scaleY: 1.8,
                              child: Container(
                                width: size * 0.08,
                                height: size * 0.08,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: size * 0.17,
                        left: size * 0.48,
                        child: SizedBox(
                          width: size * 0.15,
                          height: size * 0.22,
                          child: Center(
                            child: Transform.scale(
                              scaleY: 1.8,
                              child: Container(
                                width: size * 0.08,
                                height: size * 0.08,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: size * 0.5,
                        left: size * 0.2,
                        child: SizedBox(
                          width: size * 0.5,
                          height: size * 0.3,
                          child: CustomPaint(
                            painter: SmilePainter(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Body Segments
              ...List.generate(widget.data.length, (index) {
                final number = widget.data[index];
                final word = widget.text[index];
                final keyStr = '${widget.rowId}-$index';
                widget.zoneKeys.putIfAbsent(
                  keyStr,
                      () => GlobalKey<HandwritingRecognitionZoneState>(),
                );
                final zoneKey = widget.zoneKeys[keyStr]!;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  zoneKey.currentState?.updateBackgroundColor(Colors.transparent);
                });

                final double leftOffset = size * 0.9 * index + size * 0.9;
                final double topOffset = topOffsets[index + 1];

                return Positioned(
                  left: leftOffset,
                  top: topOffset,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        word.toString(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      ClipOval(
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.lightGreen, width: 18),
                          ),
                          child: number == 0
                              ? HandwritingRecognitionZone(
                            key: zoneKey,
                            width: size,
                            height: size,
                            borderColor: Colors.transparent,
                          )
                              : Center(
                            child: Text(
                              number.toString(),
                              style: const TextStyle(fontSize: 50),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class SmilePainter extends CustomPainter {
  final double strokeWidth;
  final Color color;

  SmilePainter({required this.strokeWidth, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, 0.0, pi, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
