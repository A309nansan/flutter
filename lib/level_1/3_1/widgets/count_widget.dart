import 'package:flutter/material.dart';
import 'package:nansan_flutter/shared/digit_recognition/widgets/handwriting_recognition_zone.dart';

class CountWidget extends StatefulWidget {
  final void Function(int selectedValue)? onSelected;
  final double screenWidth;
  final double screenHeight;
  final List data;
  final GlobalKey<HandwritingRecognitionZoneState> left;
  final GlobalKey<HandwritingRecognitionZoneState> right;

  const CountWidget({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.data,
    required this.left,
    required this.right,
    this.onSelected,
  });

  @override
  State<CountWidget> createState() => _CountWidgetState();
}

class _CountWidgetState extends State<CountWidget> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Just visual elements
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: widget.screenWidth * 0.15,
              height: widget.screenWidth * 0.15,
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.lightBlue),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/images/number/dot/${widget.data[0]}.png',
                fit: BoxFit.scaleDown,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      'Image ${widget.data[0]}',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: widget.screenWidth * 0.05),
            Container(
              width: widget.screenWidth * 0.15,
              height: widget.screenWidth * 0.15,
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.lightBlue),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/images/number/dot/${widget.data[1]}.png',
                fit: BoxFit.scaleDown,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      'Image ${widget.data[1]}',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        SizedBox(
          width: widget.screenWidth * 0.4,
          height: widget.screenHeight * 0.04,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Left vertical line
              Positioned(
                left: widget.screenWidth * 0.1,
                top: 0,
                bottom: 0,
                child: Container(
                  width: widget.screenHeight * 0.002,
                  color: Colors.red,
                ),
              ),
              // Right vertical line
              Positioned(
                right: widget.screenWidth * 0.1,
                top: 0,
                bottom: 0,
                child: Container(
                  width: widget.screenHeight * 0.002,
                  color: Colors.red,
                ),
              ),
              // Horizontal center line
              Positioned(
                top: widget.screenHeight * 0.02,
                child: Container(
                  width: widget.screenWidth * 0.4,
                  height: widget.screenHeight * 0.002,
                  color: Colors.red,
                ),
              ),
              // Left arrowhead
              Positioned(
                left: 0,
                top: widget.screenHeight * 0.02 - 4,
                child: Transform.rotate(
                  angle: -3.14 / 4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 2, color: Colors.red),
                        left: BorderSide(width: 2, color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ),
              // Right arrowhead
              Positioned(
                right: 0,
                top: widget.screenHeight * 0.02 - 4,
                child: Transform.rotate(
                  angle: 3.14 / 4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 2, color: Colors.red),
                        right: BorderSide(width: 2, color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Replace GestureDetector with handwriting zone
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HandwritingRecognitionZone(
              key: widget.left,
              width: widget.screenWidth * 0.15,
              height: widget.screenWidth * 0.15,
              // onRecognized: (value) {
              //   if (widget.onSelected != null) {
              //     widget.onSelected!(value);
              //   }
              // },
            ),
            SizedBox(width: widget.screenWidth * 0.05),
            HandwritingRecognitionZone(
              key: widget.right,
              width: widget.screenWidth * 0.15,
              height: widget.screenWidth * 0.15,
              // onRecognized: (value) {
              //   if (widget.onSelected != null) {
              //     widget.onSelected!(value);
              //   }
              // },
            ),
          ],
        ),
      ],
    );
  }
}
