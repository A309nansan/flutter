// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_modular/flutter_modular.dart';
// import 'package:intl/intl.dart';
// import '../../../../shared/widgets/appbar_widget.dart';
//
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';
// import '../../../../shared/widgets/toase_message.dart';
// import '../services/basa_math_decoder.dart';
// import '../services/basa_math_encoder.dart';
// import '../services/basa_math_reporter.dart';
// import '../services/m_problem_manager.dart';
// import '../widgets/m_display_statistics/m_dailystats.dart';
// import '../widgets/m_display_statistics/m_dailystats_blank.dart';
//
// class MResultScreen extends StatefulWidget {
//   final int categoryIndex;
//   final String categoryName;
//   final String categoryDescription;
//   final String imageURL;
//
//   const MResultScreen({
//     super.key,
//     required this.categoryIndex,
//     required this.categoryName,
//     required this.categoryDescription,
//     required this.imageURL,
//   });
//
//   @override
//   State<MResultScreen> createState() => _MResultScreenState();
// }
//
// class _MResultScreenState extends State<MResultScreen> {
//   late DateTime _selectedDate = DateTime.now();
//   late final DateTime _lastDate;
//   late final DateTime _firstDate;
//   late final List<DateTime> _DateList;
//   Future<List<Map<String, dynamic>>>? _reportFuture;
//
//   final _bmDecode = BasaMathDecoder();
//   final _bmEncode = BasaMathEncoder();
//   late final MProblemManager _PM;
//
//   @override
//   void initState() {
//     super.initState();
//     _PM = MProblemManager(_bmDecode, _bmEncode);
//     _loadReports();
//   }
//   bool isLatestDay(){
//     return _selectedDate == _lastDate;
//   }
//   void _loadReports() {
//     var today = DateTime.now();
//     var yesterday = today.subtract(Duration(days:1));
//
//     if (_reportFuture != null) return;
//
//     _reportFuture = BasaMathReporter()
//         .fetchAPIData(widget.categoryIndex ~/ 100, widget.categoryIndex % 10)
//         .then((data) {
//       if (data.isNotEmpty) {
//         _lastDate = DateTime.parse(data.first["solvedDate"]);
//         _firstDate = DateTime.parse(data.last["solvedDate"]);
//         _DateList = data
//             .map((item) => DateTime.tryParse(item["solvedDate"] ?? ""))
//             .where((date) => date != null)
//             .cast<DateTime>()
//             .toList();
//       } else {
//         _lastDate = today;
//         _firstDate = yesterday;
//         _DateList = [];
//       }
//       _selectedDate = _lastDate;
//       return data;
//     });
//   }
//
//   void _changeDate(DateTime newDate) {
//     setState(() {
//       _selectedDate = newDate;
//     });
//   }
//
//   Widget _buildDateBar() {
//     var today = DateTime.now();
//     var yesterday = today.subtract(Duration(days:1));
//
//
//
//
//     return Padding(
//       padding: const EdgeInsets.all(12),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.arrow_back_ios),
//                 onPressed: () =>
//                     _changeDate(
//                         _selectedDate!.subtract(const Duration(days: 1))),
//               ),
//               SizedBox(width:10),
//               GestureDetector(
//                 onTap: () => _selectDataCalendar(context, _DateList, _selectedDate),
//                 child: Row(
//                   children: [
//                     Text(
//                       DateFormat('yyyy년 M월 d일').format(_selectedDate!),
//                       style: const TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(width:10),
//               IconButton(
//                 icon: const Icon(Icons.arrow_forward_ios),
//                 onPressed: _selectedDate!.isBefore(yesterday)
//                     ? () =>
//                     _changeDate(_selectedDate!.add(const Duration(days: 1)))
//                     : null, // 🚫 미래 이동 금지
//                 color: _selectedDate!.isBefore(today) ? null : Colors.grey[300],
//               ),
//             ],
//           ),
//           if (!isLatestDay())
//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton.icon(
//                 onPressed: () => _changeDate(_lastDate),
//                 icon: const Icon(Icons.redo),
//                 label: const Text("마지막 날짜로!"),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       // appBar: AppBar(title: const Text('문제 풀이 리포트')),
//       appBar: AppbarWidget(
//         title: const Text(
//           '문제 풀이 리포트',
//           style: TextStyle(
//             fontFamily: "SingleDay",
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.chevron_left, size: 40.0),
//           onPressed: () => Modular.to.pop(),
//         ),
//         isCenter: true,
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _reportFuture,
//         builder: (context, snapshot) {
//           if (_selectedDate == null ||
//               snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             return Center(child: Text("❌ 에러 발생: ${snapshot.error}"));
//           }
//
//           final selectedDateStr = DateFormat('yyyy-MM-dd').format(
//               _selectedDate!);
//           final allReports = snapshot.data!;
//           final dayReport = allReports.firstWhere(
//                 (report) => report["solvedDate"] == selectedDateStr,
//             orElse: () => {},
//           );
//           return Column(
//             children: [
//               _buildDateBar(),
//               const Divider(height: 1),
//               Expanded(
//                 child: Builder(
//                   builder: (context) {
//                     if (dayReport.isEmpty || dayReport["problems"] == null) {
//                       return const MDailyStatsBlank();
//                     }
//
//                     final problems = (dayReport["problems"] as List).cast<
//                         Map<String, dynamic>>();
//
//                     return SingleChildScrollView(
//                       child: MDailyStats(
//                         dateKey: selectedDateStr,
//                         problems: problems,
//                         problemManager: _PM,
//                         categoryIndex: widget.categoryIndex,
//                         parentCategory: widget.categoryIndex ~/ 100,
//                         childCategory: widget.categoryIndex % 10,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//   void _changeMonth(int offset) {
//     setState(() {
//       _selectedDate = DateTime(
//         _selectedDate!.year,
//         _selectedDate!.month + offset,
//       );
//     });
//   }
//
//   void _selectDataCalendar(BuildContext context, List<DateTime> DateList, DateTime selectedDate) {
//     showCupertinoDialog(
//       barrierDismissible: true,
//       context: context,
//       builder: (context) {
//         return SafeArea(
//           child: Center(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: Container(
//                 width: MediaQuery.of(context).size.width * 0.55,
//                 height: 550,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(15),
//                   color: Color.fromARGB(255, 249, 241, 196),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withAlpha(10),
//                       blurRadius: 5,
//                       spreadRadius: 5,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(children:[
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.arrow_left),
//                         onPressed: () => _changeMonth(-1),
//                       ),
//                       Text(
//                         DateFormat('yyyy년 M월', 'ko').format(selectedDate),
//                         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.arrow_right),
//                         onPressed: () => _changeMonth(1),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//
//                   Localizations.override(
//                     context: context,
//                     locale: const Locale('ko'), // ✅ 여기서만 한국어 적용
//                     child: Builder(
//                       builder: (context) => SfDateRangePicker(
//
//                         monthCellStyle: DateRangePickerMonthCellStyle(
//                           specialDatesDecoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Color.fromARGB(255, 249, 241, 196),
//                           ),
//                         ),
//                         monthViewSettings: DateRangePickerMonthViewSettings(
//                           dayFormat: 'EEE',
//                           specialDates: DateList,
//                         ),
//                         monthFormat: 'MMM',
//                         showNavigationArrow: true,
//
//                         headerStyle: const DateRangePickerHeaderStyle(
//                           textAlign: TextAlign.center,
//                           textStyle: TextStyle(
//                             fontSize: 25,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                           backgroundColor: Color.fromARGB(255, 249, 241, 196),
//                         ),
//                         //headerHeight: 80,
//                         headerHeight:0,
//                         view: DateRangePickerView.month,
//                         allowViewNavigation: true,
//                         backgroundColor: Colors.white,
//                         initialSelectedDate: _selectedDate,
//                         minDate: _firstDate,
//                         maxDate: _lastDate,
//                         selectionColor: const Color.fromARGB(255, 249, 241, 196),
//                         selectionTextStyle: const TextStyle(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20,
//                         ),
//                         selectionMode: DateRangePickerSelectionMode.single,
//                         confirmText: '완료',
//                         cancelText: '취소',
//                         onSubmit: (args) {
//                           if (args is DateTime) {
//                             if (args.isAfter(DateTime.now())) {
//                               ToastMessage.show("미래 날짜를 선택할 수 없습니다.");
//                             } else {
//                               _changeDate(args);
//                             }
//                           }
//                           Navigator.of(context).pop();
//                         },
//                         onCancel: () => Navigator.of(context).pop(),
//                         showActionButtons: true,
//                       ),
//                     ),
//                   ),
//                 ]),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
