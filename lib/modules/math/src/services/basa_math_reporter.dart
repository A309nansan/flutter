import 'package:flutter/material.dart';
import 'package:nansan_flutter/modules/math/src/utils/math_stat_converter.dart';

import '../../../../shared/services/request_service.dart';

class BasaMathReporter {
  Future<List<Map<String, dynamic>>> fetchAPIData(int childId, int parentCategory, int childCategory) async {
    //debugPrint("❗PARENT: $parent, CHILD: $child");
    try {
      //debugPrint("sendResponse for Report start");
      final response = await RequestService.get('/m/$childId/problems/$parentCategory/$childCategory');
      //debugPrint("sendResponse for Report finish");
      //debugPrintPrettify(response);

      if (response is List) {
        // ✅ 변환 결과 저장
        final result =
            response.map((e) => Map<String, dynamic>.from(e)).toList();

        // debugPrint("LENGTH OF RESPONSE: ${result.length}");
        for (int i = 0; i < result.length; i++) {
          //debugPrintPrettify(result[i]);
        }

        return result;
      } else {
        throw Exception('Expected a List');
      }
    } catch (e) {
      //debugPrint('❗ Error fetching API data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchHuge(int childId, int parentCategory) async {
    try {
      final List<List<Map<String, dynamic>>> results = [];

      for (int childCategory = 1; childCategory <= 4; childCategory++) {
        final data = await fetchAPIData(childId, parentCategory, childCategory);
        results.add(data);
        await Future.delayed(const Duration(milliseconds: 300)); // 💡 100ms 딜레이
      }

      // 변환
      final List<Map<String, dynamic>> statsList =
      results.map((report) => convertReportsToStats(report)).toList();

      // 합치기
      Map<String, dynamic> combined = statsList.first;
      for (int i = 1; i < statsList.length; i++) {
        combined = concatenateStats(combined, statsList[i]);
      }

      return combined;
    } catch (e) {
      debugPrint("❗ Error in fetchHuge: $e");
      return {}; // 에러 시 빈 맵 반환
    }
  }
}
