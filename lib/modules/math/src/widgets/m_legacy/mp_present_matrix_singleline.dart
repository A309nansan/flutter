import 'package:flutter/material.dart';

class MPPresentMatrixSingleline extends StatelessWidget {
  final List<List<String>> gridData;
  final double wSize;
  final double hSize;
  final double fSize;
  final Color textColor;
  const MPPresentMatrixSingleline({
    super.key,
    required this.gridData,
    this.wSize = 100,
    this.hSize = 150,
    this.fSize = 90,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
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
                color: Colors.white, // 공백일 때 배경색 변경
              ),
              child: Text(
                char,
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
