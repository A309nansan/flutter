import 'dart:convert';

import '../services/basa_math_reporter.dart';
import 'math_string_hardcoder.dart';

Map<String, dynamic> convertReportsToStats(List<Map<String, dynamic>> reports) {
  final Map<String, dynamic> statsData = {};

  for (var singleReport in reports) {
    final String solvedDate = singleReport["solvedDate"];
    final List<dynamic> problems = singleReport["problems"] ?? [];

    if (!statsData.containsKey(solvedDate)) {
      statsData[solvedDate] = {
        "times": <int>[],
        "correctCount": 0,
        "errorCodes": <String, int>{},
      };
    }

    final dateStats = statsData[solvedDate];

    for (var problem in problems) {
      final int solvedTime = int.tryParse("${problem["solvedTime"]}") ?? 0;
      final bool correct = problem["correct"] ?? false;
      final List<dynamic> errorCodes = problem["errorCodes"] ?? [];

      dateStats["times"].add(solvedTime);
      if (correct) {
        dateStats["correctCount"]++;
      }

      for (var error in errorCodes) {
        String errorKR = returnErrorType(error);
        if (!dateStats["errorCodes"].containsKey(errorKR)) {
          dateStats["errorCodes"][errorKR] = 0;
        }
        dateStats["errorCodes"][errorKR]++;
      }
    }
  }

  return statsData;
}

Map<String, dynamic> concatenateStats(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
    ) {
  final Map<String, dynamic> result = Map.from(a);

  b.forEach((date, bStats) {
    if (!result.containsKey(date)) {
      result[date] = {
        "times": List<int>.from(bStats["times"] ?? []),
        "correctCount": bStats["correctCount"] ?? 0,
        "errorCodes": Map<String, int>.from(bStats["errorCodes"] ?? {}),
      };
    } else {
      result[date]["times"].addAll(List<int>.from(bStats["times"] ?? []));
      result[date]["correctCount"] += bStats["correctCount"] ?? 0;

      final Map<String, int> bErrors = Map<String, int>.from(bStats["errorCodes"] ?? {});
      bErrors.forEach((code, count) {
        result[date]["errorCodes"][code] =
            (result[date]["errorCodes"][code] ?? 0) + count;
      });
    }
  });

  return result;
}
