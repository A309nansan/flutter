import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/auth/src/auth_module.dart';
import 'package:nansan_flutter/modules/auth/src/screens/login_screen.dart';

class AppModule extends Module {
  @override
  List<Module> get imports => [AuthModule()];

  @override
  void routes(r) {
    r.child('/', child: (context) => const LoginScreen());
  }
}
