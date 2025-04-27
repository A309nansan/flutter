import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/shared/widgets/toase_message.dart';

import '../../../../shared/widgets/problem_dialog.dart';
import '../models/en_category_model.dart';

class EnChapterListItem extends StatelessWidget {
  final EnCategoryModel listItem;
  final int level;
  final int childId;

  const EnChapterListItem({
    super.key,
    required this.listItem,
    required this.level,
    required this.childId,
  });

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Card(
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Hero(
                tag: '${listItem.id}',
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(60),
                          blurRadius: 5,
                          spreadRadius: 1,
                          offset: const Offset(4, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        listItem.imagePath,
                        height: screenHeight * 0.15,
                        width: screenWidth * 0.3,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: double.infinity,
                  width: double.maxFinite,
                  padding: const EdgeInsets.only(
                    top: 20,
                    bottom: 15,
                    left: 20,
                    right: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            listItem.name,
                            style: TextStyle(
                              fontSize: screenWidth * 0.025,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        "📌 활동목표",
                        style: TextStyle(
                          fontSize: screenWidth * 0.02,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 5),
                      Container(
                        height: screenHeight * 0.05,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "${listItem.description}",
                          style: TextStyle(
                            fontSize: screenWidth * 0.019,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: screenHeight * 0.03,
                              child: ElevatedButton(
                                onPressed: () {
                                  ToastMessage.show("문제집 준비중입니다!");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFFAE1),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 3,
                                ),
                                child: Text(
                                  "교사와 함께하기",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.015,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: SizedBox(
                              height: screenHeight * 0.03,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final problemCode = listItem.problemCode;

                                  await ProblemDialog.showProblemDialog(context, problemCode, childId, level);
                                },
                                //   onPressed: () {
                                //   var problemCode = listItem.problemCode;
                                //
                                //   final route = '/level$level/enlv2s1c2jy2';
                                //   // final route = '/level2/enlv2s1c1gn1';
                                //   // Modular.to.pushNamed(route);
                                //   Modular.to.pushNamed(route, arguments: 'enlv2s1c2jy2');
                                // },
                                // onPressed: () {
                                //   var problemCode = listItem.problemCode;
                                //   debugPrint('$level');

                                //   final route = '/level$level/enlv2s1c2jy1';
                                //   // final route = '/level2/enlv2s1c1gn1';
                                //   // Modular.to.pushNamed(route);
                                //   Modular.to.pushNamed(
                                //     route,
                                //     arguments: 'enlv2s1c2jy1',
                                //   );
                                // },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFFAE1),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 3,
                                ),
                                child: Text(
                                  "혼자 학습하기",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.015,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
