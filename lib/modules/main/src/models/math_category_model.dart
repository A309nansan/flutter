import 'dart:convert';

import 'package:flutter/services.dart';

class MathCategory {
  final int id;
  final int parentId;
  final int level;
  final String name;
  final String imageUrl;
  final String description;

  MathCategory({
    required this.id,
    required this.parentId,
    required this.level,
    required this.name,
    required this.imageUrl,
    required this.description,
  });

  factory MathCategory.fromJson(Map<String, dynamic> json) {
    return MathCategory(
      id: json['id'],
      parentId: json['parent_id'],
      level: json['level'],
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class MathCategoryModel {
  final List<MathCategory> categories;

  MathCategoryModel({required this.categories});

  factory MathCategoryModel.fromJson(String jsonString) {
    final List<dynamic> jsonResponse = json.decode(jsonString);
    return MathCategoryModel(
      categories:
          jsonResponse.map((data) => MathCategory.fromJson(data)).toList(),
    );
  }
}

Future<MathCategoryModel> loadMathCategoryModel() async {
  final String jsonString = await rootBundle.loadString(
    'assets/jsons/m_categories/m_category_list.json',
  );
  return MathCategoryModel.fromJson(jsonString);
}

Future<MathCategoryModel> loadMathSubCategoryModel(int index) async {
  final String jsonString = await rootBundle.loadString(
    'assets/jsons/m_categories/m_category_$index.json',
  );
  return MathCategoryModel.fromJson(jsonString);
}
