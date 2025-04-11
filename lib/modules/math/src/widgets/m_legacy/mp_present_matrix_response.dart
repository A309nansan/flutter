// import 'package:flutter/material.dart';
//
// import '../../utils/math_basic.dart';
//
// class MPPresentMatrixResponse extends StatelessWidget {
//   final List<List<String>> gridData;
//
//   const MPPresentMatrixResponse({
//     Key? key,
//     required this.gridData,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     int rowCount = gridData.length;
//     int colCount = rowCount > 0 ? gridData[0].length : 0;
//
//     return Column(
//       children: List.generate(rowCount, (rowIndex) {
//         return Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(colCount, (colIndex) {
//             String char = ansConvert(gridData[rowIndex][colIndex]);
//
//             return Container(
//               width: 80,
//               height: 80,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: Colors.white, // 공백일 때 배경색 변경
//               ),
//               child: Text(
//                 char,
//                 style: TextStyle(
//                   fontSize: 40,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black, // 'x'는 빨간색
//                 ),
//               ),
//             );
//           }),
//         );
//       }),
//     );
//   }
// }
