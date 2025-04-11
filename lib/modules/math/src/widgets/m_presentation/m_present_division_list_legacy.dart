import 'dart:math';

import 'package:flutter/material.dart';

import '../../utils/math_ui_constant.dart';

class MPresentDivisionList extends StatelessWidget {
  final List<List<String>> gridData;
  final double? wSizeOverride;
  final double? hSizeOverride;
  final double? fSizeOverride;
  final Color? textColorOverride;
  const MPresentDivisionList({
    Key? key,
    required this.gridData,
    this.wSizeOverride,
    this.hSizeOverride,
    this.fSizeOverride,
    this.textColorOverride,
  }) : super(key: key);
  double get wSize => wSizeOverride ?? MathUIConstant.wSize;
  double get hSize => hSizeOverride ?? MathUIConstant.hSize;
  double get fSize => fSizeOverride ?? MathUIConstant.fSize;
  Color get textColor => textColorOverride ?? MathUIConstant.blackFontColor;
  @override
  Widget build(BuildContext context) {
    int rowCount = gridData.length;
    int colCount = rowCount > 0 ? gridData[0].length : 0;


    return Container(
      decoration: BoxDecoration(

        color: Colors.transparent, // 배경색 (필요에 따라 변경 가능)
        border: Border.all(
          color: MathUIConstant.boundaryTeal,
          width: 3, // 테두리 두께
        ),
        borderRadius: BorderRadius.circular(16), // 둥근 모서리
      ),
      child:Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: MathUIConstant.boundaryTeal,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              width: wSize,
              height: hSize,
              child: Center( // ✅ 중앙 정렬
                child: Text(
                  gridData[0][0],
                  style: TextStyle(
                    fontSize: fSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),

            CustomPaint(
              size: Size(20, hSize* 0.77),
              painter: CurvedBracketPainter(),
            ),

            //SizedBox(width:43),
            Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: MathUIConstant.boundaryTeal,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              width: wSize,
              height: hSize,
              child: Center( // ✅ 중앙 정렬
                child: Text(
                  gridData[0][2],
                  style: TextStyle(
                    fontSize: fSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),


            Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: MathUIConstant.boundaryTeal,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              width: wSize,
              height: hSize,
              child: Center( // ✅ 중앙 정렬
                child: Text(
                  gridData[0][3],
                  style: TextStyle(
                    fontSize: fSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),

          ]
      ),
    );
  }
}

class CurvedBracketPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  CurvedBracketPainter({this.color = MathUIConstant.blackFontColor, this.strokeWidth = 7});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();

    // ) 곡선
    path.moveTo(3, -20);
    path.quadraticBezierTo(size.width, size.height * 0.4, 0, size.height*0.8);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}