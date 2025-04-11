import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/math/src/widgets/m_chart/m_accuracy_chart.dart';
import 'package:nansan_flutter/modules/math/src/widgets/m_chart/m_boxplot_chart.dart';
import 'package:nansan_flutter/modules/math/src/widgets/m_chart/text_with_tooltip.dart';
import 'package:nansan_flutter/shared/widgets/appbar_widget.dart';

import '../widgets/m_chart/m_overview_chart.dart';

class MStatChartScreen extends StatelessWidget {
  final Map<String, dynamic> statsData; // 변환된 결과 하나
  final String categoryName;
  const MStatChartScreen({Key? key, required this.statsData, required this.categoryName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedDates = statsData.keys.toList()..sort();

    final allTimes = sortedDates
        .expand((date) => (statsData[date]["times"] as List<dynamic>).cast<int>())
        .toList();
    allTimes.sort();

    final totalQuestions = allTimes.length;
    final totalCorrect = sortedDates.fold<int>(0, (sum, date) => sum + (statsData[date]["correctCount"] as int));
    final overallAccuracy = totalQuestions > 0 ? (totalCorrect / totalQuestions * 100).toStringAsFixed(1) : "0";
    final totalTime = allTimes.fold<int>(0, (sum, t) => sum + t);
    final averageTime = totalQuestions > 0
        ? (allTimes.reduce((a, b) => a + b) / totalQuestions).toStringAsFixed(1)
        : "0.0";

    final medianTime = totalQuestions > 0
        ? _percentile(allTimes, 50).toStringAsFixed(1)
        : "0.0";
    return Scaffold(
    appBar: AppbarWidget(
        title: Text('$categoryName - report',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
    icon: const Icon(Icons.chevron_left, size: 40.0),
      onPressed: () {
          Modular.to.pop(); // 기본 pop
        },
    ),
    isCenter: true,),
    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 24), // 좌우 여백 크게
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          TextWithTooltip(
            text: "📊 전체 요약",
            title: "전체 통계",
            subtext: "모든 풀이 데이터를 기반으로 정확도와 시간 통계를 확인합니다.",
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("🎯 정답률", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                MOverviewChart(
                  totalQuestions: totalQuestions,
                  totalCorrect: totalCorrect,
                  overallAccuracy: overallAccuracy,
                ),
                const SizedBox(height: 24),
                const Text("🕒 시간 소요", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                MOverviewChart2(
                  totalTime: totalTime,
                  averageTime: averageTime,
                  medianTime: medianTime,
                ),
                const SizedBox(height: 40),
                const Text("🚨 실수 유형", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Wrap(
                    spacing: 8,
                    children: _buildErrorSummary(statsData),
                  ),
                ),
              ],
            ),
          ),



          const SizedBox(height: 40),
          TextWithTooltip(
            text: "📆 일간 통계",
            title: "날짜별 통계",
            subtext: "정답률과 풀이 시간의 변화를 날짜별로 확인할 수 있어요.",
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.lightBlue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.lightBlue.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("📈 날짜별 정답률" , style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child:MAccuracyChart(statsData: statsData),
                  ),

                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children:[
                    const Text("📈 날짜별 소요시간" , style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 30),
                    const Text("상위 75%, 50%, 25% 값을 표기합니다", style: TextStyle(fontSize: 14, color: Color(0xff666666))),
                  ]
                ),

                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child:MBoxPlotChart(statsData: statsData),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  List<Widget> _buildErrorSummary(Map<String, dynamic> statsData) {
    final Map<String, int> combinedErrorMap = {};
    for (final stat in statsData.values) {
      final errors = stat["errorCodes"] as Map<String, int>;
      for (final entry in errors.entries) {
        combinedErrorMap[entry.key] = (combinedErrorMap[entry.key] ?? 0) + entry.value;
      }
    }

    final sortedEntries = combinedErrorMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // 👈 빈도 내림차순 정렬

    return sortedEntries.map((e) => Chip(label: Text("${e.key}: ${e.value}"))).toList();
  }
}

double _percentile(List<int> list, double percentile) {
  if (list.isEmpty) return 0;
  list.sort();
  final rank = (percentile / 100.0) * (list.length - 1);
  final lower = rank.floor();
  final upper = rank.ceil();
  if (lower == upper) return list[lower].toDouble();
  final interp = rank - lower;
  return list[lower] * (1 - interp) + list[upper] * interp;
}