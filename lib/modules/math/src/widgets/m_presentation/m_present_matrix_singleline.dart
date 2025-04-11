import 'package:flutter/material.dart';

import '../../utils/math_ui_constant.dart';

class MPresentMatrixSingleline extends StatelessWidget {
  final List<List<String>> gridData;
  final Color textColor;

  const MPresentMatrixSingleline({
    super.key,
    required this.gridData,

    this.textColor = MathUIConstant.blackFontColor,
  });

  @override
  Widget build(BuildContext context) {
    double wSize = MathUIConstant.wSize * 0.66;
    double hSize = MathUIConstant.hSize;
    double fSize = MathUIConstant.fSize;
    int rowCount = gridData.length;
    int colCount = rowCount > 0 ? gridData[0].length : 0;

    return Column(
      children: List.generate(rowCount, (rowIndex) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(colCount, (colIndex) {
            String char = gridData[rowIndex][colIndex];

            return Container(
              width: char == " " ? wSize / 2 : wSize,
              height: hSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.transparent, // 공백일 때 배경색 변경
              ),
              child: Text(
                char == "-1" ? "" : char,
                style: TextStyle(
                  fontSize: fSize,
                  fontWeight: FontWeight.bold,
                  color: textColor, // 'x'는 빨간색
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}
