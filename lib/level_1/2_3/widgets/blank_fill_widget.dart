import 'package:flutter/material.dart';
import 'package:nansan_flutter/shared/digit_recognition/widgets/handwriting_recognition_zone.dart';

class BlankFillWidget extends StatefulWidget {
  final int ans;
  final String? answerKey;
  final Map<String, GlobalKey<HandwritingRecognitionZoneState>>? zoneKeys;
  final Map<String, dynamic>? selectedAnswers;

  const BlankFillWidget({
    super.key,
    required this.ans,
    this.answerKey,
    this.zoneKeys,
    this.selectedAnswers,
  });

  @override
  State<BlankFillWidget> createState() => _BlankFillWidgetState();
}

class _BlankFillWidgetState extends State<BlankFillWidget> {
  static const int rowCount = 2;
  static const int colCount = 5;
  static const int cellCount = rowCount * colCount;

  GlobalKey<HandwritingRecognitionZoneState>? zoneKey;
  List<bool> selectedCells = List.generate(cellCount, (_) => false);
  int selectedCount = 0;

  bool get isInteractive => widget.zoneKeys != null && widget.answerKey != null;

  @override
  void initState() {
    super.initState();

    if (isInteractive) {
      zoneKey = widget.zoneKeys!.putIfAbsent(
        widget.answerKey!,
            () => GlobalKey<HandwritingRecognitionZoneState>(),
      );
    } else {
      selectedCount = widget.ans.clamp(0, cellCount);
      selectedCells = List.generate(cellCount, (i) => i < selectedCount);
    }
  }

  void toggleCell(int index) {
    if (!isInteractive) return;

    setState(() {
      selectedCells[index] = !selectedCells[index];
      widget.selectedAnswers![widget.answerKey][1] += selectedCells[index] ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double containerWidth = screenWidth * 0.3;
    double gridMaxHeight = screenHeight * 0.08;

    Widget handwritingZone = isInteractive
        ? HandwritingRecognitionZone(
      key: zoneKey,
      width: screenWidth * 0.12,
      height: screenWidth * 0.12,
      backgroundColor: Colors.white,
    )
        : Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      width: screenWidth * 0.12,
      height: screenWidth * 0.12,
      child: Text(
        widget.ans.toString(),
        style: TextStyle(fontSize: containerWidth * 0.3),
      ),
    );

    Widget blankGrid = Container(
      width: containerWidth - 32,
      height: gridMaxHeight,
      child: Table(
        border: TableBorder.all(color: Colors.black),
        children: List.generate(rowCount, (row) {
          return TableRow(
            children: List.generate(colCount, (col) {
              int index = row * colCount + col;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isInteractive ? () => toggleCell(index) : null,
                  child: Container(
                    color: Colors.white,
                    height: gridMaxHeight / rowCount,
                    alignment: Alignment.center,
                    child: selectedCells[index]
                        ? Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    )
                        : null,
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );

    return Container(
      width: containerWidth,
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.end,children: [Text('1 큰 수', style: TextStyle(fontSize: containerWidth * 0.1, fontWeight: FontWeight.bold)), Icon(Icons.arrow_right_alt, size: containerWidth * 0.15,)],),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.lightBlue[100],
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                handwritingZone,
                SizedBox(height: containerWidth * 0.05),
                blankGrid,
              ],
            ),
          ),
          SizedBox(height: containerWidth * 0.05,)
        ],
      ),
    );
  }
}
