import 'package:flutter/material.dart';

class Selection extends StatefulWidget {
  // Accepting the list of integers as a parameter
  final List<int> boxValues;

  const Selection({super.key, required this.boxValues});

  @override
  _SelectionState createState() => _SelectionState();
}

class _SelectionState extends State<Selection> {
  // Track the selected box index (-1 if no box is selected)
  int selectedBoxIndex = -1;

  // Function to handle box click
  void toggleBox(int index) {
    setState(() {
      // If the same box is clicked again, deselect it, otherwise select the clicked box
      selectedBoxIndex = selectedBoxIndex == index ? -1 : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ensure there are at least 4 boxValues to avoid index errors
    if (widget.boxValues.length < 4) {
      return Center(
        child: Text("Please provide at least 4 values for boxValues."),
      );
    }

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The sentence with the first value dynamically inserted
          Text(
            '사과 ${widget.boxValues[0]}개보다 1개 더 많은 사과의 수는',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Box 1 (clickable for the 2nd value in the list)
              GestureDetector(
                onTap: () => toggleBox(1),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: selectedBoxIndex == 1
                        ? Colors.green
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      selectedBoxIndex == 1 ? widget.boxValues[1].toString() : '',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              // Box 2 (clickable for the 3rd value in the list)
              GestureDetector(
                onTap: () => toggleBox(2),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: selectedBoxIndex == 2
                        ? Colors.green
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      selectedBoxIndex == 2 ? widget.boxValues[2].toString() : '',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              // Box 3 (clickable for the 4th value in the list)
              GestureDetector(
                onTap: () => toggleBox(3),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: selectedBoxIndex == 3
                        ? Colors.green
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      selectedBoxIndex == 3 ? widget.boxValues[3].toString() : '',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          // Continue the sentence with the clickable boxes values
          Text(
            '${widget.boxValues[1]}, ${widget.boxValues[2]}, ${widget.boxValues[3]} 입니다.',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
