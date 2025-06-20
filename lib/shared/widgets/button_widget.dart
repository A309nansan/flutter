import 'dart:async';
import 'package:flutter/material.dart';

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
          padding: EdgeInsets.zero,
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
