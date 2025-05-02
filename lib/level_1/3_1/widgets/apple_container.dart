import 'package:flutter/material.dart';
import 'package:nansan_flutter/shared/digit_recognition/widgets/handwriting_recognition_zone.dart';

class AppleContainer extends StatelessWidget {
  final int image;
  final int box;
  final Map<String, GlobalKey<HandwritingRecognitionZoneState>> zoneKey;

  const AppleContainer({
    super.key,
    required this.image,
    required this.box,
    required this.zoneKey,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth * 0.4;

    Widget topImage = Container(
      width: screenWidth * 0.4 - 166,
      height: screenWidth * 0.4 - 166,
      child: Image.asset(
        'assets/images/number/apple/$image.png',
        fit: BoxFit.scaleDown,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              'Image $image',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );

    Widget boxContent;
    if (box == 0) {
      final key = '${image.toString()}-$box';
      final handwritingZoneKey = zoneKey[key];

      boxContent = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: HandwritingRecognitionZone(
          key: handwritingZoneKey,
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
            box.toString(),
            style: const TextStyle(fontSize: 60),
          ),
        ),
      );
    }

    return Container(
      width: containerWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.lightBlue, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
