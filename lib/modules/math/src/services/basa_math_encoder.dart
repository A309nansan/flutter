import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../shared/services/request_service.dart';
import '../utils/math_basic.dart';
import '../utils/math_data_utils.dart';

class BasaMathEncoder {
  Future<int> sendAPIData(
    int group,
    int child,
    Map<String, dynamic> data,
  ) async {
    debugPrint("❗PARENT: $group, CHILD: $child");

    try {
      // 요청 시작 로그
      debugPrint("🚀 sendResponse start 🚀🚀🚀🚀🚀");
      debugPrintPrettify(data);

      // POST 요청 전송 (body 없이 전송)
      final response = await RequestService.post(
        '/m/submit/$group/$child',
        data: data,
      );

      // 요청 완료 로그
      debugPrint("✅ sendResponse finish");
      debugPrint("RESPONSE: ");
      debugPrint(response.toString());
      debugPrint("RESPONSE: ");
      // 응답 형식 검증
      if (response is int) {
        return response;
      } else {
        throw Exception(
          'Invalid response format: Expected int, got ${response.runtimeType}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❗ Error fetching API data: $e');
      debugPrint('📌 Stack trace: $stackTrace');
      rethrow; // 호출한 쪽에서도 에러를 처리할 수 있도록 다시 던짐
    }
  }

  Map<String, dynamic> responseToAnswerMap(
    List<List<List<String>>> ans,
    List<int> MV,
  ) {
    Map<String, dynamic> map = {};
    bool hasRemainder = MV[2] != 0 && (MV[1] == 1 || MV[0] == 0);
    for (int i = 0; i < MV[4]; i++) {
      Map<String, dynamic> temp = convertListToNumberMap(ans[2][i], MV[5]);
      if (temp.isNotEmpty) map["result"] = temp;
    }
    if (!hasRemainder) {
      for (int i = 0; i < MV[0]; i++) {
        Map<String, dynamic> temp = convertListToNumberMap(ans[0][i], MV[1]);
        if (temp.isNotEmpty) map["carry${MV[0] - i}"] = temp;
        //map["carry${MV[0] - i}"] = convertListToNumberMap(ans[0][i], MV[1]);
      }
    }
    for (int i = 0; i < MV[2]; i++) {
      Map<String, dynamic> temp = convertListToNumberMap(ans[1][i], MV[3]);
      if (temp.isNotEmpty) map["calculate${i + 1}"] = temp;
      //map["calculate${i + 1}"] = convertListToNumberMap(ans[1][i], MV[3]);
    }

    if (hasRemainder) {
      if (MV[0] == 0 || ans[0][0][0] == "")
        map["remainder"] = 0;
      else
        map["remainder"] = int.parse(ans[0][0][0]);
    }
    return map;
  }

  Map<String, dynamic> initiateRequest(Map<String, dynamic> response) {
    debugPrint("💡INITIAL STAGE💡");
    Map<String, dynamic> request = {};
    final DateTime now = DateTime.now();
    request["problemNumber"] = response["problemNumber"];
    request["solvedDate"] = todayDateOnly();
    request["solvedTime"] = "0";
    request["generatedProblem"] = response["problem"];
    request["generatedAnswer"] = response["answer"];
    request["_startTime"] = now;

    //debugPrintPrettify(toJsonCompatible(request));
    debugPrint("✅check✅");
    return request;
  }

  void addUserDataToRequest(
    Map<String, dynamic> request,
    Map<String, dynamic> userData,
  ) {
    debugPrint("🔥THE FINAL STAGE🔥");
    request["userAnswer"] = userData;
    final DateTime now = DateTime.now();
    final int secondsTaken = now.difference(request["_startTime"]).inSeconds;
    request["solvedTime"] = secondsTaken.toString();
    request.remove("_startTime");

    //debugPrintPrettify(toJsonCompatible(request));
    debugPrint("✅check✅");
    return;
  }
}

Future<void> main() async {
  BasaMathEncoder bme = BasaMathEncoder();
  Map<String, dynamic> json1 = {
    "problemNumber": 1,
    "problem": {"first": 78, "second": 26, "operator": "MULT"},
    "answer": {
      "result": {"one": 8, "two": 2, "three": 0, "four": 2},
      "carry2": {"three": 1, "four": 1},
      "carry1": {"two": 4, "three": 4},
      "calculate1": {"one": 8, "two": 6, "three": 4},
      "calculate2": {"two": 6, "three": 5, "four": 1},
    },
  };
  Map<String, dynamic> json2 = {
    "problemNumber": 1,
    "problem": {"first": 1575, "second": 1108, "operator": "MIN"},
    "answer": {
      "result": {"one": 7, "two": 6, "three": 4},
      "carry1": {"two": 6},
    },
  };
  Map<String, dynamic> json3 = {
    "problemNumber": 1,
    "problem": {"first": 78, "second": 7, "operator": "DIV"},
    "answer": {
      "result": {"one": 1, "two": 1},
      "calculate1": {"two": 7},
      "calculate2": {"one": 8},
      "calculate3": {"one": 7},
      "remainder": 1,
    },
  };
  Map<String, dynamic> json4 = {
    "problemNumber": 1,
    "problem": {"first": 60, "second": 4, "operator": "DIV"},
    "answer": {
      "result": {"one": 5, "two": 1},
      "calculate1": {"two": 4},
      "calculate2": {"one": 0, "two": 2},
      "calculate3": {"one": 0, "two": 2},
      "remainder": 0,
    },
  };
  Map<String, dynamic> json5 = {
    "problemNumber": 1,
    "problem": {"first": 3, "second": 5, "operator": "PLUS"},
    "answer": {
      "result": {"one": 8},
    },
  };
  Map<String, dynamic> json6 = {
    "problemNumber": 1,
    "problem": {"first": 7043, "second": 9449, "operator": "PLUS"},
    "answer": {
      "result": {"one": 2, "two": 9, "three": 4, "four": 6, "five": 1},
      "carry1": {"two": 1, "five": 1},
    },
  };
  var jsonSet = [json1, json2, json3, json4, json5, json6];
  List<int> size1 = [2, 4, 2, 4, 1, 4];
  List<int> size2 = [1, 4, 0, 0, 1, 4];
  List<int> size3 = [1, 1, 4, 2, 1, 2];
  List<int> size4 = [0, 0, 3, 2, 1, 2];
  List<int> size5 = [0, 0, 0, 0, 1, 1];
  List<int> size6 = [1, 5, 0, 0, 1, 5];
  List sizes = [size1, size2, size3, size4, size5, size6];
  BasaMathEncoder encoder = BasaMathEncoder();
  var outputRaw = [];
  outputRaw.add(generateOutput(size1));
  outputRaw.add(generateOutput(size2));
  outputRaw.add(generateOutput(size3));
  outputRaw.add(generateOutput(size4));
  outputRaw.add(generateOutput(size5));
  outputRaw.add(generateOutput(size6));
  for (int TC = 0; TC < 1; TC++) {
    for (int test = 0; test < 3; test++) {
      final Random rand = Random();
      Map<String, dynamic> req = bme.initiateRequest(jsonSet[test]);
      debugPrint("💡INITIAL STAGE💡");
      debugPrintPrettify(toJsonCompatible(req));
      debugPrint("🟨check🟨");
      var output = outputRaw[test];
      Map<String, dynamic> ans = bme.responseToAnswerMap(
        outputRaw[test],
        sizes[test],
      );
      int delaySeconds = rand.nextInt(100) + 1;
      await Future.delayed(Duration(milliseconds: delaySeconds));
      bme.addUserDataToRequest(req, ans);
      debugPrint("🔥THE FINAL STAGE🔥");
      debugPrintPrettify(toJsonCompatible(req));
      debugPrint("✅check✅");
      debugPrint("");
    }
  }
}

///문제를 풀 때 사용했던 list 형식을 key-value로 변환합니다.

///userResponse(숫자만) key-value의 Map으로 변환합니다.
