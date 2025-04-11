import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../shared/widgets/appbar_widget.dart';
import '../../../shared/widgets/header_widget.dart';
import '../../../shared/widgets/question_text.dart';

class LevelTwoOneOneMain2 extends StatelessWidget {
  const LevelTwoOneOneMain2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(
        title: null,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 40.0),
          onPressed: () => Modular.to.pop(),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                SizedBox(height: 20),
                HeaderWidget(headerText: "주요학습활동"),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: QuestionTextWidget(
                          questionText: "10을 다양하게 갈라 봅시다.",
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.restart_alt_rounded, size: 30),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
