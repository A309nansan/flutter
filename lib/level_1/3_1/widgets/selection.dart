import 'package:flutter/material.dart';

class Selection extends StatefulWidget {
  final List<int> boxValues;
  final Function(int) onSelectionChanged; // Callback to send selected number to parent

  const Selection({super.key, required this.boxValues, required this.onSelectionChanged});

  @override
  _SelectionState createState() => _SelectionState();
}

class _SelectionState extends State<Selection> {
  int selectedBoxIndex = -1;

  void toggleBox(int index) {
    setState(() {
      selectedBoxIndex = selectedBoxIndex == index ? -1 : index;
    });
    // Call the callback with the selected number
    if (selectedBoxIndex != -1) {
      widget.onSelectionChanged(widget.boxValues[selectedBoxIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.boxValues.length < 4) {
      return Center(
        child: Text("Please provide at least 4 values for boxValues."),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 42.0), // Added padding here
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '사과 ${widget.boxValues[0]}개보다 1개 더 많은 사과의 수는',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => toggleBox(1),
                  child: CustomBox(
                    number: widget.boxValues[1],
                    isSelected: selectedBoxIndex == 1,
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () => toggleBox(2),
                  child: CustomBox(
                    number: widget.boxValues[2],
                    isSelected: selectedBoxIndex == 2,
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () => toggleBox(3),
                  child: CustomBox(
                    number: widget.boxValues[3],
                    isSelected: selectedBoxIndex == 3,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              '입니다.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomBox extends StatelessWidget {
  final int number;
  final bool isSelected;

  const CustomBox({super.key, required this.number, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey, // Blue when selected, gray otherwise
            width: 2,
          ),
        ),
        child: Text(
          number.toString(),
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
