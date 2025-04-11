import 'package:flutter/material.dart';
import '../models/pattern_type.dart';

class PatternSelector extends StatelessWidget {
  final PatternType selected;
  final void Function(PatternType) onSelected;

  const PatternSelector({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3),
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: PatternType.values.map((type) {
          return GestureDetector(
            onTap: () => onSelected(type),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected == type ? Color.fromARGB(255, 249, 241, 196) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.3 * 255).toInt()),
                    blurRadius: 3,
                    offset: const Offset(1, 2),
                  )
                ]
              ),
              child: _buildIcon(type),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIcon(PatternType type) {
    switch (type) {
      case PatternType.circle:
        return const Icon(Icons.circle, size: 30);
      case PatternType.heart:
        return const Icon(Icons.favorite, size: 30, color: Colors.red);
      case PatternType.star:
        return const Icon(Icons.star, size: 30, color: Colors.orange);
    }
  }
}
