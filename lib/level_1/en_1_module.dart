import 'package:nansan_flutter/level_1/1_1/screens/level_1_1_1_think.dart';
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
import 'package:nansan_flutter/level_1/2_3/level_1_2_3_main1.dart';
import 'package:nansan_flutter/level_1/2_3/level_1_2_3_think1.dart';
import 'package:nansan_flutter/level_1/2_3/level_1_2_3_think3.dart';
import 'package:nansan_flutter/level_1/2_3/level_1_2_3_think4.dart';
import 'package:nansan_flutter/level_1/3_1/level_1_3_1_basic1.dart';
import 'package:nansan_flutter/level_1/3-2/screens/level_1_3_2_pro1.dart';
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
  void routes(RouteManager r) {
    // level1 1과 1차시 개념학습활동
    // r.child(
    //   '/enlv1s1c1gn1',
    //   child: (context) {
    //     final nextCode = r.args.data as String;
    //     return LevelOneOneOneThink(problemCode: nextCode);
    //   },
    // );
    // level1 1과 1차시 주요학습활동
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
    // 2과 2차시 개념1
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
      '/enlv1s2c3gn1',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneTwoThreeThink1(problemCode: nextCode);
      },
    );
    // 2과 3차시 개념3
    r.child(
      '/enlv1s2c3gn3',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneTwoThreeThink3(problemCode: nextCode);
      },
    );
    // 2과 3차시 개념4
    r.child(
      '/enlv1s2c3gn4',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneTwoThreeThink4(problemCode: nextCode);
      },
    );
    // 2과 3차시 주요1
    r.child(
      '/enlv1s2c3jy1',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneTwoThreeMain1(problemCode: nextCode);
      },
    );
    // 3과 1차시 기초1
    // r.child(
    //   '/enlv1s3c1kc1',
    //   child: (context) {
    //     final nextCode = r.args.data as String;
    //     return LevelOneThreeOneBasic1(problemCode: nextCode);
    //   },
    // );
    // 3과 2차시 기초1
    r.child(
      '/enlv1s3c2kc1',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneThreeTwoBasic(problemCode: nextCode);
      },
    );
    // 3과 2차시 주요1
    r.child(
      '/enlv1s3c2jy1',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneThreeTwoMain(problemCode: nextCode);
      },
    );
    // 3과 2차시 심화1
    r.child(
      '/enlv1s3c2sh1',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneThreeTwoPro1(problemCode: nextCode);
      },
    );
    // 4과 2차시 주요1
    r.child(
      '/enlv1s4c2jy1',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelOneFourTwoMain(problemCode: nextCode);
      },
    );
  }
}
