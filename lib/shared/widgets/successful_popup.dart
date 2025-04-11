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

  const SuccessfulPopup({
    super.key,
    required this.scaleAnimation,
    this.isCorrect,
    this.image,
    this.customMessage,
    this.isEnd,
    this.closePopup,
    this.onClose,
  });

  @override
  State<SuccessfulPopup> createState() => _SuccessfulPopupState();
}

class _SuccessfulPopupState extends State<SuccessfulPopup> {
  late final String rabbitAsset;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final index = Random().nextInt(4) + 1;
    rabbitAsset = widget.isCorrect == true
        ? 'assets/images/successfull_rabbit_$index.png'
        : 'assets/images/wrong_rabbit_$index.png';
  }

  Future<void> _handleSubmit() async {
    setState(() => isLoading = true);

    try {
      // 우선순위: closePopup > onClose
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
              height: screenHeight * 0.4,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    rabbitAsset,
                    height: screenHeight * 0.22,
                    width: screenWidth * 0.5,
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
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08, vertical: screenHeight * 0.01),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: screenHeight * 0.01),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  else
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFAE1),
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07, vertical: screenHeight * 0.01),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
