import 'package:flutter/material.dart';

class ClickableWidget113 extends StatefulWidget {
  const ClickableWidget113({
    super.key,
    required this.imageUrl,
    required this.identifier, // 추가: 고유 식별자 (p1, p2, p3)
    required this.onClickCountChanged, // 추가: 클릭 카운트 변경 콜백 함수
  });

  final String imageUrl;
  final String identifier; // 위젯 식별자 (p1, p2, p3)
  final Function(String, int) onClickCountChanged; // 클릭 카운트 변경 시 호출될 콜백

  @override
  State createState() => _ClickableWidget113State();
}

class _ClickableWidget113State extends State<ClickableWidget113> {
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
    // 기존 빌드 메서드 코드 (변경 없음)
    return SizedBox(
      width: 600,
      height: 160,
      child: Column(
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 2, color: Colors.black),
                ),
                child: Image.network(widget.imageUrl),
              ),
              SizedBox(width: 30),
              Column(
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => handleContainerClick(index),
                        child: Container(
                          alignment: Alignment.center,
                          width: 50,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                          child:
                              containerStates[index]
                                  ? Text(
                                    'O',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                  : null,
                        ),
                      );
                    }),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => handleContainerClick(index + 5),
                        child: Container(
                          alignment: Alignment.center,
                          width: 50,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                          child:
                              containerStates[index + 5]
                                  ? Text(
                                    'O',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                  : null,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
