import 'package:nansan_flutter/modules/main/src/models/en_category_model.dart';
import '../../../../shared/services/request_service.dart';

class CategoryService {
  static Future<List<EnCategoryModel>> fetchCategories([int? parentId]) async {
    try {
      final path =
          parentId == null
              ? '/category/list'
              : '/category/list?parent_id=$parentId';

      final response = await RequestService.get(path);
      final List<dynamic> categories = response['categories'] ?? [];

      return categories.map((json) => EnCategoryModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ 카테고리 요청 실패: $e');
      return [];
    }
  }
}
