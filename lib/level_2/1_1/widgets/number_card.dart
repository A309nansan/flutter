import 'package:flutter/material.dart';

class NumberCard extends StatelessWidget {
  final Map<String, dynamic> problem;
  final bool isSelected;
  final bool isCorrect;
  final AnimationController controller;
  final VoidCallback onPressed;

  const NumberCard({
    super.key,
    required this.problem,
    required this.isSelected,
    required this.isCorrect,
    required this.controller,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final images = problem["images"] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color.fromARGB(255, 249, 241, 196),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side:
                isSelected
                    ? const BorderSide(color: Colors.blueAccent, width: 4.5)
                    : const BorderSide(color: Colors.transparent, width: 1),
          ),
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          elevation: 3,
        ),
        onPressed: onPressed,
        child:
            images.length >= 2
                ? SizedBox(
                  height: screenHeight * 0.15,
                  width: screenWidth * 0.22,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        width: screenWidth * 0.15,
                        height: screenHeight * 0.07,
                        child: Image.network(images[0], fit: BoxFit.contain),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        width: screenWidth * 0.1,
                        height: screenHeight * 0.07,
                        child: Image.network(images[1], fit: BoxFit.contain),
                      ),
                    ],
                  ),
                )
                : Container(
                  height: screenHeight * 0.15,
                  width: screenWidth * 0.22,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child:
                      images.isNotEmpty
                          ? Image.network(images[0], fit: BoxFit.contain)
                          : const Icon(Icons.broken_image),
                ),
      ),
    );
  }
}
