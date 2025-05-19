class AnswerCandidate {
  final String? object;
  final int number;
  final String key;

  AnswerCandidate({this.object, required this.number, required this.key});

  factory AnswerCandidate.fromJson(Map<String, dynamic> json) {
    return AnswerCandidate(
      object: json['object'] as String?,
      number: json['number'] as int? ?? 0,
      key: json['key'] as String? ?? 'unknown',
    );
  }
}
