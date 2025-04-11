import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isDisabled;

  const Button({
    super.key,
    required this.onPressed,
    required this.text,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.045,
      width: screenWidth * 0.2,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFFAE1),
          foregroundColor: const Color.fromARGB(255, 249, 241, 196),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          elevation: 3,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: screenWidth * 0.023,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
