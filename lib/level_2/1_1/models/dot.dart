import 'package:flutter/material.dart';

class Dot {
  final String id; // 고유 식별자
  final Offset position;
  final int value;
  final String img;

  Dot({
    required this.id,
    required this.position,
    required this.value,
    required this.img,
  });

  @override
  bool operator ==(Object other) {
    return other is Dot && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}