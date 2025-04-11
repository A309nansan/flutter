import 'dart:convert';

class SubmitRequest {
  final int childId;
  final String problemCode;
  final String dateTime;
  final int solvingTime;
  final bool isCorrected;
  final Map<dynamic, dynamic> problem;
  final Map<dynamic, dynamic> answer;
  final Map<String, dynamic> input;

  SubmitRequest({
    required this.childId,
    required this.problemCode,
    required this.dateTime,
    required this.solvingTime,
    required this.isCorrected,
    required this.problem,
    required this.answer,
    required this.input,
  });

  // JSON 직렬화: 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      "child_id": childId,
      "problem_code": problemCode,
      "date_time": dateTime,
      "solving_time": solvingTime,
      "is_corrected": isCorrected,
      "problem": problem,
      "answer": answer,
      "input": input,
    };
  }

  // JSON 역직렬화: JSON 데이터를 객체로 변환
  factory SubmitRequest.fromJson(Map<String, dynamic> json) {
    return SubmitRequest(
      childId: json['child_id'] as int,
      problemCode: json["problem_code"] as String,
      dateTime: json["date_time"] as String,
      solvingTime: json["solving_time"] as int,
      isCorrected: json["is_corrected"] as bool,
      problem: json["problem"] as Map<String, dynamic>,
      answer: json["answer"] as Map<String, dynamic>,
      input: json["input"] as Map<String, dynamic>,
    );
  }

  // JSON 문자열로 변환 (디버깅용)
  String toJsonString() => jsonEncode(toJson());
}
