import 'dart:async';
import 'package:flutter/material.dart';

/// 재사용 버튼 위젯
///
/// 기본 사용 예시:
/// ```dart
/// ButtonWidget(
///   height: 50,                          // 필수
///   width: 200,                          // 필수
///   buttonText: '제출하기',             // 필수
///   fontSize: 16,                        // 필수
///   backgroundColor: Colors.red,        // (선택) 버튼 배경색
///   textColor: Color(0xFFE1E1FF),       // (선택) 텍스트 색상
///   borderRadius: 30.0,                 // (선택) 버튼 둥글기
///
///   onPressed: () async {               // (선택) 클릭 시 비동기 처리
///     await Future.delayed(Duration(seconds: 2));
///     print('제출 완료!');
///   },
///
///   또는
///
///   onPressed: () {                     // (선택) 클릭 시 실행할 동기 함수
///     print('제출 완료!');
///   },
/// ),
/// ```
class ButtonWidget extends StatefulWidget {
  final double height;
  final double width;
  final String buttonText;
  final double fontSize;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final FutureOr<void> Function()? onPressed;

  const ButtonWidget({
    super.key,
    required this.height,
    required this.width,
    required this.buttonText,
    required this.fontSize,
    this.backgroundColor,
    this.textColor = Colors.black,
    this.borderRadius,
    this.onPressed,
  });

  @override
  State<ButtonWidget> createState() => _AsyncButtonWidgetState();
}

class _AsyncButtonWidgetState extends State<ButtonWidget> {
  bool isLoading = false;

  Future<void> _handlePress() async {
    if (isLoading || widget.onPressed == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final result = widget.onPressed!();
      if (result is Future) {
        await result;
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handlePress,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor ?? const Color(0xFFFFFAE1),
          foregroundColor: Colors.black,
          disabledBackgroundColor:
              widget.backgroundColor ?? const Color(0xFFFFFAE1),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 30.0),
          ),
          elevation: 3,
        ),
        child:
            isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  widget.buttonText,
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }
}
