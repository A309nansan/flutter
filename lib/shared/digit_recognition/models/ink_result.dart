class InkResult {
  final String text;
  final double confidence;

  InkResult({required this.text, this.confidence = 0.0});

  @override
  String toString() => 'InkResult(text: $text, confidence: $confidence)';
}
