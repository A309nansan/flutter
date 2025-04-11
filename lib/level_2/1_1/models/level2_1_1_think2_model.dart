// models/problem.dart

class ProblemCard {
  final int value;
  final List<String> images;
  bool isSelected;
  bool isCorrect;

  ProblemCard({
    required this.value,
    required this.images,
    this.isSelected = false,
    this.isCorrect = false,
  });

  factory ProblemCard.fromJson(Map<String, dynamic> json) {
    return ProblemCard(
      value: json['value'],
      images: List<String>.from(json['images']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'images': images,
      'isSelected': isSelected,
      'isCorrect': isCorrect,
    };
  }
}

class ProblemModel {
  final String problemCode;
  final String? nextProblemCode;
  final List<ProblemCard> candidates;
  final List<dynamic> answer;

  ProblemModel({
    required this.problemCode,
    this.nextProblemCode,
    required this.candidates,
    required this.answer,
  });

  factory ProblemModel.fromJson(Map<String, dynamic> json) {
    final problemData = json['problem'];
    final dynamic candidatesData = problemData['candidates'];

    List<dynamic> candidatesJson;
    if (candidatesData is List) {
      candidatesJson = candidatesData;
    } else if (candidatesData is Map) {
      // 키 타입과 상관없이 Map의 value들을 List로 변환
      candidatesJson = (candidatesData).values.toList();
    } else {
      candidatesJson = [];
    }

    List<ProblemCard> candidates =
        candidatesJson.map((e) => ProblemCard.fromJson(e)).toList();

    return ProblemModel(
      problemCode: json['problem_code'],
      nextProblemCode: json['next_problem_code'],
      candidates: candidates,
      answer: json['answer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'problem_code': problemCode,
      'next_problem_code': nextProblemCode,
      'problem': {'candidates': candidates.map((c) => c.toJson()).toList()},
      'answer': answer,
    };
  }
}
