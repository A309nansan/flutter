import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/level_2/1_1/screens/level_2_1_1_main1.dart';
import 'package:nansan_flutter/level_2/1_1/screens/level_2_1_1_main2.dart';
import 'package:nansan_flutter/level_2/1_1/screens/level_2_1_1_think1.dart';
import 'package:nansan_flutter/level_2/1_1/screens/level_2_1_1_think2.dart';
import 'package:nansan_flutter/level_2/1_2/screens/level_2_1_2_main1.dart';
import 'package:nansan_flutter/level_2/1_2/screens/level_2_1_2_main2.dart';
import 'package:nansan_flutter/level_2/1_2/screens/level_2_1_2_think.dart';

class En2Module extends Module {
  @override
  void binds(Injector i) {
    // TODO: implement binds
    super.binds(i);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/enlv2s1c1gn1',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelTwoOneOneThink1(problemCode: nextCode);
      },
    );
    r.child(
      '/enlv2s1c1gn2',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelTwoOneOneThink2(problemCode: nextCode);
      },
    );
    r.child(
      '/enlv2s1c1jy1',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelTwoOneOneMain1(problemCode: nextCode);
      },
    );
    r.child('/2-1-1-main2', child: (context) => const LevelTwoOneOneMain2());

    r.child(
      '/enlv2s1c2gn1',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelTwoOneTwoThink(problemCode: nextCode);
      },
    );
    r.child(
      '/enlv2s1c2jy1',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelTwoOneTwoMain1(problemCode: nextCode);
      },
    );
    r.child(
      '/enlv2s1c2jy2',
      child: (context) {
        final nextCode = r.args.data as String;
        return LevelTwoOneTwoMain2(problemCode: nextCode);
      },
    );
  }
}
