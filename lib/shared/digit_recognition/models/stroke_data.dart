import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

class StrokeData {
  final List<Stroke> strokes;
  final Ink ink;

  StrokeData({required this.strokes, required this.ink});

  factory StrokeData.empty() {
    return StrokeData(strokes: [], ink: Ink());
  }

  StrokeData copyWith({List<Stroke>? strokes, Ink? ink}) {
    return StrokeData(strokes: strokes ?? this.strokes, ink: ink ?? this.ink);
  }

  bool get isEmpty => strokes.isEmpty;
  bool get isNotEmpty => strokes.isNotEmpty;
}
