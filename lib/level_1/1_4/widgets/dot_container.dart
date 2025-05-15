import 'package:flutter/material.dart';
import 'package:nansan_flutter/shared/digit_recognition/widgets/handwriting_recognition_zone.dart';

class DotContainer extends StatelessWidget {
  final int ans;
  final GlobalKey<HandwritingRecognitionZoneState>? zoneKey;

  const DotContainer({
    super.key,
    required this.ans,
    this.zoneKey,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double containerWidth = screenWidth * 0.8;

    Widget buildImage(int ans) {
      return Container(
        width: screenHeight * 0.17 - 16,
        height: screenHeight * 0.17 - 16,
        child: Image.asset(
          'assets/images/number/dot/$ans.png',
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
    }

    Widget topImage = Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildImage(ans),
          buildImage(ans),
        ],
      ),
    );

    Widget boxContent;

    if (zoneKey != null) {
      boxContent = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: HandwritingRecognitionZone(
          key: zoneKey,
          width: screenWidth * 0.15,
          height: screenWidth * 0.15,
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
          width: screenWidth * 0.15,
          height: screenWidth * 0.15,
          child: Text(
            (ans * 2).toString(),
            style: const TextStyle(fontSize: 60),
          ),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none, // Allows overlap outside the Stack bounds
      children: [
        Container(
          width: containerWidth,
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          decoration: zoneKey == null
              ? BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.deepOrange, width: 2),
          )
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              topImage,
              const SizedBox(width: 10),
              boxContent,
            ],
          ),
        ),
        if (zoneKey == null)
          Positioned(
            top: -12, // Adjust as needed to control overlap depth
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: const Text(
                  '  <보기>  ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

  }
}
