import 'package:flutter/material.dart';
import 'package:nansan_flutter/modules/math/src/utils/math_ui_constant.dart';

import '../utils/math_basic.dart';

class IndexPresenter extends StatelessWidget {
  final int indexLabel;

  const IndexPresenter({super.key, required this.indexLabel});

  @override
  Widget build(BuildContext context) {
    // 연보라색(파스텔 보라) 예시 컬러
    const Color pastelPurple = Color(0xFFD8B4FE);

    return Container(
      // 적절한 크기를 주어 원 형태가 보이도록 조절합니다.
      width: MathUIConstant.indexIconSize,
      height: MathUIConstant.indexIconSize,
      decoration: BoxDecoration(color: pastelPurple, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        addPaddingToNumber(indexLabel),
        style: TextStyle(
          fontSize: MathUIConstant.indexIconFontSize,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
