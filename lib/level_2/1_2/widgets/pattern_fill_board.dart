import 'package:flutter/material.dart';
import '../models/pattern_type.dart';

class PatternFillBoard extends StatefulWidget {
  final PatternType pattern;
  final int filledCount;
  final ValueChanged<int> onChanged;

  const PatternFillBoard({
    super.key,
    required this.pattern,
    required this.filledCount,
    required this.onChanged,
  });

  @override
  State<PatternFillBoard> createState() => _PatternFillBoardState();
}

class _PatternFillBoardState extends State<PatternFillBoard> {
  final List<PatternType?> _filledPatterns = List.generate(20, (_) => null);

  @override
  void initState() {
    super.initState();
    _syncFilled(widget.filledCount);
  }

  @override
  void didUpdateWidget(covariant PatternFillBoard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.filledCount != widget.filledCount) {
      for (int i = 0; i < _filledPatterns.length; i++) {
        _filledPatterns[i] = i < widget.filledCount ? _filledPatterns[i] : null;
      }
    }
  }

  void _syncFilled(int count) {
    for (int i = 0; i < 20; i++) {
      _filledPatterns[i] = i < count ? widget.pattern : null;
    }
  }

  void _updateCount(int index) {
    for (int i = 0; i <= index; i++) {
      // 기존에 이미 채워진 칸은 그대로 유지
      if (_filledPatterns[i] == null) {
        _filledPatterns[i] = widget.pattern;
      }
    }
    for (int i = index + 1; i < _filledPatterns.length; i++) {
      _filledPatterns[i] = null;
    }

    widget.onChanged(index + 1);
    setState(() {});
  }

  void _handleDrag(Offset position, BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final local = box.globalToLocal(position);
    final width = box.size.width;
    final cellSize = width / 5;

    for (int i = 0; i < 20; i++) {
      final row = i ~/ 5;
      final col = i % 5;
      final rect = Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize);
      if (rect.contains(local)) {
        _updateCount(i);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _handleDrag(details.globalPosition, context),
      onPanUpdate: (details) => _handleDrag(details.globalPosition, context),
      child: GridView.count(
        crossAxisCount: 5,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: List.generate(20, (i) {
          return GestureDetector(
            onTap: () => _updateCount(i),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(10),
                color: i < 10 ? Color.fromARGB(60, 249, 241, 196) : Colors.white,
              ),
              child: Center(
                child: _filledPatterns[i] != null
                    ? _buildIcon(_filledPatterns[i]!)
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildIcon(PatternType type) {
    switch (type) {
      case PatternType.heart:
        return const Icon(Icons.favorite, color: Colors.red, size: 40);
      case PatternType.star:
        return const Icon(Icons.star, color: Colors.orange,  size: 40);
      case PatternType.circle:
        return const Icon(Icons.circle, color: Colors.black, size: 40);
    }
  }
}