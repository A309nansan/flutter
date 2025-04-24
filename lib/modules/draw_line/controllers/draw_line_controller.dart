import '../models/draw_line_models.dart';

class DrawLineDotsController {
  List<DrawLineDot> dots = [];
  List<DrawLineConnection> connections = [];

  void addDot(DrawLineDot dot) {
    dots.add(dot);
  }

  void clearAll() {
    dots.clear();
    connections.clear();
  }

  bool isDotConnected(DrawLineDot dot) {
    return connections.any((conn) => conn.involves(dot));
  }
}
