import 'package:flutter/material.dart';

class ClickableAnimalCard extends StatelessWidget {
  const ClickableAnimalCard({
    super.key,
    required this.width,
    required this.height,
    required this.animalName,
    required this.isSelected,
    required this.onTap,
  });

  final double width;
  final double height;
  final int animalName;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: width * 0.12,
        height: height * 0.08,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.lightBlue,
            width: 2,
          ),
          color: isSelected ? Colors.amber.shade100 : Colors.grey.shade300,
        ),
        child: Image.asset('assets/images/number/zodiac/${animalName.toString()}.png'),
      ),
    );
  }
}
