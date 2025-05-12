import 'package:flutter/material.dart';

class BoxWithLineWidget extends StatefulWidget {
  final void Function(int selectedValue)? onSelected;
  final double screenWidth;
  final double screenHeight;
  final List data;

  const BoxWithLineWidget({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.data,
    this.onSelected,
  });

  @override
  State<BoxWithLineWidget> createState() => _BoxWithLineWidgetState();
}

class _BoxWithLineWidgetState extends State<BoxWithLineWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: widget.screenWidth * 0.3,
              height: widget.screenHeight * 0.15,
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.lightBlue),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(width: widget.screenWidth * 0.1),
            Container(
              width: widget.screenWidth * 0.3,
              height: widget.screenHeight * 0.15,
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.lightBlue),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
        SizedBox(
          width: widget.screenWidth * 0.7,
          height: widget.screenHeight * 0.04,
          child: Stack(
            children: [
              Positioned(
                left: widget.screenWidth * 0.15,
                top: 0,
                bottom: 0,
                child: Container(
                  width: widget.screenHeight * 0.002,
                  color: Colors.red,
                ),
              ),
              Positioned(
                right: widget.screenWidth * 0.15,
                top: 0,
                bottom: 0,
                child: Container(
                  width: widget.screenHeight * 0.002,
                  color: Colors.red,
                ),
              ),
              Positioned(
                right: 0,
                top: widget.screenHeight * 0.02,
                child: Container(
                  width: widget.screenWidth * 0.7,
                  height: widget.screenHeight * 0.002,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (widget.onSelected != null)
                  widget.onSelected!(widget.data[0]);
                // setState()로 상태 변경 가능
              },
              child: Container(
                alignment: Alignment.center,
                width: widget.screenWidth * 0.3,
                height: widget.screenHeight * 0.1,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlue),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.data[0]}',
                  style: TextStyle(fontSize: widget.screenHeight * 0.06),
                ),
              ),
            ),
            SizedBox(width: widget.screenWidth * 0.1),
            GestureDetector(
              onTap: () {
                if (widget.onSelected != null)
                  widget.onSelected!(widget.data[1]);
                // setState()로 상태 변경 가능
              },
              child: Container(
                alignment: Alignment.center,
                width: widget.screenWidth * 0.3,
                height: widget.screenHeight * 0.1,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlue),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.data[1]}',
                  style: TextStyle(fontSize: widget.screenHeight * 0.06),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
