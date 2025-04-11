import 'package:flutter/material.dart';
import 'package:nansan_flutter/modules/math/src/utils/math_ui_constant.dart';

import '../utils/math_basic.dart';

class IndexPresenterNew extends StatelessWidget {
  final int indexLabel;

  const IndexPresenterNew({Key? key, required this.indexLabel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 연보라색(파스텔 보라) 예시 컬러
    const Color pastelPurple = Color(0xFFD8B4FE);

    return Container(
      // 적절한 크기를 주어 원 형태가 보이도록 조절합니다.
      width: MathUIConstant.indexIconSize * 0.5,
      height: MathUIConstant.indexIconSize * 0.5,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        addPaddingToNumber(indexLabel),
        style: TextStyle(
          fontSize: MathUIConstant.indexIconFontSize * 0.5,
          color: MathUIConstant.blackFontColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
