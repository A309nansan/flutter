// import 'package:flutter/material.dart';
// import '../../../models/math_paper_model.dart';
//
// class MAnnouncement extends StatelessWidget {
//   final MathProblem problemData;
//
//   const MAnnouncement({Key? key, required this.problemData}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0), // ✅ 박스 주변 여백 추가
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.transparent, // ✅ 배경색 없음
//           border: Border.all(color: Colors.blue, width: 2.0), // ✅ 파란색 테두리
//           borderRadius: BorderRadius.circular(12.0), // ✅ 모서리를 둥글게
//         ),
//         padding: const EdgeInsets.all(12.0), // ✅ 내부 여백 추가
//         child: Text(
//           problemData.msg ?? "", // ✅ 메시지 표시 (null이면 빈 문자열)
//           style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.black),
//           textAlign: TextAlign.center, // ✅ 가운데 정렬
//         ),
//       ),
//     );
//   }
// }
