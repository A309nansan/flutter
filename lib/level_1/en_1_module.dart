import 'package:nansan_flutter/level_1/1_3/screens/level_1_1_3_main2.dart';
import 'package:nansan_flutter/level_1/1_3/screens/level_1_1_3_main3.dart';
import 'package:nansan_flutter/level_1/1_3/screens/level_1_1_3_think.dart';
import 'package:nansan_flutter/level_1/1_4/screens/level_1_1_4_think1.dart';
import 'package:nansan_flutter/level_1/1_4/screens/level_1_1_4_think2.dart';
import 'package:nansan_flutter/level_1/1_4/screens/level_1_1_4_think3.dart';
import 'package:nansan_flutter/level_1/2_1/screens/level_1_2_1_main1.dart';
import 'package:nansan_flutter/level_1/2_1/screens/level_1_2_1_think.dart';
import 'package:nansan_flutter/level_1/2_2/level_1_2_2_think1.dart';
import 'package:nansan_flutter/level_1/2_2/level_1_2_2_think2.dart';
import 'package:nansan_flutter/modules/drag_drop/controllers/drag_drop_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:provider/provider.dart';
import '3-2/screens/level_1_3_2_basic.dart';
import '3-2/screens/level_1_3_2_main.dart';
import '4-2/screens/level_1_4_2_main.dart';
import 'package:nansan_flutter/level_1/1_1/screens/level_1_1_1_main.dart';
import 'package:nansan_flutter/level_1/1_2/screens/level_1_1_2_think.dart';
import 'package:nansan_flutter/level_1/1_2/screens/level_1_1_2_main.dart';
import 'package:nansan_flutter/level_1/1_3/screens/level_1_1_3_main1.dart';

class En1Module extends Module {
  @override
  void binds(Injector i) {
    // TODO: implement binds
    super.binds(i);
  }

  @override
  // level1 1과 1차시 주요학습활동
  void routes(RouteManager r) {
    r.child(
      '/enlv1s1c1jy1',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneOneOneMain(problemCode: nextCode);
      },
    );
    // level1 1과 2차시 개념학습활동
    r.child(
      '/enlv1s1c2gn1',
      child: (context) {
        final nextCode = r.args.data as String;
        final controller = DragDropController();
        return ChangeNotifierProvider.value(
          value: controller,
          child: LevelOneOneTwoThink(
            problemCode: nextCode,
            controller: controller, // 직접 전달
          ),
        );
      },
    );
    // 1과 2차시 주요학습활동
    r.child(
      '/enlv1s1c2jy1',
      child: (context) {
        final nextCode = r.args.data as String;
        final controller = DragDropController();
        return ChangeNotifierProvider.value(
          value: controller,
          child: LevelOneOneTwoMain(
            problemCode: nextCode,
            controller: controller, // 직접 전달
          ),
        );
      },
    );
    // 1과 3차시 개념학습활동
    r.child(
      '/enlv1s1c3gn1',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneOneThreeThink(problemCode: nextCode);
      },
    );
    // 1과 3차시 주요학습활동 1번
    r.child(
      '/enlv1s1c3jy1',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneOneThreeMain1(problemCode: nextCode);
      },
    );
    // 1과 3차시 주요학습활동 2번
    r.child(
      '/enlv1s1c3jy2',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneOneThreeMain2(problemCode: nextCode);
      },
    );
    // 1과 3차시 주요학습활동 3번
    r.child(
      '/enlv1s1c3jy3',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneOneThreeMain3(problemCode: nextCode);
      },
    );
    // 1과 4차시 주요학습활동 1번
    r.child(
      '/enlv1s1c4gn1',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneOneFourThink1(problemCode: nextCode);
      },
    );
    // 1과 4차시 주요학습활동 2번
    r.child(
      '/enlv1s1c4gn2',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneOneFourThink2(problemCode: nextCode);
      },
    );
    // 1과 4차시 주요학습활동 3번
    r.child(
      '/enlv1s1c4gn3',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneOneFourThink3(problemCode: nextCode);
      },
    );
    // 2과 1차시 개념학습활동
    r.child(
      '/enlv1s2c1gn1',
      child: (context) {
        final nextCode = r.args.data as String;
        final controller = DragDropController();
        return ChangeNotifierProvider.value(
          value: controller,
          child: LevelOneTwoOneThink(
            problemCode: nextCode,
            controller: controller, // 직접 전달
          ),
        );
      },
    );
    // 2과 1차시 주요
    r.child(
      '/enlv1s2c1jy1',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneTwoOneMain1(problemCode: nextCode);
      },
    );
    // level1 2과 2차시 개념 1번
    r.child(
      // 'enlv1s2c2gn2'
      '/enlv1s2c2gn1',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneTwoTwoThink2(problemCode: nextCode);
      },
    );
    // level1 2과 2차시 개념 2번
    r.child(
      '/enlv1s2c2gn2',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneTwoTwoThink2(problemCode: nextCode);
      },
    );
    // 2과 3차시 개념1
    r.child(
      '/enlv1s2c2gn1',
      child: (context) {
        final nextCode = r.args.data as String;
        final controller = DragDropController();
        return ChangeNotifierProvider.value(
          value: controller,
          child: LevelOneTwoTwoThink1(
            problemCode: nextCode,
            controller: controller, // 직접 전달
          ),
        );
      },
    );
    r.child(
      '/enlv1s3c2kc1',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneThreeTwoBasic(problemCode: nextCode);
      },
    );
    r.child(
      '/enlv1s3c2jy1',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneThreeTwoMain(problemCode: nextCode);
      },
    );
    r.child(
      '/enlv1s4c2jy1',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneFourTwoMain(problemCode: nextCode);
      },
    );
  }
}
