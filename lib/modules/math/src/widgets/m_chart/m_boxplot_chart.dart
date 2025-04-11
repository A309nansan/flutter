import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MBoxPlotChart extends StatelessWidget {
  final Map<String, dynamic> statsData;

  const MBoxPlotChart({Key? key, required this.statsData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedDates = statsData.keys.toList()..sort();
    // ✅ 모든 Q3 값을 수집
    final q3List = sortedDates.map((date) {
      final times = (statsData[date]["times"] as List<dynamic>).cast<int>();
      return times.isEmpty ? 0 : _percentile(times, 75);
    }).toList();

    final maxQ3 = q3List.isEmpty ? 10 : q3List.reduce((a, b) => a > b ? a : b);
    final adjustedMaxY = ((maxQ3 ) ~/ 5) * 5 + 5; // 5의 배수 올림 + 5 buffer

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(

        BarChartData(

          minY: 0.0,
          maxY: adjustedMaxY*1,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index < 0 || index >= sortedDates.length) return const SizedBox();
                  final dateStr = sortedDates[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(dateStr.substring(5), style: const TextStyle(fontSize: 12)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                minIncluded:true,
                maxIncluded:true,
                interval:5,
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  // 중복 제거 위해 소수점 제거 후 고유값만 표시
                  final shown = <int>{};
                  int intValue = value.toInt();
                  if (shown.contains(intValue)) return const SizedBox();
                  shown.add(intValue);
                  return Text('$intValue초');
                },
              ),
            ),

            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(color: Colors.black),    // 왼쪽 테두리 표시
              bottom: BorderSide(color: Colors.black),  // 아래 테두리 표시
              top: BorderSide.none,                     // 위쪽 제거
              right: BorderSide.none,                   // 오른쪽 제거
            ),
          ),
          barGroups: List.generate(sortedDates.length, (i) {
            final date = sortedDates[i];
            final times = (statsData[date]["times"] as List<dynamic>).cast<int>();
            if (times.isEmpty) return BarChartGroupData(x: i, barRods: []);

            times.sort();
            final min = times.first.toDouble();
            final max = times.last.toDouble();
            final q1 = _percentile(times, 25);
            final q3 = _percentile(times, 75);
            final median = _percentile(times, 50);

            return BarChartGroupData(
              groupVertically:true,
              x: i,
              barRods: [
                BarChartRodData(

                  fromY: q1,
                  toY: q3,
                  width: 12,
                  color: Colors.orange.shade200,
                  rodStackItems: [],
                  borderRadius: BorderRadius.circular(4),
                ),
                // 중앙값 (빨간 점)
                BarChartRodData(
                  fromY: median + 0.1,
                  toY: median -0.1,
                  width: 12,
                  //borderRadius:BorderRadius.circular(12),
                  color: Colors.red,
                  rodStackItems: [],
                ),
              ],
            );
          }),
        ),
      ),
    );
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
}