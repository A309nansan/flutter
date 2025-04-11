import 'package:flutter/material.dart';

class ClickableAnimalCard extends StatelessWidget {
  const ClickableAnimalCard({
    super.key,
    required this.animalName,
    required this.isSelected,
    required this.onTap,
  });

  final String animalName;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: 75,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.lightBlue,
            width: 2,
          ),
          color: isSelected ? Colors.amber.shade100 : Colors.grey.shade300,
        ),
        child: Image.network(animalName),
      ),
    );
  }
}
