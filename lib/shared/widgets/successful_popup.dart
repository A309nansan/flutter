import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessfulPopup extends StatefulWidget {
  final Animation<double> scaleAnimation;
  final bool? isCorrect;
  final String? image;
  final String? customMessage;
  final bool? isEnd;
  final Function()? closePopup;
  final Future<void> Function()? onClose;
  final Future<void> Function()? end;

  const SuccessfulPopup({
    super.key,
    required this.scaleAnimation,
    this.isCorrect,
    this.image,
    this.customMessage,
    this.isEnd,
    this.closePopup,
    this.onClose,
    this.end,
  });

  @override
  State<SuccessfulPopup> createState() => _SuccessfulPopupState();
}

class _SuccessfulPopupState extends State<SuccessfulPopup> {
  late final String rabbitAsset;
  late final String resultRabbitAsset;
  bool isLoading = false;
  bool showResultCarousel = false;
  final result = {
    "imageUrl": 'https://example.com/image.png',
    "correct": 1,
    "wrong": 3,
  };

  @override
  void initState() {
    super.initState();
    final index = Random().nextInt(4) + 1;
    final index2 = Random().nextInt(3) + 1;
    rabbitAsset = widget.isCorrect == true
        ? 'assets/images/successfull_rabbit_$index.png'
        : 'assets/images/wrong_rabbit_$index.png';
    resultRabbitAsset = "assets/images/image3d/Bunny3D_$index2.webp";
  }

  Future<void> _handleSubmit() async {
    setState(() => isLoading = true);
    try {
      if (widget.closePopup != null) {
        widget.closePopup!();
      } else if (widget.onClose != null) {
        await widget.onClose!();
      }
    } catch (e, stack) {
      print(stack);
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCorrect = widget.isCorrect ?? false;
    final isEnd = widget.isEnd ?? false;

    return Center(
      child: ScaleTransition(
        scale: widget.scaleAnimation,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: isEnd ? screenHeight * 0.55 : screenHeight * 0.4,
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
                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(-1.0, 0.0), // 오른쪽에서 들어오기
                    end: Offset.zero,
                  ).animate(animation);
                  return ClipRect( // 모달 밖 overflow 방지
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ),
                  );
                },
                child: showResultCarousel
                ? Column(
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
                          "${result["correct"]} 개",
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
                          "${result["wrong"]} 개",
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
                          onPressed: isLoading ? null : _handleSubmit,
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
                            "확인",
                            style: TextStyle(
                              fontSize: screenWidth * 0.022,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (widget.end != null) {
                              widget.end!();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFAE1),
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.06,
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
                    : Column(
                  key: const ValueKey('original'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      rabbitAsset,
                      height: isEnd ? screenHeight * 0.3 : screenHeight * 0.22,
                      width: screenWidth * 0.5,
                      scale: isCorrect ? 2 : .6,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.customMessage ?? '',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    if (isCorrect)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFFAE1),
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.08,
                                  vertical: screenHeight * 0.01),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              "확인",
                              style: TextStyle(
                                fontSize: screenWidth * 0.022,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (widget.onClose != null) {
                                widget.onClose!();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFFAE1),
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.06,
                                  vertical: screenHeight * 0.01),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              isEnd ? "학습종료" : "다음문제",
                              style: TextStyle(
                                fontSize: screenWidth * 0.022,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (isEnd == true)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: isLoading ? null : _handleSubmit,
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
                                  "확인",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.022,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: () {
                                  if (widget.end != null) {
                                    widget.end!();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFFAE1),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.06,
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
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                showResultCarousel = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFFAE1),
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.17,
                                  vertical: screenHeight * 0.01),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              "결과 보기",
                              style: TextStyle(
                                fontSize: screenWidth * 0.022,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      ElevatedButton(
                        onPressed: isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFAE1),
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.07,
                              vertical: screenHeight * 0.01),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          "다시풀기",
                          style: TextStyle(
                            fontSize: screenWidth * 0.022,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (isCorrect)
              IgnorePointer(
                child: SizedBox(
                  height: screenHeight * 0.5,
                  child: Lottie.asset(
                    'assets/lottie/confetti.json',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
