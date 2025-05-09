import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../../shared/services/secure_storage_service.dart';
import '../../../../shared/widgets/appbar_widget.dart';
import '../../../../shared/widgets/en_list_splash_screen.dart';
import '../../../../shared/widgets/m_list_splash_screen.dart';
import '../../../math/src/services/basa_math_reporter.dart';
import '../../../math/src/utils/math_ui_constant.dart';
import '../models/en_category_model.dart';
import '../service/category_service.dart';
import '../widgets/m_chapter_list_item.dart';

class MChapterListScreen extends StatefulWidget {
  final int categoryIndex;
  final String categoryName;

  const MChapterListScreen({
    super.key,
    required this.categoryIndex,
    required this.categoryName,
  });

  @override
  State<MChapterListScreen> createState() => _MChapterListScreenState();
}

class _MChapterListScreenState extends State<MChapterListScreen> {
  List<EnCategoryModel> chapterList = [];
  bool isLoading = false;
  int childId = 0;
  Future<void> _prepareChildID() async{
    final childProfileJson = await SecureStorageService.getChildProfile();
    final childProfile = jsonDecode(childProfileJson!);
    childId = childProfile['id'];
  }
  @override
  void initState() {
    super.initState();
    setState(() => isLoading = true);
    _loadChapters();
    _prepareChildID();
    print(childId);
  }

  Future<void> _loadChapters() async {
    final result = await CategoryService.fetchCategories(widget.categoryIndex);
    setState(() {
      chapterList = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // ✅ MathUIConstant 초기화 (단 한 번만)

    return Scaffold(
      appBar: AppbarWidget(
        title: null,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 40.0),
          onPressed: () => Modular.to.pop(),
        ),
      ),
      body:
          isLoading
              ? MListSplashScreen()
              : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.90,
                      height: screenHeight * 0.13,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "사칙 연산(M)",
                              style: TextStyle(
                                fontFamily: "SingleDay",
                                fontSize: screenWidth * 0.065,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9C6A17),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:[
                                Text(
                                  widget.categoryName,
                                  style: TextStyle(
                                    fontFamily: "SingleDay",
                                    fontSize: screenWidth * 0.043,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF9C6A17),
                                  ),
                                ),
                                GestureDetector(
                                  //delete this shit later
                                  onTap: () async {
                                    setState((){
                                      isLoading = true;
                                    });
                                    final stats = await BasaMathReporter()
                                        .fetchHuge(
                                      childId,
                                      int.parse(widget.categoryName[0]),
                                    );
                                    setState((){
                                      isLoading = false;
                                    });
                                    Modular.to.pushNamed(
                                      "/math/m-statchart",
                                      arguments: {
                                        "stats": stats,
                                        "categoryName": widget.categoryName,
                                      },
                                    );
                                  }, //delete this shit later
                                  child: Container(
                                    margin: EdgeInsets.all(8),
                                    // decoration: BoxDecoration(
                                    //
                                    //   //color: Color.fromARGB(127, 249, 241, 196),
                                    //   borderRadius: BorderRadius.circular(10),
                                    //   border: Border.all(color: Colors.grey.withOpacity(0.4)),
                                    // ),
                                    child: Text(
                                      "전체통계 보기",
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.025,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF9C6A17),
                                      ),
                                    ),
                                  )
                                ),
                              ]
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: chapterList.length,
                        itemBuilder: (context, index) {
                          return MChapterListItem(listItem: chapterList[index], childId: childId);
                        },
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
    );
  }
}
