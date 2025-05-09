import 'package:flutter/material.dart';
import 'package:nansan_flutter/shared/digit_recognition/widgets/handwriting_recognition_zone.dart';

class AppleContainer extends StatelessWidget {
  final int ans;
  final GlobalKey<HandwritingRecognitionZoneState>? zoneKey;

  const AppleContainer({super.key, required this.ans, this.zoneKey});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth * 0.4;

    Widget topImage = SizedBox(
      width: screenWidth * 0.4 - 166,
      height: screenWidth * 0.4 - 166,
      child: Image.asset(
        'assets/images/number/apple/$ans.png',
        fit: BoxFit.scaleDown,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text('Image $ans', style: TextStyle(color: Colors.white)),
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
          child: Text(ans.toString(), style: const TextStyle(fontSize: 60)),
        ),
      );
    }

    return Container(
      width: containerWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [topImage, SizedBox(width: 10), boxContent],
      ),
    );
  }
}
