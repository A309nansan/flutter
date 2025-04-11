import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/main/src/screens/en_category_list_screen.dart';
import 'package:nansan_flutter/modules/main/src/screens/en_chapter_list_screen.dart';
import 'package:nansan_flutter/modules/main/src/screens/m_category_list_screen.dart';
import 'package:nansan_flutter/modules/main/src/screens/m_chapter_list_screen.dart';
import 'package:nansan_flutter/modules/main/src/screens/main_list_screen.dart';

class MainModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child('/main-list', child: (context) => const MainListScreen());
    r.child(
      '/category-list',
      child: (context) {
        final parentId = r.args.data as int? ?? 0;
        return EnCategoryListScreen(mainIndex: parentId);
      },
    );
    r.child(
      '/chapter-list',
      child: (context) {
        final args = r.args.data as Map<String, dynamic>? ?? {};
        final parentId = args["categoryIndex"] as int? ?? 0;
        final categoryName = args["categoryName"] as String? ?? "Unknown";
        final categoryLevel = args["categoryLevel"] as int? ?? 0;
        return EnChapterListScreen(
          categoryIndex: parentId,
          categoryName: categoryName,
          categoryLevel: categoryLevel,
        );
      },
    );
    r.child(
      '/m-category-list',
      child: (context) => const MCategoryListScreen(),
    );
    r.child(
      '/m-chapter-list',
      child: (context) {
        final args = r.args.data as Map<String, dynamic>? ?? {};
        final categoryIndex = args["categoryIndex"] as int? ?? 0;
        final categoryName = args["categoryName"] as String? ?? "Unknown";
        return MChapterListScreen(
          categoryIndex: categoryIndex,
          categoryName: categoryName,
        );
      },
    );
  }
}
