// import 'package:flutter/material.dart';
//
// class MLectureStatsScreen extends StatelessWidget {
//   const MLectureStatsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.centerRight,
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.7,
//         height: double.infinity * 0.8,
//         // color: Colors.white,
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               '📊 풀이 기록',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             const Text("여기에 문제 풀이 기록이 들어갑니다."),
//             const Spacer(),
//             Align(
//               alignment: Alignment.bottomRight,
//               child: TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text("닫기"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }