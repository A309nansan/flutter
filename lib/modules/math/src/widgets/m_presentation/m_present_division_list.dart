import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nansan_flutter/modules/math/src/widgets/m_presentation/progress_divider.dart';

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
      child:Stack(
        alignment: Alignment.bottomLeft,
        children:[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              SizedBox(width: wSize),
              Column(
                children:[
                  Opacity(
                    opacity: 0.75,
                    child:                  Image.asset(
                      'assets/images/basa_math/division.png', // 📁 assets/example.png 이미지가 있어야 함
                      width: hSize*0.8,
                      height: hSize*0.95,
                      fit: BoxFit.cover, // 이미지가 지정 영역을 꽉 채우도록
                    ),
                  ),

                  SizedBox(height: hSize*0.15),
                ]
              ),

              ProgressDivider(
                wCount: 1.4,
                isDivision: true,
              ),

              // 2. 수평선 (위쪽에 위치)
            ]
          ),
          Row(
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
                SizedBox(width:wSize * 0.3),
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
        ]
      )
    );
  }
}
