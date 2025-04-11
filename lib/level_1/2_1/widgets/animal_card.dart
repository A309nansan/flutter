import 'package:flutter/material.dart';

class AnimalCard extends StatelessWidget {
  const AnimalCard({super.key, required this.animalName});

  final String animalName;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 65,
      height: 75,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.lightBlue, width: 2),
      ),
      child: Image.network(animalName),
    );
  }
}
