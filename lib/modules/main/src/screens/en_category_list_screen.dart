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

class _EnCategoryListScreenState extends State<EnCategoryListScreen> {
  int selectedLevel = 1;
  List<EnCategoryModel> fullCategoryList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() => isLoading = true);
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
          : Center(
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
              SizedBox(
                width: screenWidth * 0.98,
                height: screenHeight * 0.06,
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(2, (index) {
                        final level = index + 1;
                        final isSelected = selectedLevel == level;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedLevel = level;
                            });
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: AnimatedScale(
                            scale: isSelected ? 1.1 : 1.0, // 선택 시 약간 커짐
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: screenWidth * 0.25,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Level $level',
                                        style: TextStyle(
                                          fontFamily: "SingleDay",
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenHeight * 0.023,
                                          color: isSelected ? const Color(0xFF9C6A17) : Colors.black26,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      ...List.generate(level, (i) => Icon(
                                        Icons.star,
                                        color: isSelected ? Colors.amber : Colors.grey[300],
                                        size: screenWidth * 0.032,
                                        shadows: const [Shadow(color: Colors.black45, blurRadius: 5.0)],
                                      )),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 5,
                                  width: isSelected ? screenWidth * 0.2 : 0,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9C6A17),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );

                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Column(
                  key: ValueKey<int>(selectedLevel),
                  children: _buildLevelGroup(filteredList, selectedLevel - 1),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLevelGroup(List<EnCategoryModel> chunk, int chunkIndex) {
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
                        level: chunkIndex + 1,
                      ),
                    ),
                    const SizedBox(width: 20),
                    if (secondIndex < chunk.length)
                      Expanded(
                        child: EnCategoryListItem(
                          listItem: chunk[secondIndex],
                          scale: 1.3,
                          level: chunkIndex + 1,
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