// import 'dart:convert';
// import 'package:flutter/services.dart' show rootBundle;
//
// class NumPair {
//   final int num1;
//   final int num2;
//
//   NumPair({required this.num1, required this.num2});
//
//   factory NumPair.fromJson(Map<String, dynamic> json) {
//     return NumPair(
//       num1: json['num1'],
//       num2: json['num2'],
//     );
//   }
//
//   @override
//   String toString() => 'NumPair(num1: $num1, num2: $num2)';
// }
//
// class CategoryMapper {
//   List<NumPair> _data = [];
//
//   // JSON 파일 로드
//   Future<void> loadNumPairs() async {
//     final String jsonString =
//     await rootBundle.loadString('assets/jsons/m_example/sample_response.json');
//     final List<dynamic> jsonList = json.decode(jsonString);
//     _data = jsonList.map((e) => NumPair.fromJson(e)).toList();
//   }
//
//   // categoryIndex를 기반으로 NumPair 가져오기
//   NumPair? getNumPair(int categoryIndex) {
//     final int index = _convertCategoryIndexToListIndex(categoryIndex);
//     if (index >= 0 && index < _data.length) {
//       return _data[index];
//     }
//     return null;
//   }
//
//   // categoryIndex를 리스트 인덱스로 변환
//   int _convertCategoryIndexToListIndex(int categoryIndex) {
//     final hundreds = categoryIndex ~/ 100;
//     final units = categoryIndex % 100;
//     return (hundreds - 1) * 4 + (units - 1);
//   }
// }