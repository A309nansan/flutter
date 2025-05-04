import 'package:flutter/material.dart';

class ClickableWidget123Main2 extends StatefulWidget {
  const ClickableWidget123Main2({
    super.key,
    required this.problemNum,
    required this.identifier, // 추가: 고유 식별자 (p1, p2, p3)
    required this.onClickCountChanged, // 추가: 클릭 카운트 변경 콜백 함수
  });

  final String problemNum;
  final String identifier; // 위젯 식별자 (p1, p2, p3)
  final Function(String, int) onClickCountChanged; // 클릭 카운트 변경 시 호출될 콜백

  @override
  State createState() => _ClickableWidget123Main2State();
}

class _ClickableWidget123Main2State extends State<ClickableWidget123Main2> {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      width: screenWidth * 0.2,
      height: screenHeight * 0.35,
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                width: screenHeight * 0.04,
                height: screenHeight * 0.04,
                child: Center(
                  child: Text(
                    "${widget.problemNum}",
                    style: TextStyle(
                        fontSize: screenHeight * 0.03,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                children: List.generate(2, (colIndex) {
                  return Column(
                    children: List.generate(5, (rowIndex) {
                      int index = colIndex * 5 + rowIndex; // 0~9 인덱스 계산
                      return GestureDetector(
                        onTap: () => handleContainerClick(index),
                        child: Container(
                          alignment: Alignment.center,
                          width: screenWidth * 0.1,
                          height: screenHeight * 0.06,
                          decoration: BoxDecoration(
                            color: containerStates[index] ? Color(0xFFFef1c4) : null, // ✅ 선택되면 빨간색 배경
                            border: Border.all(
                                width: 1,
                                color: Color(0xFF9c6a17)
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
