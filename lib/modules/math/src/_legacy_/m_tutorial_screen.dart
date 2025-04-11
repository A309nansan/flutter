import 'package:flutter/material.dart';

class MTutorialScreen extends StatelessWidget {
  final int categoryIndex;
  final String categoryName;

  const MTutorialScreen({
    super.key,
    required this.categoryIndex,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("튜토리얼"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "카테고리 인덱스: $categoryIndex",
              style: const TextStyle(
                fontSize: 24,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "카테고리 이름: $categoryName",
              style: const TextStyle(
                fontSize: 24,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}