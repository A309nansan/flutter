import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../utils/math_string_hardcoder.dart';
import '../utils/math_ui_constant.dart';

void showTutorialDialog(BuildContext context, bool isTeachingMode, int categoryIndex) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return _TutorialDialog(isTeachingMode, categoryIndex);
    },
  );
}

class _TutorialDialog extends StatefulWidget {
  final bool isTeachingMode;
  final int categoryIndex;

  const _TutorialDialog(this.isTeachingMode, this.categoryIndex, {Key? key}) : super(key: key);

  @override
  State<_TutorialDialog> createState() => _TutorialDialogState();
}
class _TutorialDialogState extends State<_TutorialDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _imagePaths = [
    'assets/images/basa_m_tutorial_1.png',
    'assets/images/basa_m_tutorial_2.png',
    'assets/images/basa_m_tutorial_3.png',
  ];

  final List<String> _descriptions = [
    "",
    "",
    "",
  ];
  final List<String> _markdowns = ["", "", ""];

  @override
  Widget build(BuildContext context) {
    if (widget.isTeachingMode && _imagePaths.length == 3) {
      _imagePaths.insert(0, "https://s3.nansan.site/nansan/problem/m-example/${widget.categoryIndex}.webp");
      _descriptions.insert(0, returnExplanation1(widget.categoryIndex));
      _markdowns.insert(0, returnExplanation2(widget.categoryIndex));
    }
    if (!widget.isTeachingMode && _imagePaths.length == 3) {
      _imagePaths.insert(0, "assets/images/basa_math/thinking_rabbit.png");
      _descriptions.insert(0, "스스로 문제를 풀어보세요!");
      _markdowns.insert(0, "");
    }

    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.all(8.0),
      content: SizedBox(
        width: MathUIConstant.dialogWidth,
        height: MathUIConstant.dialogHeight,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _imagePaths.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = (_pageController.page ?? 0.0) - index;
                        value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                      }
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: value,
                          child: child,
                        ),
                      );
                    },
                    child: widget.isTeachingMode && index == 0
                        ? Image.network(
                      _imagePaths[index],
                      fit: BoxFit.contain,
                    )
                        : Image.asset(
                      width: MathUIConstant.dialogWidth,
                      _imagePaths[index],
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            /// 🔸 설명 텍스트
            if (_descriptions[_currentPage] != "")Text(
              _descriptions[_currentPage],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            // const SizedBox(height: 12),
            // MarkdownBody(
            //   data: _markdowns[_currentPage],
            //   styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            //     p: const TextStyle(fontSize: 16),
            //   ),
            // ),
            const SizedBox(height: 20),
            /// 🔸 페이지 인디케이터
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_imagePaths.length, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Color(0xFFD8B4FE)
                        : Colors.grey[300],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('닫기'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
