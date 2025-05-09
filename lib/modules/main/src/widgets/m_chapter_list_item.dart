import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../math/src/utils/math_hardcoder.dart';
import '../models/en_category_model.dart';

class MChapterListItem extends StatelessWidget {
  final EnCategoryModel listItem;
  final int childId;
  const MChapterListItem({super.key, required this.listItem, required this.childId});

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
                  padding: const EdgeInsets.only(top: 20, bottom: 15, left: 20, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          Text(
                            listItem.name,
                            style: TextStyle(
                              fontSize: screenWidth * 0.025,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),Container(
                            width: screenWidth * 0.05,
                            height: screenWidth * 0.05,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFDE7),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: Offset(0, screenWidth * 0.0025,),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.calendar_month_rounded),
                              color: Colors.grey[600],
                              iconSize: screenWidth * 0.025,
                              onPressed: () {
                                Modular.to.pushNamed(
                                  '/math/m-result',
                                  arguments: {
                                    "categoryIndex": idTranslate(listItem.id),
                                    "categoryName": listItem.name,
                                    "imageURL": listItem.imagePath,
                                    "categoryDescription": listItem.description,
                                    "childId": childId
                                  },
                                );
                              },
                            ),
                          ),
                        ]
                      ),
                      SizedBox(height: 15),
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
                      SizedBox(
                        height: screenHeight * 0.05,
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
                                  Modular.to.pushNamed(
                                      '/math/m-lecture',
                                      arguments: {
                                        "categoryIndex": idTranslate(listItem.id),
                                        "categoryName": listItem.name,
                                        "imageURL": listItem.imagePath,
                                        "categoryDescription": listItem.description,
                                        "childId": childId
                                      }
                                  );
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
                                onPressed: () {
                                  Modular.to.pushNamed(
                                      '/math/m-practice',
                                      arguments: {
                                        "categoryIndex": idTranslate(listItem.id),
                                        "categoryName": listItem.name,
                                        "imageURL": listItem.imagePath,
                                        "categoryDescription": listItem.description,
                                        "childId": childId,
                                      }
                                  );
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