import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/main/src/widgets/en_chapter_list_item.dart';
import '../../../../shared/services/en_problem_service.dart';
import '../../../../shared/widgets/appbar_widget.dart';
import '../../../../shared/widgets/en_list_splash_screen.dart';
import '../models/en_category_model.dart';
import '../service/category_service.dart';

class EnChapterListScreen extends StatefulWidget{
  final int categoryIndex;
  final String categoryName;
  final int categoryLevel;

  const EnChapterListScreen({
    super.key,
    required this.categoryIndex,
    required this.categoryName,
    required this.categoryLevel
  });

  @override
  State<EnChapterListScreen> createState() => _EnChapterListScreenState();
}

class _EnChapterListScreenState extends State<EnChapterListScreen> {
  late final int? childId;
  List<EnCategoryModel> chapterList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() => isLoading = true);
    init();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    final result = await CategoryService.fetchCategories(widget.categoryIndex);
    setState(() {
      chapterList = result;
      isLoading = false;
    });
  }

  void init() async {
    childId = await EnProblemService.getChildId();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppbarWidget(
        title: null,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 40.0),
          onPressed: () => Modular.to.pop(),
        ),
      ),
      body: isLoading
          ? EnListSplashScreen() :
      SingleChildScrollView(
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
                      "수 인식",
                      style: TextStyle(
                        fontFamily: "SingleDay",
                        fontSize: screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9C6A17),
                      ),
                    ),
                    Text(
                      widget.categoryName,
                      style: TextStyle(
                        fontFamily: "SingleDay",
                        fontSize: screenWidth * 0.043,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9C6A17),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: chapterList.length,
                itemBuilder: (context, index) {
                  return EnChapterListItem(listItem: chapterList[index], level: widget.categoryLevel, childId: childId!,);
                },
              ),
            ),
            const SizedBox(height: 80)
          ],
        ),
      ),
    );
  }
}