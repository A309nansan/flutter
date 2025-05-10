import 'dart:math';
import 'package:flutter/material.dart';

class EnResultPopup extends StatefulWidget {
  final Animation<double> scaleAnimation;
  final Future<Map<String, dynamic>>? result;
  final Future<void> Function()? end;

  const EnResultPopup({
    super.key,
    required this.scaleAnimation,
    this.result,
    this.end,
  });

  @override
  State<EnResultPopup> createState() => _EnResultPopupState();
}

class _EnResultPopupState extends State<EnResultPopup> {
  late final String resultRabbitAsset;
  bool isLoading = false;
  bool showResultCarousel = false;
  Map<String, dynamic>? result = {
    "correct": 0,
    "wrong": 0
  };

  @override
  void initState() {
    super.initState();
    final index = Random().nextInt(3) + 1;
    resultRabbitAsset = "assets/images/image3d/Bunny3D_$index.webp";
    _loadResult();
  }

  Future<void> _loadResult() async {
    final loaded = await widget.result;
    if(loaded != null){
      setState(() {
        result = loaded;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: ScaleTransition(
        scale: widget.scaleAnimation,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: screenHeight * 0.55,
              width: screenWidth * 0.6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 10,
                    offset: const Offset(3, 6),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (child, animation) {
                  final isResult = child.key == const ValueKey('result');

                  final offsetAnimation = Tween<Offset>(
                    begin: isResult ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation);

                  return ClipRect(
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  key: const ValueKey('result'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '문제 풀이 결과',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20), // 원하는 radius 값
                      child: Image.asset(
                        resultRabbitAsset,
                        width: screenWidth * 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/basa_math/thumbsup.png",
                          width: screenWidth * 0.07,
                          height: screenHeight * 0.07,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${result?["correct"]} 개",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.05),
                        Image.asset(
                          "assets/images/basa_math/thumbsdown.png",
                          width: screenWidth * 0.075,
                          height: screenHeight * 0.07,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${result?["wrong"]} 개",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (widget.end != null) {
                              widget.end!();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFAE1),
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.08,
                                vertical: screenHeight * 0.01),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10)),
                          ),
                          child: Text(
                            "학습종료",
                            style: TextStyle(
                              fontSize: screenWidth * 0.022,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
