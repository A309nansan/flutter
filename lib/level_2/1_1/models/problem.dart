// models/problem.dart
class Problem {
  final String problemCode;
  final String? nextProblemCode;
  final ProblemData problem;
  final dynamic answer;

  Problem({
    required this.problemCode,
    this.nextProblemCode,
    required this.problem,
    this.answer,
  });

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      problemCode: json['problem_code'],
      nextProblemCode: json['next_problem_code'],
      problem: ProblemData.fromJson(json['problem']),
      answer: json['answer'],
    );
  }
}

class ProblemData {
  final List<ProblemLine> lines;

  ProblemData({
    required this.lines,
  });

  factory ProblemData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> lineList = json['line'];
    List<ProblemLine> lines =
    lineList.map((item) => ProblemLine.fromJson(item)).toList();
    return ProblemData(lines: lines);
  }

  Map<String, dynamic> toJson() {
    return {
      'line': lines.map((line) => line.toJson()).toList(),
    };
  }
}

class ProblemLine {
  final int left;
  final String leftImg;
  final int right;
  final String rightImg;
  bool? userMatched;
  bool isCorrect;

  ProblemLine({
    required this.left,
    required this.leftImg,
    required this.right,
    required this.rightImg,
    this.userMatched,
    this.isCorrect = false,
  });

  factory ProblemLine.fromJson(Map<String, dynamic> json) {
    return ProblemLine(
      left: json['left'],
      leftImg: json['left_img'],
      right: json['right'],
      rightImg: json['right_img'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'left': left,
      'left_img': leftImg,
      'right': right,
      'right_img': rightImg,
      'userMatched': userMatched,
      'isCorrect': isCorrect,
    };
  }
}
