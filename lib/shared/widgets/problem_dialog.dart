import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/shared/services/en_problem_service.dart';

class ProblemDialog {
  static Future<void> showProblemDialog(
      BuildContext context,
      String? problemCode,
      int childId,
      int level,
      ) async {
    if (problemCode == null || problemCode.isEmpty) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('정보', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('해당 차시 문제를 준비중입니다.', style: TextStyle(fontSize: 17)),
          backgroundColor: Color(0xFFFFFBF4),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    final chapterCode = problemCode.substring(0, problemCode.length - 3);
    final exists = await EnProblemService.existsContinueProblem(chapterCode, childId);

    if (exists) {
      final savedProblemCode = await EnProblemService.loadContinueProblem(chapterCode, childId);

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('이어 학습', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('이전에 풀던 기록이 있어요!\n이어서 하시겠어요?', style: TextStyle(fontSize: 17)),
          backgroundColor: Color(0xFFFFFBF4),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (savedProblemCode != null) {
                  final route = '/level$level/$savedProblemCode';
                  Modular.to.pushNamed(route, arguments: savedProblemCode);
                }
              },
              child: const Text('이어하기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () async {
                await EnProblemService.clearChapterProblem(childId, chapterCode);
                Navigator.pop(context);
                final route = '/level$level/$problemCode';
                Modular.to.pushNamed(route, arguments: problemCode);
              },
              child: const Text('처음부터', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('학습 시작', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('문제 풀이를 시작할게요!', style: TextStyle(fontSize: 17)),
          backgroundColor: Color(0xFFFFFBF4),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                final route = '/level$level/$problemCode';
                Modular.to.pushNamed(route, arguments: problemCode);
              },
              child: const Text('시작하기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('다음에 하기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }
}
