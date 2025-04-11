import 'package:flutter/material.dart';

import '../../utils/math_basic.dart';
import '../../utils/math_ui_constant.dart';

class MPresentMatrix extends StatelessWidget {
  final List<List<String>> gridData;
  final String operator;

  const MPresentMatrix({
    super.key,
    required this.gridData,
    required this.operator,
  });
  double get wSize => MathUIConstant.wSize;
  double get hSize => MathUIConstant.hSize;
  double get fSize => MathUIConstant.fSize;
  double get opSize => MathUIConstant.opSize;
  Color get textColor => MathUIConstant.blackFontColor;
  @override
  Widget build(BuildContext context) {
    int rowCount = gridData.length;
    int colCount = rowCount > 0 ? gridData[0].length : 0;

    return IntrinsicWidth(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: MathUIConstant.boundaryTeal, width: 3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              children: [
                Text(
                  opConvert(operator),
                  style: TextStyle(fontSize: opSize, color: textColor),
                ),
                SizedBox(height: opSize * 0.3),
              ],
            ),
            SizedBox(width: wSize * 0.3),
            Column(
              children: List.generate(rowCount, (rowIndex) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: List.generate(colCount, (colIndex) {
                    String char = gridData[rowIndex][colIndex];

                    return Container(
                      width: wSize,
                      height: hSize,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: MathUIConstant.boundaryPurple,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          char == "-1" ? "" : char,
                          style: TextStyle(
                            fontSize: fSize,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
