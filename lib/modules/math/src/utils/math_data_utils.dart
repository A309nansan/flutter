import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

List<String> convertNumberMapToList(
  Map<String, dynamic> answerMap,
  String keyName,
  int lenList,
) {
  final Map<String, dynamic>? subMap = answerMap[keyName];
  List<String> digits = List.filled(lenList, "-1");

  if (subMap == null) return digits;

  final List<String> keys = ["one", "two", "three", "four", "five"];
  for (int i = 0; i < lenList && i < keys.length; i++) {
    final key = keys[i];
    final value = subMap[key];
    if (value != null) {
      digits[lenList - 1 - i] = value.toString();
    }
  }

  return digits;
}

Map<String, dynamic> convertListToNumberMap(List<String> list, int lenList) {
  final List<String> keys = ["one", "two", "three", "four", "five"];
  Map<String, dynamic> result = {};

  for (int i = 0; i < list.length && i < lenList && i < keys.length; i++) {
    final value = list[list.length - 1 - i]; // 오른쪽부터 매핑
    if (value != "-1" && value.trim().isNotEmpty) {
      result[keys[i]] = int.parse(value);
    }
  }
  return result;
}

String formatAnswer(int num1, int num2, String op) {
  if (op == "PLUS") return (num1 + num2).toString();
  if (op == "MIN") return (num1 - num2).toString();
  if (op == "MULT") return (num1 * num2).toString();
  if (op == "DIV") {
    if (num1 % num2 == 0) {
      return (num1 ~/ num2).toString();
    } else {
      return ("몫: ${num1 ~/ num2}, 나머지: ${num1 % num2}");
    }
  }
  return "";
}

String getRandomIntString() {
  final Random random = Random();
  // "" 또는 "1"~"9" 중 랜덤 선택
  int r = random.nextInt(10); // 0~9
  return r == 0 ? "" : r.toString();
}

List<List<List<String>>> generateOutput(List<int> MV) {
  List<List<String>> carry = [];
  List<List<String>> progress = [];
  List<List<String>> answer = [];
  for (int i = 0; i < MV[0]; i++) {
    carry.add(List.generate(MV[1], (_) => getRandomIntString()));
  }
  for (int i = 0; i < MV[2]; i++) {
    progress.add(List.generate(MV[3], (_) => getRandomIntString()));
  }
  for (int i = 0; i < MV[4]; i++) {
    answer.add(List.generate(MV[5], (_) => getRandomIntString()));
  }
  return [carry, progress, answer];
}

void debugPrintPrettify(Map<String, dynamic> map) {
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  String pretty = encoder.convert(map);
  debugPrint(pretty);
}

String todayDateOnly() {
  final now = DateTime.now();
  return "${now.year.toString().padLeft(4, '0')}-"
      "${now.month.toString().padLeft(2, '0')}-"
      "${now.day.toString().padLeft(2, '0')}";
}

Map<String, dynamic> toJsonCompatible(Map<String, dynamic> input) {
  Map<String, dynamic> result = {};

  input.forEach((key, value) {
    if (value is DateTime) {
      result[key] = value.toIso8601String(); // 날짜를 문자열로 변환
    } else if (value is Map<String, dynamic>) {
      result[key] = toJsonCompatible(value); // 재귀 처리
    } else {
      result[key] = value;
    }
  });

  return result;
}
