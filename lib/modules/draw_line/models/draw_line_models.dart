import 'package:flutter/material.dart';

class DrawLineDot {
  final String id;
  final String key;
  Offset position;

  DrawLineDot({required this.id, required this.key, required this.position});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawLineDot &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          key == other.key &&
          position == other.position;

  @override
  int get hashCode => id.hashCode ^ key.hashCode ^ position.hashCode;
}

class DrawLineConnection {
  final DrawLineDot dot1;
  final DrawLineDot dot2;
  final bool isDashed;

  DrawLineConnection({
    required this.dot1,
    required this.dot2,
    this.isDashed = false,
  });

  bool involves(DrawLineDot dot) {
    return dot1.id == dot.id || dot2.id == dot.id;
  }
}
