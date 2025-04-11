import 'package:flutter/material.dart';

class MOverviewChart extends StatelessWidget {
  final int totalQuestions;
  final int totalCorrect;
  final String overallAccuracy;

  const MOverviewChart({
    Key? key,
    required this.totalQuestions,
    required this.totalCorrect,
    required this.overallAccuracy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetric("총 문제 수", totalQuestions.toString()),
          _buildMetric("정답 수", totalCorrect.toString()),
          _buildMetric("정답률", "$overallAccuracy%"),
        ],
      ),
    );
  }

  Widget _buildMetric(String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class MOverviewChart2 extends StatelessWidget {
  final int totalTime;
  final String averageTime;
  final String medianTime;

  const MOverviewChart2({
    Key? key,
    required this.totalTime,
    required this.averageTime,
    required this.medianTime,
  }) : super(key: key);

  Widget _buildMetric(String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String totalMinutes = (totalTime ~/ 60).toString();
    String totalSeconds = (totalTime % 60).toString();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetric("총 소요시간", "$totalMinutes분 $totalSeconds초"),
          _buildMetric("평균 소요시간", averageTime + "초"),
          _buildMetric("중앙값", medianTime + "초"),
        ],
      ),
    );
  }
}