import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/interaction/src/screens/drawing_playground_screen.dart';

class InteractionModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child("/drawing_playground", child: (context) => DrawingPlaygroundScreen());
  }
}