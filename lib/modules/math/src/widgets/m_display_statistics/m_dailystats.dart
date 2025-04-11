import 'package:flutter/material.dart';
import '../../../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
import '../../services/m_problem_manager.dart';
import 'm_dailystats_subwidget.dart';

class MDailyStats extends StatefulWidget {
  final String dateKey;
  final List<Map<String, dynamic>> problems;
  final int categoryIndex;
  final int parentCategory;
  final int childCategory;
  final MProblemManager problemManager;

  const MDailyStats({
    super.key,
    required this.dateKey,
    required this.problems,
    required this.categoryIndex,
    required this.parentCategory,
    required this.childCategory,
    required this.problemManager,
  });

  @override
  State<MDailyStats> createState() => _MDailyStatsState();
}

class _MDailyStatsState extends State<MDailyStats> {
  final Map<String, GlobalKey<HandwritingRecognitionZoneState>> _drawingKeys = {};
  final Map<String, bool> _drawingEnabledMap = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.problems.asMap().entries.map((entry) {
        final index = entry.key;
        final problem = entry.value;
        final mapKey = '${widget.dateKey}_$index';

        _drawingKeys.putIfAbsent(mapKey, () => GlobalKey<HandwritingRecognitionZoneState>());
        _drawingEnabledMap.putIfAbsent(mapKey, () => false);

        final bundle = widget.problemManager.loadLite(
          widget.parentCategory,
          widget.childCategory,
          problem["problemNumber"],
          widget.categoryIndex,
          problem,
        );

        return MProblemStatTile(
          index: index,
          mapKey: mapKey,
          problem: problem,
          problemBundle: bundle,
          categoryIndex: widget.categoryIndex
        );
      }).toList(),
    );
  }
}
