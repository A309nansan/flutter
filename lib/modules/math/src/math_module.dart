import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/math/src/screens/m_basa_random_defense.dart';
import 'package:nansan_flutter/modules/math/src/screens/m_lecture_screen.dart';
import 'package:nansan_flutter/modules/math/src/screens/m_statchart_screen.dart';
import 'package:nansan_flutter/modules/math/src/screens/m_stats_screen.dart';
import 'package:nansan_flutter/modules/math/src/_legacy_/m_test_screen.dart';

class MathModule extends Module {
  @override
  void binds(Injector i) {
    super.binds(i);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/m-lecture',
      child: (context) {
        final args = r.args.data as Map<String, dynamic>? ?? {};
        final categoryIndex = args["categoryIndex"] as int? ?? 0;
        final categoryName = args["categoryName"] as String? ?? "Unknown";
        final categoryDescription =
            args["categoryDescription"] as String? ?? "Unknown";
        final imageURL = args["imageURL"] as String? ?? "";
        final childId = args["childId"] as int? ?? 0;
        return MLectureScreen(
          categoryIndex: categoryIndex,
          categoryName: categoryName,
          categoryDescription: categoryDescription,
          imageURL: imageURL,
          isTeachingMode: true,
          childId: childId
        );
      },
    );
    r.child(
      '/m-practice',
      child: (context) {
        final args = r.args.data as Map<String, dynamic>? ?? {};
        final categoryIndex = args["categoryIndex"] as int? ?? 0;
        final categoryName = args["categoryName"] as String? ?? "Unknown";
        final categoryDescription =
            args["categoryDescription"] as String? ?? "Unknown";
        final imageURL = args["imageURL"] as String? ?? "";
        final childId = args["childId"] as int? ?? 0;
        return MLectureScreen(
          categoryIndex: categoryIndex,
          categoryName: categoryName,
          categoryDescription: categoryDescription,
          imageURL: imageURL,
          isTeachingMode: false,
          childId: childId
        );
      },
    );
    r.child(
      '/m-result',
      child: (context) {
        final args = r.args.data as Map<String, dynamic>? ?? {};
        final categoryIndex = args["categoryIndex"] as int? ?? 0;
        final categoryName = args["categoryName"] as String? ?? "Unknown";
        final categoryDescription =
            args["categoryDescription"] as String? ?? "Unknown";
        final imageURL = args["imageURL"] as String? ?? "";
        final doublePopOnBack =
            args["doublePopOnBack"] as bool? ?? false; // ✅ default false
        final childId = args["childId"] as int? ?? 0;
        return MResultScreen(
          categoryIndex: categoryIndex,
          categoryName: categoryName,
          categoryDescription: categoryDescription,
          imageURL: imageURL,
          doublePopOnBack: doublePopOnBack,
          childId: childId
        );
      },
    );
    r.child(
      '/m-random-defence',
      child: (context) {
        return MRandomDefenceScreen();
      },
    );
    r.child('/m-statchart', child: (context) {
      final args = r.args.data as Map<String, dynamic>? ?? {};
      final stats = args["stats"] as Map<String, dynamic>? ?? {};
      final categoryName = args["categoryName"] as String? ?? "미지정";

      return MStatChartScreen(statsData: stats, categoryName: categoryName);
    });
  }
}
