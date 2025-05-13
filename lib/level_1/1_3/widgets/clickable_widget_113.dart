import 'package:flutter/material.dart';

class ClickableWidget extends StatefulWidget {
  const ClickableWidget({
    super.key,
    required this.identifier,
    required this.onClickCountChanged,
    required this.width,
    required this.height,
    required this.bgColor,
    required this.liColor,
    required this.textColor,
  });

  final String identifier;
  final Function(String, int) onClickCountChanged;
  // final int identifier;
  // final Function(int, int) onClickCountChanged;
  final double width;
  final double height;
  final Color bgColor;
  final Color liColor;
  final Color textColor;

  @override
  State createState() => _ClickableWidgetState();
}

class _ClickableWidgetState extends State<ClickableWidget> {
  // 클릭 횟수를 저장하는 변수
  int clickCount = 0;
  // 각 컨테이너의 상태를 저장하는 리스트
  List<bool> containerStates = List.generate(10, (index) => false);

  void handleContainerClick(int index) {
    setState(() {
      // 클릭 상태에 따라 처리
      if (containerStates[index]) {
        // 이미 클릭된 상태라면 다시 클릭 시 상태를 false로 변경하고 클릭 횟수 감소
        containerStates[index] = false;
        clickCount--;
      } else {
        // 클릭되지 않은 상태라면 상태를 true로 변경하고 클릭 횟수 증가
        containerStates[index] = true;
        clickCount++;
      }

      // 부모 위젯에 변경된 클릭 카운트 전달
      widget.onClickCountChanged(widget.identifier, clickCount);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width, // GridView에 맞게 너비 조정
      height: widget.height, // GridView에 맞게 높이 조정
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 2, color: widget.liColor),
          left: BorderSide(width: 2, color: widget.liColor),
          bottom: BorderSide(width: 2, color: widget.liColor),
        ),
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // 5개 열
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          childAspectRatio: 50 / 60, // 너비/높이 비율
        ),
        itemCount: 10,
        physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => handleContainerClick(index),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: widget.bgColor,
                border: Border(
                  right: BorderSide(width: 2, color: widget.liColor),
                  bottom: BorderSide(width: 2, color: widget.liColor),
                ),
              ),
              child:
                  containerStates[index]
                      ? Text(
                        'O',
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: widget.width * 0.1,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            ),
          );
        },
      ),
    );
  }
}
