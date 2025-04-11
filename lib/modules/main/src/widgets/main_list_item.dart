import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/main/src/models/en_category_model.dart';
import 'package:nansan_flutter/shared/widgets/toase_message.dart';

class MainListItem extends StatelessWidget {
  final EnCategoryModel category;
  final double scale;

  const MainListItem({super.key, required this.category, required this.scale});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return ElevatedButton(
      onPressed: () {
        switch (category.id) {
          case 1:
            Modular.to.pushNamed("/main/category-list", arguments: category.id);
            break;
          case 2:
            Modular.to.pushNamed(
              "/main/m-category-list",
              arguments: category.id,
            );
            break;
          default:
              Modular.to.pushNamed(
                  '/math/m-random-defence',
                  arguments: {
                  }
              );
            break;
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 249, 241, 196),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        elevation: 5,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              category.imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              cacheWidth: 1000,
              cacheHeight: 600,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Color(0xFFCAAF82)),
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withAlpha(0),
                    Colors.white.withAlpha(128),
                    Colors.white.withAlpha(192),
                    Colors.white.withAlpha(255),
                  ],
                  stops: [0.0, 0.65, 0.75, 1.0],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9c6a17),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_right_rounded,
                            size: screenWidth * 0.035,
                            color: Color(0xFF9c6a17),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
