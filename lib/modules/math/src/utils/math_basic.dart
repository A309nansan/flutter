import 'dart:math';

import 'package:flutter/material.dart';

String opConvert(String op) {
  if (op == "add" || op == "PLUS") return "＋";
  if (op == "sub" || op == "MIN") return "–";
  if (op == "mult" || op == "MULT")
    return "×";
  else
    return "÷";
}

String addPaddingToNumber(int x) {
  if (x < 10) return "0$x";
  return x.toString();
}

String ansConvert(String x) {
  if (x.isEmpty) return "-";
  if (x.contains("숫자")) return "?";

  return x;
}

List<List<String>> formatMathProblem(
  String num1,
  String num2,
  String op,
  int length,
) {
  // 숫자 앞에 공백 추가하여 길이에 맞추기
  List<String> row1 = List.filled(length - num1.length, " ") + num1.split('');
  List<String> row2 = List.filled(length - num2.length, " ") + num2.split('');

  return [row1, row2];
}

List<List<String>> toString2DArr(List<dynamic> target) {
  List<List<String>> result =
      target
          .map<List<String>>(
            (row) => row.map<String>((e) => e.toString()).toList(),
          )
          .toList();
  return result;
}

int getMatrixRows(int a, int b) {
  int x = max(a, b);
  String xStr = x.toString();
  return xStr.length;
}

void Arr2DPrinter(List<List<String>> x) {
  if (x.isEmpty) return;
  for (int i = 0; i < x.length; i++) {
    debugPrint(x[i].toString());
  }
}

void Arr3DPrinter(List<List<List<String>>> x) {
  debugPrint("CARRY:");
  Arr2DPrinter(x[0]);
  debugPrint("Calculate:");
  Arr2DPrinter(x[1]);
  debugPrint("ANSWER:");
  Arr2DPrinter(x[2]);
}

List<List<String>> generateDummyInts2D(int x, int y, String labelName) {
  return List.generate(x, (i) => List.generate(y, (j) => labelName));
}

List<List<List<String>>> generateDummyAnswer(
  int index,
  List<int> matrixVolume,
) {
  String dummy = (index % 10).toString();

  List<List<String>> carryDummy = generateDummyInts2D(
    matrixVolume[0],
    matrixVolume[1],
    dummy,
  );
  List<List<String>> progressDummy = generateDummyInts2D(
    matrixVolume[2],
    matrixVolume[3],
    dummy,
  );
  List<List<String>> ansDummy = generateDummyInts2D(
    matrixVolume[4],
    matrixVolume[5],
    dummy,
  );

  return [carryDummy, progressDummy, ansDummy];
}
