class ProblemResponse {
  final String problemCode;
  final String nextProblemCode;
  final Map<String, dynamic> problem;
  final Map<String, dynamic> answer;
  final int current;
  final int total;

  ProblemResponse({
    required this.problemCode,
    required this.nextProblemCode,
    required this.problem,
    required this.answer,
    required this.current,
    required this.total,
  });

  factory ProblemResponse.fromJson(Map<String, dynamic> json) {
    return ProblemResponse(
      problemCode: json['problem_code'] as String? ?? '',
      nextProblemCode: json['next_problem_code'] as String? ?? '',
      problem: json['problem'] as Map<String, dynamic>? ?? {},
      answer: json['answer'] as Map<String, dynamic>? ?? {},
      current: json['current_problem_number'] as int? ?? 0,
      total: json["total_problem_count"] as int? ?? 0,
    );
  }
}
