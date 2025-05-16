import 'package:flutter/material.dart';

import '../../../../shared/services/request_service.dart';
import '../utils/math_data_utils.dart';
import '../utils/math_hardcoder.dart';
import '../models/m_problem_metadata.dart';

class BasaMathDecoder {
  /// 예: JSON을 읽어오는 메서드
  Future<Map<String, dynamic>> fetchBasaMProblemDataTeachingMode(int parentCategory, int childCategory) async {
    debugPrint("❗FetchBasaMProblemDataTeachingMode: PARENT: $parentCategory, CHILD: $childCategory");
    try {
      debugPrint("sendResponse start");
      final response = await RequestService.get('/m/parent/$parentCategory/$childCategory');
      debugPrint("sendResponse finish");
      //printPrettify(response);
      // 응답이 Map 형태가 아니면 예외 처리
      if (response is Map<String, dynamic>) {
        return response;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      debugPrint('❗ Error fetching API data: $e');
      rethrow;
    }
  }
  Future<Map<String, dynamic>> fetchBasaMProblemDataPracticeMode(int parentCategory, int childCategory, int childId) async {
    debugPrint("❗FetchBasaMProblemDataPracticeMode PARENT: $parentCategory, CHILD: $childCategory, childId: $childId");
    try {
      debugPrint("sendResponse start");
      final response = await RequestService.get('/m/self/$childId/$parentCategory/$childCategory');
      debugPrint("sendResponse finish");
      //printPrettify(response);
      // 응답이 Map 형태가 아니면 예외 처리
      if (response is Map<String, dynamic>) {
        return response;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      debugPrint('❗ Error fetching API data: $e');
      rethrow;
    }
  }
  /// JSON의 "problem" 파트를 읽어와서 MathData 객체를 만드는 메서드
  MProblemMetadata getMathDataFromResponse(
    Map<String, dynamic> json,
    int categoryIndex,
  ) {
    // 1) problem 파싱
    final problem = json['problem'];
    final int first = problem['first'];
    final int second = problem['second'];
    final String operator = problem['operator'];
    final problemNumber = json['problemNumber'];

    // 3) category와 index 기반으로 MathData 생성 (이미 구현된 함수라고 가정)
    final mathData = MProblemMetadata(
      index: problemNumber,
      num1: first,
      num2: second,
      operator: operator,
      matrixVolume: getMatrixVolumes(categoryIndex, first, second),
      type: getType(categoryIndex),
    );
    return mathData;
  }

  MProblemMetadata getMathDataFromReportResponse(
    Map<String, dynamic> json,
    int Mtype,
  ) {
    // 1) problem 파싱
    final problem = json['generatedProblem'];
    final int first = problem['first'];
    final int second = problem['second'];
    final String operator = problem['operator'];
    final problemNumber = json['problemNumber'];

    final mathData = MProblemMetadata(
      index: problemNumber,
      num1: first,
      num2: second,
      operator: operator,
      matrixVolume: getMatrixVolumes(Mtype, first, second),
      type: getType(Mtype),
    );
    return mathData;
  }

  /// 설명: keyName을 바탕으로 answerMap의 한 줄을 NumberList화 한다.

  List<List<List<String>>> getAnswerFromResponse(
    Map<String, dynamic> json,
    int index,
    int categoryIndex,
  ) {
    List<int> whatTheFuckIsMv = getMatrixVolumes(
      categoryIndex,
      json['problem']['first'],
      json['problem']['second'],
    );
    List<List<String>> carryList = [];
    List<List<String>> progressList = [];
    List<List<String>> answerList = [];
    // 1) answer 파싱
    final answer = json['answer'] as Map<String, dynamic>?;
    if (answer == null) return [[], [], []];

    if (answer.containsKey('remainder')) {
      if (answer['remainder'] != 0) {
        carryList.add([json['answer']['remainder'].toString()]);
      }
    } else {
      for (int i = 1; i <= whatTheFuckIsMv[0]; i++) {
        carryList.add(
          convertNumberMapToList(
            json['answer'],
            "carry${whatTheFuckIsMv[0] - i + 1}",
            whatTheFuckIsMv[1],
          ),
        );
      }
    }

    for (int i = 1; i <= whatTheFuckIsMv[2]; i++) {
      progressList.add(
        convertNumberMapToList(json['answer'], "calculate$i", whatTheFuckIsMv[3]),
      );
    }

    for (int i = 1; i <= whatTheFuckIsMv[4]; i++) {
      answerList.add(convertNumberMapToList(json['answer'], "result", whatTheFuckIsMv[5]));
    }

    // 4) 세 개의 2차원 리스트를 한번에 묶어서 3차원 리스트로 반환
    return [carryList, progressList, answerList];
  }

  List<List<List<String>>> getDataFromReportResponse(
    Map<String, dynamic> json,
    int index,
    int categoryIndex,
    String type,
  ) {
    //debugPrint("🚀🚀🚀🚀🚀");
    List<int> whatTheFuckIsMv = getMatrixVolumes(
      categoryIndex,
      json['generatedProblem']['first'],
      json['generatedProblem']['second'],
    );
    List<List<String>> carryList = [];
    List<List<String>> progressList = [];
    List<List<String>> answerList = [];
    // 1) answer 파싱
    final answer = json[type] as Map<String, dynamic>?;
    if (answer == null) return [[], [], []];

    if (answer.containsKey('remainder')) {
      if (answer['remainder'] != 0) {
        debugPrint("REMAINDER EXISTS CASE");
        carryList.add([json[type]['remainder'].toString()]);
      } else {
        if (whatTheFuckIsMv[0] != 0) carryList.add(["0"]);
      }
    } else {
      for (int i = 1; i <= whatTheFuckIsMv[0]; i++) {
        //debugPrint("REMAINDER NONEXIST CASE");
        carryList.add(
          convertNumberMapToList(json[type], "carry${whatTheFuckIsMv[0] - i + 1}", whatTheFuckIsMv[1]),
        );
      }
    }

    for (int i = 1; i <= whatTheFuckIsMv[2]; i++) {
      progressList.add(
        convertNumberMapToList(json[type], "calculate$i", whatTheFuckIsMv[3]),
      );
    }

    for (int i = 1; i <= whatTheFuckIsMv[4]; i++) {
      answerList.add(convertNumberMapToList(json[type], "result", whatTheFuckIsMv[5]));
    }

    return [carryList, progressList, answerList];
  }
}
