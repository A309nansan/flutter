import 'package:flutter/material.dart';

class AnimalCard extends StatelessWidget {
  const AnimalCard({super.key, required this.animalName, required this.width, required this.height});

  final double width;
  final double height;
  final String animalName;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: width * 0.093,
      height: height * 0.075,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.lightBlue, width: 2),
      ),
      child: Image.asset(animalName),
    );
  }
}