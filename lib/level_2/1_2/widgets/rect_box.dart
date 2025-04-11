import 'package:flutter/material.dart';

class RectBox extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const RectBox({
    super.key,
    this.width = 40,
    this.height = 40,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width + 4,
      height: height + 4,
      child: Stack(
        children: [
          // 입체감 - 그림자 면
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              margin: const EdgeInsets.only(left: 2, top: 2),
            ),
          ),
          // 본체
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(1, 2),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
