import 'package:flutter/material.dart';

class ClickAndDragWidget extends StatefulWidget {
  final int filledCount;
  final ValueChanged<int> onChanged;

  const ClickAndDragWidget({
    super.key,
    required this.filledCount,
    required this.onChanged,
  });

  @override
  State<StatefulWidget> createState() => ClickAndDragWidgetState();
}

class ClickAndDragWidgetState extends State<ClickAndDragWidget> {
  late int _count;
  static const int totalItems = 10;

  late List<bool> _selectedItems;
  late List<bool> _initialSelection;

  int? _dragStartIndex;

  @override
  void initState() {
    super.initState();
    _count = widget.filledCount;
    _selectedItems = List.generate(totalItems, (i) => i < _count);
  }

  void _updateCount(int index) {
    final newCount = index + 1;
    if (newCount != _count) {
      setState(() {
        _count = newCount;
        for (int i = 0; i < totalItems; i++) {
          _selectedItems[i] = i < _count;
        }
      });
      widget.onChanged(newCount);
    }
  }

  void _handleDragStart(Offset position, BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final local = box.globalToLocal(position);
    final width = box.size.width;

    final cellSize = width / 5;

    for (int i = 0; i < totalItems; i++) {
      final row = i ~/ 5;
      final col = i % 5;

      final rect = Rect.fromLTWH(
        col * cellSize,
        row * cellSize,
        cellSize,
        cellSize,
      );
      if (rect.contains(local)) {
        _dragStartIndex = i;

        _initialSelection = List<bool>.from(_selectedItems);
        break;
      }
    }
  }

  void _handleDragUpdate(Offset position, BuildContext context) {
    if (_dragStartIndex == null) return;

    final box = context.findRenderObject() as RenderBox;
    final local = box.globalToLocal(position);
    final width = box.size.width;

    final cellSize = width / 5;

    for (int i = 0; i < totalItems; i++) {
      final row = i ~/ 5;
      final col = i % 5;

      final rect = Rect.fromLTWH(
        col * cellSize,
        row * cellSize,
        cellSize,
        cellSize,
      );
      if (rect.contains(local)) {
        final dragEndIndex = i;

        final start = _dragStartIndex!;
        final end = dragEndIndex;

        final lower = start < end ? start : end;
        final upper = start > end ? start : end;

        setState(() {
          for (int j = 0; j < totalItems; j++) {
            if (j >= lower && j <= upper) {
              _selectedItems[j] = !_initialSelection[j];
            } else {
              _selectedItems[j] = _initialSelection[j];
            }
          }
        });
        final newCount = _selectedItems.where((v) => v).length;
        widget.onChanged(newCount);
        break;
      }
    }
  }

  void _toggleItem(int index) {
    setState(() {
      _selectedItems[index] = !_selectedItems[index];
    });
    final newCount = _selectedItems.where((v) => v).length;
    widget.onChanged(newCount);
  }

  void _handleDragEnd(_) {
    _dragStartIndex = null;
    _initialSelection = [];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _handleDragStart(details.globalPosition, context),
      onPanUpdate: (details) => _handleDragUpdate(details.globalPosition, context),
      onPanEnd: _handleDragEnd,
      child: GridView.count(
        crossAxisCount: 5,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(totalItems, (i) {
          final isFilled = _selectedItems[i];
          return GestureDetector(
            onTap: () => _toggleItem(i),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(4),
                color: isFilled ? Colors.blueAccent : Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black38,
                      offset: const Offset(0, 2),
                      blurRadius: 3.0
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
