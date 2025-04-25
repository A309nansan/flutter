import '../models/draw_line_models.dart';

class DrawLineDotsController {
  List dots = [];
  List connections = [];

  void addDot(DrawLineDot dot) {
    dots.add(dot);
  }

  // 연결을 추가하는 전용 메서드 추가
  void addConnection(DrawLineConnection connection) {
    connections.add(connection);
  }

  void clearAll() {
    dots.clear();
    connections.clear();
  }

  bool isDotConnected(DrawLineDot dot) {
    return connections.any((conn) => conn.involves(dot));
  }
}
