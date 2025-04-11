import 'package:flutter/material.dart';

class CompareNumberCard extends StatelessWidget {
  final int number;
  final bool isSelected;
  final bool isWrong;
  final bool isCorrect;
  final AnimationController controller;
  final VoidCallback onPressed;

  const CompareNumberCard({
    super.key,
    required this.number,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.controller,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        SizedBox(
          height: screenHeight * 0.1,
          width: screenHeight * 0.1,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color.fromARGB(255, 249, 241, 196),
              shape:
                  isSelected
                      ? RoundedRectangleBorder(
                        side: BorderSide(width: 4.5, color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(10),
                      )
                      : RoundedRectangleBorder(
                        side: BorderSide(width: 0, color: Colors.transparent),
                        borderRadius: BorderRadius.circular(10),
                      ),
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              elevation: 3,
            ),
            onPressed: onPressed,
            child: Container(
              child: Text(
                "$number",
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
