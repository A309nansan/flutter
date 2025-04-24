import 'package:flutter/material.dart';
import '../controllers/draw_line_controller.dart';
import '../models/draw_line_models.dart';
import '../widgets/draw_line_dot_widget.dart';
import '../widgets/draw_lines_painter.dart';

class DotConnectionScreen extends StatefulWidget {
  final Widget? child;

  const DotConnectionScreen({super.key, this.child});

  @override
  State<DotConnectionScreen> createState() => _DotConnectionScreenState();
}

class _DotConnectionScreenState extends State<DotConnectionScreen> {
  final DrawLineDotsController dotsController = DrawLineDotsController();

  DrawLineDot? _startDot;
  Offset? _currentPosition;
  bool _isDrawingTemporaryLine = false;
  DrawLineDot? _hoveredDot;
  Size _widgetSize = Size.zero;

  final Map<String, List<String>> _connectionRules = {
    'A': ['B'],
    'B': ['A'],
    'C': [],
  };

  @override
  void initState() {
    super.initState();
  }

  void _initializeDots(Size size) {
    dotsController.clearAll();
    dotsController.addDot(
      DrawLineDot(id: '1', key: 'A', position: const Offset(0.2, 0.15)),
    );
    dotsController.addDot(
      DrawLineDot(id: '2', key: 'A', position: const Offset(0.2, 0.4)),
    );
    dotsController.addDot(
      DrawLineDot(id: '3', key: 'A', position: const Offset(0.2, 0.65)),
    );
    dotsController.addDot(
      DrawLineDot(id: '4', key: 'B', position: const Offset(0.8, 0.15)),
    );
    dotsController.addDot(
      DrawLineDot(id: '5', key: 'B', position: const Offset(0.8, 0.4)),
    );
    dotsController.addDot(
      DrawLineDot(id: '6', key: 'B', position: const Offset(0.8, 0.65)),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _resetState() {
    setState(() {
      _initializeDots(_widgetSize);
      _startDot = null;
      _currentPosition = null;
      _isDrawingTemporaryLine = false;
      _hoveredDot = null;
    });
  }

  void _handleDotDragStart(PointerDownEvent event, DrawLineDot dot) {
    if (dotsController.isDotConnected(dot)) return;
    setState(() {
      _startDot = dot;
      _currentPosition = event.localPosition;
      _isDrawingTemporaryLine = true;
      _hoveredDot = null;
    });
  }

  void _handlePointerMove(Offset localPosition) {
    if (!_isDrawingTemporaryLine || _startDot == null) return;

    setState(() {
      _currentPosition = localPosition;
      final foundDot = _findDotAt(localPosition);
      bool canConnect = false;

      if (foundDot != null &&
          foundDot.id != _startDot!.id &&
          !dotsController.isDotConnected(foundDot)) {
        final allowedKeys = _connectionRules[_startDot!.key];
        if (allowedKeys != null && allowedKeys.contains(foundDot.key)) {
          canConnect = true;
        }
      }
      _hoveredDot = canConnect ? foundDot : null;
    });
  }

  void _handlePointerUp(Offset localPosition) {
    if (!_isDrawingTemporaryLine || _startDot == null) return;

    final targetDot = _hoveredDot;

    if (targetDot != null) {
      bool alreadyExists = dotsController.connections.any(
        (conn) =>
            (conn.dot1.id == _startDot!.id && conn.dot2.id == targetDot.id) ||
            (conn.dot1.id == targetDot.id && conn.dot2.id == _startDot!.id),
      );
      if (!alreadyExists) {
        dotsController.connections.add(
          DrawLineConnection(
            dot1: _startDot!,
            dot2: targetDot,
            isDashed: false,
          ),
        );
      }
    }

    setState(() {
      _startDot = null;
      _currentPosition = null;
      _isDrawingTemporaryLine = false;
      _hoveredDot = null;
    });
  }

  DrawLineDot? _findDotAt(Offset absolutePosition) {
    if (_widgetSize == Size.zero) return null;

    const double hitRadius = 15.0;
    for (var dot in dotsController.dots) {
      final dotAbsolutePosition = Offset(
        dot.position.dx * _widgetSize.width,
        dot.position.dy * _widgetSize.height,
      );
      final distance = (dotAbsolutePosition - absolutePosition).distance;
      if (distance < hitRadius) {
        return dot;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final newSize = constraints.biggest;
        if (_widgetSize != newSize) {
          _widgetSize = newSize;
          if (dotsController.dots.isEmpty) {
            _initializeDots(_widgetSize);
          }
        }

        if (_widgetSize == Size.zero) {
          return const Center(child: CircularProgressIndicator());
        }

        return Listener(
          onPointerMove: (details) => _handlePointerMove(details.localPosition),
          onPointerUp: (details) => _handlePointerUp(details.localPosition),
          behavior: HitTestBehavior.translucent,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (widget.child != null) widget.child!,
                Positioned.fill(
                  child: CustomPaint(
                    painter: DrawLinesPainter(
                      parentSize: _widgetSize,
                      connections: dotsController.connections,
                      startDot: _startDot,
                      currentPosition: _currentPosition,
                      isDrawingTemporaryLine: _isDrawingTemporaryLine,
                    ),
                  ),
                ),
                ...dotsController.dots.map(
                  (dot) => DrawLineDotWidget(
                    dot: dot,
                    parentSize: _widgetSize,
                    isSelected: (_startDot?.id == dot.id),
                    isHovered: (_hoveredDot?.id == dot.id),
                    isConnected: dotsController.isDotConnected(dot),
                    onPointerDown: _handleDotDragStart,
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FloatingActionButton.small(
                        onPressed: _resetState,
                        tooltip: '초기화',
                        backgroundColor: Colors.orange,
                        child: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
