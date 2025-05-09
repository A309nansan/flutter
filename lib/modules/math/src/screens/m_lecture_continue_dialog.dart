
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../utils/math_ui_constant.dart';

Future<bool> showContinueDialog(
    int categoryIndex,
    String categoryName,
    String imageURL,
    String categoryDescription,
    bool isTeachingMode,
    int childId,
    BuildContext context,
    ) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,

    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                "assets/images/image3d/Bunny3D_${Random().nextInt(3) + 1}.webp", // 👈 1~3 중 랜덤
                height: MathUIConstant.hSize * 4,
                width: MathUIConstant.hSize * 4,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "문제 풀이 종료",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 12),
            const Text(
              "문제를 충분히 푸셨어요!\n돌아가시겠어요?",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen.shade100,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("계속 풀기"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("돌아가기"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Modular.to.pushNamed(
                    '/math/m-result',
                    arguments: {
                      "categoryIndex": categoryIndex,
                      "categoryName": categoryName,
                      "imageURL": imageURL,
                      "categoryDescription": categoryDescription,
                      "doublePopOnBack": true,
                      "childId": childId
                    },
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("결과보기"),
              ),
            ),
          ],
        ),
      );
    },
  ) ??
      false;

}