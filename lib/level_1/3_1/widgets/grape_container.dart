import 'package:flutter/material.dart';
import 'package:nansan_flutter/shared/digit_recognition/widgets/handwriting_recognition_zone.dart';

class GrapeContainer extends StatelessWidget {
  final int ans;
  final GlobalKey<HandwritingRecognitionZoneState>? zoneKey;

  const GrapeContainer({
    super.key,
    required this.ans,
    this.zoneKey,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double containerWidth = screenWidth * 0.8;

    Widget topImage = Container(
      width: screenHeight * 0.17 - 16,
      height: screenHeight * 0.17 - 16,
      child: Image.asset(
        'assets/images/number/grape/$ans.png',
        fit: BoxFit.scaleDown,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              'Image $ans',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );

    Widget boxContent;

    if (zoneKey != null) {
      boxContent = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: HandwritingRecognitionZone(
          key: zoneKey,
          width: 100,
          height: 100,
        ),
      );
    } else {
      boxContent = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          width: 100,
          height: 100,
          child: Text(
            ans.toString(),
            style: const TextStyle(fontSize: 60),
          ),
        ),
      );
    }

    return Container(
      width: containerWidth,
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          topImage,
          SizedBox(width: 10),
          boxContent,
        ],
      ),
    );
  }
}
