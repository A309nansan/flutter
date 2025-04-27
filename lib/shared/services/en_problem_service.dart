import 'dart:convert';

import 'package:nansan_flutter/shared/services/secure_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnProblemService {
  String getLevelPath(String problemCode) {
    final levelMatch = RegExp(r'lv(\d+)').firstMatch(problemCode);
    if (levelMatch == null) {
      throw FormatException('Invalid problem code: $problemCode');
    }

    final levelNumber = levelMatch.group(1); // 예: "1"
    return "/level$levelNumber/$problemCode";
  }

  static Future<int?> getChildId() async {
    final childId = await SecureStorageService.getChildId();

    return childId;
  }

  // 문제 저장
  static Future<void> saveContinueProblem(String problemCode, int childId) async {
    final prefs = await SharedPreferences.getInstance();

    final String childIdKey = childId.toString();
    final String chapterCode = problemCode.substring(0, problemCode.length - 3);

    final jsonString = prefs.getString('child_problems');
    Map<dynamic, dynamic> data = jsonString != null ? jsonDecode(jsonString) : {};

    if (!data.containsKey(childIdKey) || data[childIdKey] == null) {
      data[childIdKey] = <String, dynamic>{};
    }

    (data[childIdKey] as Map<String, dynamic>)[chapterCode] = problemCode;

    await prefs.setString('child_problems', jsonEncode(data));

    final savedJsonString = prefs.getString('child_problems');
    if (savedJsonString != null) {
      Map<dynamic, dynamic> savedData = jsonDecode(savedJsonString);

      print("전체: $savedData");
      var savedProblemCode = savedData[childIdKey]?[chapterCode];
      if (savedProblemCode != null) {
        print("🎯 저장된 문제코드 (childId=$childId, chapterCode=$chapterCode): $savedProblemCode");
      } else {
        print("❓ 저장된 문제 없음 (childId=$childId, chapterCode=$chapterCode)");
      }
    }
  }
  
  // 진행중인 문제코드 불러오기
  static Future<String?> loadContinueProblem(String chapterCode, int childId) async {
    final prefs = await SharedPreferences.getInstance();
    final String childIdKey = childId.toString();

    final jsonString = prefs.getString('child_problems');
    if (jsonString != null) {
      Map<dynamic, dynamic> data = jsonDecode(jsonString);

      final chapterData = data[childIdKey];
      if (chapterData != null && chapterData[chapterCode] != null) {
        return chapterData[chapterCode] as String;
      }
    }
    return null;
  }
  
  // 해당 챕터 진행 여부
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
    final String chapterCode = problemCode.substring(0, problemCode.length - 3);;

    final jsonString = prefs.getString('child_problems');
    Map<dynamic, dynamic> data = jsonString != null ? jsonDecode(jsonString) : {};

    if (data.containsKey(childIdKey)) {
      Map<String, dynamic> chapterData = Map<String, dynamic>.from(data[childIdKey]);

      if (chapterData.containsKey(chapterCode)) {
        chapterData.remove(chapterCode);
        data[childIdKey] = chapterData;
        await prefs.setString('child_problems', jsonEncode(data));
        print('🧹 초기화 완료: childId=$childId, chapterCode=$chapterCode 기록 삭제');
      } else {
        print('ℹ️ 해당 챕터 기록 없음: childId=$childId, chapterCode=$chapterCode');
      }
    } else {
      print('ℹ️ 해당 아이 기록 없음: childId=$childId');
    }
  }

}