import 'package:flutter/material.dart';

import '../../utils/math_ui_constant.dart';

class ProgressDivider extends StatelessWidget {
  final double wCount;
  final bool isDivision;
  const ProgressDivider({
    super.key,
    required this.wCount,
    this.isDivision = false,
  });
  double get wSize => MathUIConstant.wSize;
  double get hSize => MathUIConstant.hSize;
  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        children: [
          //todo: 얘는 없어질수도 있음
          if (!isDivision) SizedBox(height: hSize * 0.1), // 간격 조정
          Align(
            alignment: Alignment.centerRight, // 오른쪽 기준 정렬
            child: Row(
              children: [
                Container(
                  width: wSize * wCount, // ✅ 선의 길이 (원하는 만큼 조정)
                  height:
                      isDivision ? MathUIConstant.divisorHeight : 2, // 선의 두께
                  //margin: const EdgeInsets.only(right: 50), // ✅ endIndent 효과
                  color:
                      isDivision
                          ? MathUIConstant.blackFontColor
                          : MathUIConstant.dividerColor,
                ),
                if (isDivision) SizedBox(width: wSize * 0.11),
              ],
            ),
          ),
          if (!isDivision) SizedBox(height: hSize * 0.1), // 간격 조정
        ],
      ),
    );
  }
}
