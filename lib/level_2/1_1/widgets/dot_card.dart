import 'package:flutter/material.dart';
import '../models/dot.dart';

class DotCard extends StatelessWidget {
  final Dot dot;
  final double height, width;
  final bool isConnected;

  const DotCard({
    super.key,
    required this.dot,
    required this.height,
    required this.width,
    this.isConnected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: Colors.black12,
          width: 1,
        ),
      ),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Image.network(
            dot.img,
            scale: 0.6,
          ),
        ),
      ),
    );
  }
}
