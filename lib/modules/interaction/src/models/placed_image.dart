import 'dart:ui' as ui;

class PlacedImage {
  final ui.Image image;
  ui.Offset position;
  double rotation;
  double scale;

  PlacedImage({
    required this.image,
    required this.position,
    this.rotation = 0,
    this.scale = 1.0,
  });
}
