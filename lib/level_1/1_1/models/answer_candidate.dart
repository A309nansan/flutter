class AnswerCandidate {
  final String? imageUrl;
  final int number;
  final String key;

  AnswerCandidate({this.imageUrl, required this.number, required this.key});

  factory AnswerCandidate.fromJson(Map<String, dynamic> json) {
    return AnswerCandidate(
      imageUrl: json['image_url'] as String?,
      number: json['number'] as int? ?? 0,
      key: json['key'] as String? ?? 'unknown',
    );
  }
}
