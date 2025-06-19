import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/main/src/models/en_category_model.dart';
import 'package:nansan_flutter/modules/main/src/service/category_service.dart';
import 'package:nansan_flutter/modules/main/src/widgets/en_category_list_item.dart';
import 'package:nansan_flutter/shared/widgets/en_list_splash_screen.dart';
import '../../../../shared/widgets/appbar_widget.dart';
import 'dart:math';

class EnCategoryListScreen extends StatefulWidget {
  final int mainIndex;
  const EnCategoryListScreen({super.key, required this.mainIndex});

  @override
  State<EnCategoryListScreen> createState() => _EnCategoryListScreenState();
}

class _EnCategoryListScreenState extends State<EnCategoryListScreen> with TickerProviderStateMixin {
  int selectedLevel = 1;
  List<EnCategoryModel> fullCategoryList = [];
  bool isLoading = false;
  late TabController _tabController;
  int selectedTabIndex = 0;
  final togetherCategoryList = [
    EnCategoryModel(
      id: 1000,
      name: "나만의 그림판",
      imagePath: "assets/images/freelayout_background/playground_thumbnail.png",
      description: "원하는 배경 위에 내가 그린 그림, 귀여운 스티커를 \n자유롭게 배치해 보세요!",
    ),
  ];

  final Map<int, String> togetherRoutes = {
    1000: "/interaction/drawing_playground"
  };


  @override
  void initState() {
    super.initState();
    setState(() => isLoading = true);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedTabIndex = _tabController.index;
      });
    });
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final result = await CategoryService.fetchCategories(widget.mainIndex);
    setState(() {
      fullCategoryList = result;
      isLoading = false;
    });
  }

  List<EnCategoryModel> get filteredList {
    final start = (selectedLevel - 1) * 4;
    final end = min(start + 4, fullCategoryList.length);
    return fullCategoryList.sublist(start, end);
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
          ? EnListSplashScreen()
          : DefaultTabController(
        length: 3,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: screenWidth * 0.90,
                height: screenHeight * 0.1,
                padding: const EdgeInsets.only(bottom: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "수 인식",
                    style: TextStyle(
                      fontFamily: "SingleDay",
                      fontSize: screenWidth * 0.065,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9C6A17),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: screenWidth * 0.8,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Color(0xFF9C6A17),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFF9C6A17),
                    indicatorWeight: 6,
                    indicatorSize: TabBarIndicatorSize.tab,
                    splashBorderRadius: BorderRadius.circular(20),
                      labelStyle: TextStyle(
                        fontFamily: "SingleDay",
                        fontSize: screenHeight * 0.026,
                        fontWeight: FontWeight.bold
                      ),
                      labelPadding: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      unselectedLabelStyle: TextStyle(
                          fontFamily: "SingleDay",
                          fontSize: screenHeight * 0.023,
                          fontWeight: FontWeight.bold
                      ),
                      dividerColor: Colors.transparent,
                    tabs: List.generate(3, (index) {
                      final isSelected = selectedTabIndex == index;
                      final level = index + 1;

                      return Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              index < 2 ? 'Level $level' : '함께해요',
                            ),
                            if (index < 2)
                              Row(
                                children: List.generate(level, (i) => Padding(
                                  padding: const EdgeInsets.only(left: 3),
                                  child: Icon(
                                    Icons.star,
                                    size: screenWidth * 0.032,
                                    color: isSelected ? Colors.amber : Colors.grey[300],
                                    shadows: isSelected
                                        ? [const Shadow(color: Colors.black26, blurRadius: 2)]
                                        : [],
                                  ),
                                )),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.8,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTabContent(0),
                    _buildTabContent(1),
                    _buildTabContent(2),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(int levelIndex) {
    final List<EnCategoryModel> chunk;
    final int chunkLevel;
    void Function(EnCategoryModel item) routeBuilder;

    if (levelIndex == 2) {
      chunk = togetherCategoryList;
      chunkLevel = 0;

      routeBuilder = (item) {
        final route = togetherRoutes[item.id];
        if (route != null) {
          Modular.to.pushNamed(route);
        }
      };
    } else {
      final start = levelIndex * 4;
      final end = min(start + 4, fullCategoryList.length);
      chunk = fullCategoryList.sublist(start, end);
      chunkLevel = levelIndex + 1;
      routeBuilder = (item) => Modular.to.pushNamed(
        '/main/chapter-list',
        arguments: {
          "categoryIndex": item.id,
          "categoryName": item.name,
          "categoryLevel": chunkLevel,
        },
      );
    }

    return Column(
      children: _buildLevelGroup(chunk, chunkLevel, routeBuilder),
    );
  }

  List<Widget> _buildLevelGroup(
      List<EnCategoryModel> chunk,
      int chunkIndex,
      void Function(EnCategoryModel item) routeBuilder,
      ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return [
      Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          children: List.generate(
            (chunk.length / 2).ceil(),
                (rowIndex) {
              final firstIndex = rowIndex * 2;
              final secondIndex = firstIndex + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: EnCategoryListItem(
                        listItem: chunk[firstIndex],
                        scale: 1.3,
                        level: chunkIndex,
                        onTap: () => routeBuilder(chunk[firstIndex]),
                      ),
                    ),
                    const SizedBox(width: 20),
                    if (secondIndex < chunk.length)
                      Expanded(
                        child: EnCategoryListItem(
                          listItem: chunk[secondIndex],
                          scale: 1.3,
                          level: chunkIndex,
                          onTap: () => routeBuilder(chunk[secondIndex]),
                        ),
                      )
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ];
  }
}