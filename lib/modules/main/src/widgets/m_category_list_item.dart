import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/position/gf_position.dart';
import '../models/en_category_model.dart';

class MCategoryListItem extends StatelessWidget {
  final EnCategoryModel listItem;
  final double scale;

  const MCategoryListItem({
    super.key,
    required this.listItem,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Modular.to.pushNamed(
          '/main/m-chapter-list',
          arguments: {
            "categoryIndex": listItem.id,
            "categoryName": listItem.name,
          },
        );
      },
      child: GFCard(
        padding: const EdgeInsets.only(bottom: 10),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        borderRadius: BorderRadius.circular(20),
        boxFit: BoxFit.cover,
        titlePosition: GFPosition.start,
        elevation: 5.0,
        title: GFListTile(
          padding: EdgeInsets.symmetric(vertical:screenHeight * 0.005),
          title: Text(
            listItem.name,
            style: TextStyle(
              fontSize: screenWidth * 0.025,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        image: Image.asset(
          listItem.imagePath,
          height: screenHeight * 0.15,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        showImage: true,
        color: Colors.white,
        content: Container(
          height: MediaQuery.of(context).size.height * 0.18,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(top: 30, left: 30, right: 20),
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "💡학습목표",
                  style: TextStyle(
                    fontSize: screenHeight * 0.013,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.width * 0.15,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Text(
                  listItem.description ?? '',
                  style: TextStyle(
                    fontSize: screenHeight * 0.01,
                    color: Colors.black87,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  height: screenHeight * 0.03,
                  width: screenWidth * 0.2,
                  // margin: const EdgeInsets.only(right: 20),
                  child: ElevatedButton(
                    onPressed: () {
                        Modular.to.pushNamed(
                          '/main/m-chapter-list',
                        arguments: {
                          "categoryIndex": listItem.id,
                          "categoryName": listItem.name,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFAE1),
                      foregroundColor: const Color.fromARGB(255, 249, 241, 196),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      elevation: 3,
                    ),
                    child: Text(
                      "학습하기",
                      style: TextStyle(
                        fontSize:  screenHeight * 0.01,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
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

