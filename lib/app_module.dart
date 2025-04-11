import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter/material.dart';
import 'package:nansan_flutter/level_1/en_1_module.dart';
import 'package:nansan_flutter/level_2/en_2_module.dart';
import 'package:nansan_flutter/modules/auth/src/auth_module.dart';
import 'package:nansan_flutter/modules/auth/src/services/auth_service.dart';
import 'package:nansan_flutter/modules/main/src/main_module.dart';
import 'package:nansan_flutter/modules/math/src/math_module.dart';
import 'package:nansan_flutter/modules/auth/src/models/user_model.dart';
import 'package:nansan_flutter/modules/auth/src/screens/login_screen.dart';
import 'package:nansan_flutter/modules/auth/src/screens/profile_screen.dart';
import 'package:nansan_flutter/modules/main/src/screens/draw_screen.dart';
import 'package:nansan_flutter/shared/services/secure_storage_service.dart';

import 'app_initializer.dart';

class AppModule extends Module {
  @override
  List<Module> get imports => [AuthModule()];

  @override
  void routes(r) {
    // r.child('/', child: (context) => const SplashScreen());
    r.child('/', child: (context) => const AppInitializer());
    r.child('/login', child: (context) => const LoginScreen());
    r.child('/profile', child: (context) => const ProfileScreen());
    r.child('/draw', child: (context) => const DrawScreen());
    r.module('/math', module: MathModule());

    // r.child('/digit', child: (context) => const LevelOneOneOneThink());

    r.module('/auth', module: AuthModule());
    r.module('/main', module: MainModule());
    r.module('/level1', module: En1Module());
    r.module('/level2', module: En2Module());
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final AuthService authService = Modular.get<AuthService>();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    String? accessToken = await SecureStorageService.getAccessToken();

    UserModel? user = await SecureStorageService.getUserModel();

    if (accessToken != null && accessToken.isNotEmpty && user != null) {
      bool status = await authService.getStatus();
      if (status) {
        Modular.to.navigate('/profile');
      } else {
        Modular.to.navigate('/auth/role-select', arguments: user);
      }
    } else {
      Modular.to.navigate('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
