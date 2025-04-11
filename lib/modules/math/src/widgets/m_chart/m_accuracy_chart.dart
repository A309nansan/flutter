// lib/modules/math/src/widgets/m_chart/m_accuracy_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MAccuracyChart extends StatelessWidget {
  final Map<String, dynamic> statsData;

  const MAccuracyChart({super.key, required this.statsData});

  @override
  Widget build(BuildContext context) {
    final sortedDates = statsData.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.7,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 110,
              minX: -0.2, // 왼쪽 살짝 여유
              maxX: sortedDates.length - 0.8, // 오른쪽 살짝 여유
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    minIncluded:false,
                    maxIncluded: false,
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
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
                    maxIncluded:false,
                    minIncluded:false,
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) => Text("${value.toStringAsFixed(0)}%", style: const TextStyle(fontSize: 12)),
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  spots: List.generate(sortedDates.length, (i) {
                    final date = sortedDates[i];
                    final correct = statsData[date]["correctCount"];
                    final total = (statsData[date]["times"] as List<int>).length;
                    final rate = total > 0 ? correct / total * 100 : 0.0;
                    return FlSpot(i.toDouble(), rate);
                  }),
                  barWidth: 2,
                  color: Colors.brown,
                  dotData: FlDotData(show: true),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
