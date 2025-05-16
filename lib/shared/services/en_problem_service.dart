import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:nansan_flutter/shared/services/secure_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnProblemService {
  String getLevelPath(String problemCode) {
    final levelMatch = RegExp(r'lv(\d+)').firstMatch(problemCode);
    if (levelMatch == null) {
      throw FormatException('Invalid problem code: $problemCode');
    }
    final levelNumber = levelMatch.group(1);
    return "/level$levelNumber/$problemCode";
  }

  static Future<int?> getChildId() async {
    final childId = await SecureStorageService.getChildId();
    return childId;
  }

  // 문제 저장 (진행 중 문제만 저장)
  static Future<void> saveContinueProblem(String problemCode, int childId) async {
    final prefs = await SharedPreferences.getInstance();
    final String childIdKey = childId.toString();
    final String chapterCode = problemCode.substring(0, problemCode.length - 3);

    final jsonString = prefs.getString('child_problems');
    Map<String, dynamic> data = jsonString != null ? jsonDecode(jsonString) : {};

    if (!data.containsKey(childIdKey) || data[childIdKey] == null) {
      data[childIdKey] = <String, dynamic>{};
    }

    Map<String, dynamic> chapterData = Map<String, dynamic>.from(data[childIdKey]);

    chapterData[chapterCode] = {
      'last': problemCode,
    };

    data[childIdKey] = chapterData;
    await prefs.setString('child_problems', jsonEncode(data));
  }

  // 전체 풀이 기록 저장
  static Future<void> saveProblemResults(Map<String, bool> results, String problemCode, int childId) async {
    final prefs = await SharedPreferences.getInstance();
    final String childIdKey = childId.toString();
    final String chapterCode = problemCode.substring(0, problemCode.length - 3);

    final jsonString = prefs.getString('child_problems');
    Map<String, dynamic> data = jsonString != null ? jsonDecode(jsonString) : {};

    if (!data.containsKey(childIdKey) || data[childIdKey] == null) {
      data[childIdKey] = <String, dynamic>{};
    }

    Map<String, dynamic> chapterData = Map<String, dynamic>.from(data[childIdKey]);
    chapterData[chapterCode] = {
      'last': results.keys.last,
      'records': results,
    };

    data[childIdKey] = chapterData;
    await prefs.setString('child_problems', jsonEncode(data));
  }

  static Future<Map<String, bool>> loadProblemResults(String problemCode, int childId) async {
    final prefs = await SharedPreferences.getInstance();
    final String childIdKey = childId.toString();
    final jsonString = prefs.getString('child_problems');
    final String chapterCode = problemCode.substring(0, problemCode.length - 3);

    if (jsonString != null) {
      Map<String, dynamic> data = jsonDecode(jsonString);
      final chapterData = data[childIdKey]?[chapterCode];
      if (chapterData != null && chapterData['records'] != null) {
        return Map<String, bool>.from(chapterData['records']);
      }
    }
    return {};
  }

  static Future<String?> loadContinueProblem(String chapterCode, int childId) async {
    final prefs = await SharedPreferences.getInstance();
    final String childIdKey = childId.toString();

    final jsonString = prefs.getString('child_problems');
    if (jsonString != null) {
      Map<String, dynamic> data = jsonDecode(jsonString);
      final chapterMap = data[childIdKey]?[chapterCode];

      if (chapterMap is Map && chapterMap['last'] is String) {
        return chapterMap['last'];
      }
    }
    return null;
  }

  static Future<bool> existsContinueProblem(String chapterCode, int childId) async {
    final prefs = await SharedPreferences.getInstance();
    final String childIdKey = childId.toString();

    final jsonString = prefs.getString('child_problems');
    if (jsonString != null) {
      Map<dynamic, dynamic> data = jsonDecode(jsonString);
      final chapterData = data[childIdKey];
      if (chapterData != null && chapterData[chapterCode] != null) {
        return true;
      }
    }
    return false;
  }

  static Future<void> clearChapterProblem(int childId, String problemCode) async {
    final prefs = await SharedPreferences.getInstance();
    final String childIdKey = childId.toString();
    final String chapterCode = problemCode.substring(0, problemCode.length - 3);

    final jsonString = prefs.getString('child_problems');
    Map<dynamic, dynamic> data = jsonString != null ? jsonDecode(jsonString) : {};

    if (data.containsKey(childIdKey)) {
      Map<String, dynamic> chapterData = Map<String, dynamic>.from(data[childIdKey]);

      if (chapterData.containsKey(chapterCode)) {
        chapterData.remove(chapterCode);
        data[childIdKey] = chapterData;
        await prefs.setString('child_problems', jsonEncode(data));
        debugPrint('🧹 초기화 완료: childId=$childId, chapterCode=$chapterCode 기록 삭제');
      } else {
        debugPrint('ℹ️ 해당 챕터 기록 없음: childId=$childId, chapterCode=$chapterCode');
      }
    } else {
      debugPrint('ℹ️ 해당 아이 기록 없음: childId=$childId');
    }
  }
}