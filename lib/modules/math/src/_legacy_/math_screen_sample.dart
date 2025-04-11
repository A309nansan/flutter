// import 'package:flutter/material.dart';
// import '../models/math_paper_model.dart';
// import '../widgets/mproblem/m_legacy/m_problem.dart';
// import '../../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
//
// class MathScreenSample extends StatefulWidget {
//   final int paperID;
//   const MathScreenSample({Key? key, required this.paperID}) : super(key: key);
//
//   @override
//   _MathScreenSampleState createState() => _MathScreenSampleState();
// }
//
// class _MathScreenSampleState extends State<MathScreenSample> {
//   final GlobalKey<HandwritingRecognitionZoneState> _drawingZoneKey = GlobalKey();
//   late Future<MathPaperModel> _mathPaperFuture;
//   int currentPage = 0; // ✅ 현재 페이지 상태 저장
//
//   @override
//   void initState() {
//     super.initState();
//     _mathPaperFuture = loadMathPaperModel(); // 📌 문제 데이터 불러오기
//   }
//   void _updateResults(List<List<String>> result){
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Math Screen Sample',
//       home: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(title: const Text('Math Screen Sample')),
//         body: FutureBuilder<MathPaperModel>(
//           future: _mathPaperFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               return Center(child: Text('데이터 로드 실패: ${snapshot.error}'));
//             } else {
//               final mathPaper = snapshot.data!;
//               final problems = mathPaper.problems;
//
//               int totalPages = 0;
//               int index = 0;
//               List<List<MathProblem>> paginatedProblems = [];
//
//
//
//               totalPages = paginatedProblems.length;
//
//               final problemsToShow = paginatedProblems[currentPage];
//
//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: problemsToShow
//                           .map((problem) =>
//                           MProblem(
//                               problemData: problem,
//                               isTest: false,
//                               initialResults: [],
//                               onResultsUpdated: _updateResults,
//
//
//                           )
//                       )
//                           .toList(),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // 이전 페이지 버튼
//                         ElevatedButton(
//                           onPressed: currentPage > 0
//                               ? () => setState(() => currentPage--)
//                               : null,
//                           child: const Text("이전"),
//                         ),
//                         Text("페이지 ${currentPage + 1} / $totalPages"), // ✅ 페이지 표시
//                         // 다음 페이지 버튼
//                         ElevatedButton(
//                           onPressed: currentPage < totalPages - 1
//                               ? () => setState(() => currentPage++)
//                               : null,
//                           child: const Text("다음"),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
