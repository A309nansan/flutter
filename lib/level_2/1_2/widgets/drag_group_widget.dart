import 'package:flutter/material.dart';

class GridDragGroupWidget extends StatefulWidget {
  final int itemCount;
  final String imagePath;
  final int crossAxisCount;
  final void Function(int count)? onSelectionChanged;
  final void Function(int count)? onDragFinished;
  final VoidCallback? onReset;

  const GridDragGroupWidget({
    super.key,
    required this.itemCount,
    required this.imagePath,
    required this.crossAxisCount,
    this.onSelectionChanged,
    this.onDragFinished,
    this.onReset,
  });

  @override
  State<GridDragGroupWidget> createState() => GridDragGroupWidgetState();
}

class GridDragGroupWidgetState extends State<GridDragGroupWidget> {
  final GlobalKey _gridAreaKey = GlobalKey();
  final List<GlobalKey> _itemKeys = [];
  final List<Rect> _highlightRects = [];
  final Set<int> _selectedIndices = {};
  Offset? _startDrag;
  Offset? _endDrag;
  int _currentSelectedCount = 0;
  Color _highlightColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _itemKeys.addAll(List.generate(widget.itemCount, (_) => GlobalKey()));
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _startDrag = details.globalPosition;
      _endDrag = null;
      _highlightRects.clear();
      _selectedIndices.clear();
      _currentSelectedCount = 0;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _endDrag = details.globalPosition;
      _updateSelectedIndices();
    });
  }

  void _onPanEnd(_) {
    final selectedCount = _selectedIndices.length;

    // ✅ 선택된 항목이 없으면 바로 리턴
    if (_selectedIndices.isEmpty) {
      setState(() {
        _highlightRects.clear();
        _highlightColor = Colors.transparent;
      });
      widget.onDragFinished?.call(0);
      _startDrag = null;
      _endDrag = null;
      return;
    }

    final renderBox = _gridAreaKey.currentContext!.findRenderObject() as RenderBox;

    final selectedRects = _selectedIndices.map((i) {
      final box = _itemKeys[i].currentContext!.findRenderObject() as RenderBox;
      final globalPos = box.localToGlobal(Offset.zero);
      final localPos = renderBox.globalToLocal(globalPos);
      final size = box.size;
      return Rect.fromLTWH(localPos.dx, localPos.dy, size.width, size.height);
    }).toList();

    setState(() {
      _highlightRects.clear();
      _highlightRects.add(_mergeRects(selectedRects)); // ✅ safe merge
      _highlightColor = selectedCount == 10 ? Colors.blueAccent : Colors.redAccent;
    });

    widget.onDragFinished?.call(selectedCount);
    _startDrag = null;
    _endDrag = null;
  }

  void _updateSelectedIndices() {
    if (_startDrag == null || _endDrag == null) return;

    final renderBox = _gridAreaKey.currentContext!.findRenderObject() as RenderBox;
    final dragRect = Rect.fromPoints(
      renderBox.globalToLocal(_startDrag!),
      renderBox.globalToLocal(_endDrag!),
    );

    final newSelection = <int>{};

    for (int i = 0; i < _itemKeys.length; i++) {
      final key = _itemKeys[i];
      final itemContext = key.currentContext;
      if (itemContext == null) continue;

      final box = itemContext.findRenderObject() as RenderBox;
      final globalPos = box.localToGlobal(Offset.zero);
      final localPos = renderBox.globalToLocal(globalPos);
      final size = box.size;
      final itemRect = Rect.fromLTWH(localPos.dx, localPos.dy, size.width, size.height);

      if (dragRect.overlaps(itemRect)) {
        newSelection.add(i);
      }
    }

    setState(() {
      _selectedIndices
        ..clear()
        ..addAll(newSelection);
      _currentSelectedCount = newSelection.length;
    });

    widget.onSelectionChanged?.call(_currentSelectedCount);
  }

  Rect _mergeRects(List<Rect> rects) {
    // ✅ 빈 리스트 처리
    if (rects.isEmpty) return Rect.zero;

    double left = rects.first.left;
    double top = rects.first.top;
    double right = rects.first.right;
    double bottom = rects.first.bottom;

    for (var rect in rects) {
      left = left < rect.left ? left : rect.left;
      top = top < rect.top ? top : rect.top;
      right = right > rect.right ? right : rect.right;
      bottom = bottom > rect.bottom ? bottom : rect.bottom;
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  void resetSelection() {
    setState(() {
      _highlightRects.clear();
      _selectedIndices.clear();
      _currentSelectedCount = 0;
      _highlightColor = Colors.transparent;
    });
    widget.onReset?.call();
    widget.onSelectionChanged?.call(0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "10 묶음",
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Stack(
            children: [
              Container(
                key: _gridAreaKey,
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: GridView.count(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: widget.crossAxisCount,
                    childAspectRatio: 1,
                    children: List.generate(widget.itemCount, (index) {
                      final isSelected = _selectedIndices.contains(index);
                      return AnimatedOpacity(
                        opacity: isSelected ? 1.0 : 0.5,
                        duration: Duration(milliseconds: 200),
                        child: Container(
                          key: _itemKeys[index],
                          decoration: BoxDecoration(
                            border: Border.all(color: isSelected ? Colors.orange : Colors.black26, width: 2),
                          ),
                          child: Image.network(widget.imagePath),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              IgnorePointer(
                child: CustomPaint(
                  painter: _RectPainter(_highlightRects, _startDrag, _endDrag, _highlightColor, _gridAreaKey),
                  child: SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RectPainter extends CustomPainter {
  final List<Rect> rects;
  final Offset? start;
  final Offset? end;
  final Color highlightColor;
  final GlobalKey gridKey;

  _RectPainter(this.rects, this.start, this.end, this.highlightColor, this.gridKey);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = highlightColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (final rect in rects) {
      canvas.drawRect(rect, paint);
    }

    if (start != null && end != null) {
      final renderBox = gridKey.currentContext!.findRenderObject() as RenderBox;
      final localStart = renderBox.globalToLocal(start!);
      final localEnd = renderBox.globalToLocal(end!);
      final dragRect = Rect.fromPoints(localStart, localEnd);

      final guidePaint = Paint()
        ..color = Colors.blue.withAlpha(100)
        ..style = PaintingStyle.fill;

      canvas.drawRect(dragRect, guidePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RectPainter oldDelegate) {
    return rects != oldDelegate.rects || start != oldDelegate.start || end != oldDelegate.end || highlightColor != oldDelegate.highlightColor;
  }
}