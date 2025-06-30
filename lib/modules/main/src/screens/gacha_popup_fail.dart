// lib/widgets/gacha_popup_fail.dart
import 'package:flutter/material.dart';

class GachaBoxFailPopup {
  static Future<void> show({
    required BuildContext context,
    required String message,
    String? subMessage,
    String? imageUrl,
  }) async {
    return showDialog(
      context: context,
      // ✨ Dialog 배경색을 연한 베이지색으로 변경 ✨
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF9EF), // 다이얼로그 전체 배경색
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: const BorderSide(color: Color(0xFFF0D8A6), width: 2), // 다이얼로그 테두리 추가 (선택 사항)
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✨ 이미지 컨테이너 (이미지 엣지를 깎는 효과) ✨
              Container(
                width: 400, // 이미지 컨테이너의 너비
                height: 400, // 이미지 컨테이너의 높이
                decoration: BoxDecoration(
                  // 이미지 컨테이너 자체는 투명하게 두거나, 필요에 따라 배경색 지정
                  borderRadius: BorderRadius.circular(20.0), // 이미지도 둥글게 보이는 효과
                  // border: Border.all(color: Colors.grey.shade300, width: 1.0), // 선택적 테두리
                ),
                clipBehavior: Clip.hardEdge, // ✨ 이 속성이 이미지를 컨테이너 밖으로 나가지 않도록 잘라줍니다.
                child: Image.asset(
                  imageUrl ?? 'assets/images/profile/question.png',
                  fit: BoxFit.cover, // 이미지가 컨테이너를 가득 채우면서 짤리도록
                ),
              ),

              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA26A13), // 텍스트 색상도 베이지 톤에 맞게 조정 (선택 사항)
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (subMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    subMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인', style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}