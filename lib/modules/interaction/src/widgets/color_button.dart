import 'package:flutter/material.dart';

class ColorButton extends StatelessWidget {
  final Color color;
  final Color? outlineColor;
  final bool isActive;
  final VoidCallback onPressed;
  final Icon? child;

  const ColorButton({
    required this.color,
    required this.isActive,
    required this.onPressed,
    this.outlineColor,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: kThemeAnimationDuration,
      decoration: ShapeDecoration(
        shape: CircleBorder(
          side: BorderSide(
            color: isActive ? (outlineColor ?? color) : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: IconButton(
        style: IconButton.styleFrom(
          backgroundColor: color,
          shape: const CircleBorder(),
        ),
        onPressed: onPressed,
        icon: child ?? const SizedBox.shrink(),
      ),
    );
  }
}