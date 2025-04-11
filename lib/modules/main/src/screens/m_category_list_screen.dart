import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/main/src/widgets/en_category_list_item.dart';
import '../../../../shared/widgets/appbar_widget.dart';
import '../../../../shared/widgets/en_list_splash_screen.dart';
import '../../../../shared/widgets/toase_message.dart';
import '../models/en_category_model.dart';
import '../models/math_category_model.dart';
import '../service/category_service.dart';
import '../widgets/m_category_list_item.dart'; // ← 모델 경로에 맞게 조정

class MCategoryListScreen extends StatefulWidget {
  const MCategoryListScreen({super.key});

  @override
  State<MCategoryListScreen> createState() => _MCategoryListScreenState();
}

class _MCategoryListScreenState extends State<MCategoryListScreen> {
  List<EnCategoryModel> categoryList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() => isLoading = true);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final result = await CategoryService.fetchCategories(2);
    setState(() {
      categoryList = result;
      isLoading = false;
    });
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
      body:
          isLoading
              ? EnListSplashScreen()
              : Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: screenWidth * 0.90,
                        height: screenHeight * 0.13,
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "사칙 연산(M)",
                            style: TextStyle(
                              fontFamily: "SingleDay",
                              fontSize: screenWidth * 0.065,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9C6A17),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: screenWidth * 0.05,
                          right: screenWidth * 0.05,
                        ),
                        // padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            (categoryList.length / 4).ceil(),
                            (chunkIndex) {
                              final start = chunkIndex * 4;
                              final end = (start + 4).clamp(
                                0,
                                categoryList.length,
                              );
                              final chunk = categoryList.sublist(start, end);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: List.generate(
                                      (chunk.length / 2).ceil(),
                                      (rowIndex) {
                                        final firstIndex = rowIndex * 2;
                                        final secondIndex = firstIndex + 1;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 20.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: MCategoryListItem(
                                                  listItem: chunk[firstIndex],
                                                  scale: 1.3,
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              if (secondIndex < chunk.length)
                                                Expanded(
                                                  child: MCategoryListItem(
                                                    listItem:
                                                        chunk[secondIndex],
                                                    scale: 1.3,
                                                  ),
                                                )
                                              else
                                                Expanded(child: Container()),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
    );
  }
}
