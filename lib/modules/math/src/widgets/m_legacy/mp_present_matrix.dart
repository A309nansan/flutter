import 'package:flutter/material.dart';

class MPPresentMatrix extends StatelessWidget {
  final List<List<String>> gridData;

  const MPPresentMatrix({super.key, required this.gridData});

  @override
  Widget build(BuildContext context) {
    int rowCount = gridData.length;
    int colCount = rowCount > 0 ? gridData[0].length : 0;

    return Row(
      children: [
        Text("asdf", style: TextStyle(fontSize: 80)),
        Column(
          children: List.generate(rowCount, (rowIndex) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(colCount, (colIndex) {
                String char = gridData[rowIndex][colIndex];

                return Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white, // 공백일 때 배경색 변경
                  ),
                  child: Text(
                    char,
                    style: TextStyle(
                      fontSize: 90,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // 'x'는 빨간색
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ],
    );
  }
}
