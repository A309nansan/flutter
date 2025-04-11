import 'package:flutter/material.dart';

class ClickableContainer extends StatefulWidget {
  final List<int> numberList;
  const ClickableContainer({super.key, required this.numberList});

  @override
  ClickableContainerState createState() => ClickableContainerState();
}

class ClickableContainerState extends State<ClickableContainer> {
  // 각 컨테이너의 상태를 저장할 리스트
  List<bool> isClicked = [false, false]; // 각 컨테이너의 클릭 상태 관리

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 첫 번째 컨테이너
        Container(
          width: 100,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.amber.shade200,
            border: Border.all(width: 1, color: Colors.black),
          ),
          alignment: Alignment.center,
          child: Text(
            '${widget.numberList[0]}',
            style: TextStyle(fontSize: 25),
          ),
        ),
        // 첫 번째 GestureDetector
        GestureDetector(
          onTap: () {
            setState(() {
              isClicked = [true, false, false];
            });
          },
          child: Container(
            width: 100,
            height: 50,
            decoration: BoxDecoration(
              color:
                  isClicked[0]
                      ? Colors.lightBlue.shade200
                      : Colors.amber.shade200,
              border: Border.all(width: 1, color: Colors.black),
            ),
            alignment: Alignment.center,
            child: Text(
              isClicked[0] ? 'O' : '',
              style: TextStyle(fontSize: 25),
            ),
          ),
        ),
        // 두 번째 컨테이너
        Container(
          width: 100,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.amber.shade200,
            border: Border.all(width: 1, color: Colors.black),
          ),
          alignment: Alignment.center,
          child: Text(
            '${widget.numberList[1]}',
            style: TextStyle(fontSize: 25),
          ),
        ),
        // 두 번째 GestureDetector
        GestureDetector(
          onTap: () {
            setState(() {
              isClicked = [false, true];
            });
          },
          child: Container(
            width: 100,
            height: 50,
            decoration: BoxDecoration(
              color:
                  isClicked[1]
                      ? Colors.lightBlue.shade200
                      : Colors.amber.shade200,
              border: Border.all(width: 1, color: Colors.black),
            ),
            alignment: Alignment.center,
            child: Text(
              isClicked[1] ? 'O' : '',
              style: TextStyle(fontSize: 25),
            ),
          ),
        ),
        // 세 번째 컨테이너
        Container(
          width: 100,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.amber.shade200,
            border: Border.all(width: 1, color: Colors.black),
          ),
          alignment: Alignment.center,
          child: Text(
            '${widget.numberList[2]}',
            style: TextStyle(fontSize: 25),
          ),
        ),
      ],
    );
  }
}
