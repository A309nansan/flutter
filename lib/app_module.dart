import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter/material.dart';
import 'package:nansan_flutter/modules/auth/src/auth_module.dart';
import 'package:nansan_flutter/modules/auth/src/screens/login_screen.dart';
import 'package:nansan_flutter/modules/main/src/screens/draw_screen.dart';
import 'package:nansan_flutter/modules/main/src/screens/main_screen.dart';
import 'package:nansan_flutter/modules/auth/src/services/auth_service.dart';

class AppModule extends Module {
  @override
  List<Module> get imports => [AuthModule()];

  @override
  void routes(r) {
    r.child('/', child: (context) => const SplashScreen());
    r.child('/login', child: (context) => const LoginScreen());
    r.child('/main', child: (context) => const MainScreen());
    r.child('/draw', child: (context) => const DrawScreen());
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // bool isLoggedIn = await _authService.isUserLoggedIn();
    bool isLoggedIn = false;
    if (isLoggedIn) {
      Modular.to.navigate('/draw'); // ✅ 로그인 되어 있으면 MainScreen으로 이동
    } else {
      Modular.to.navigate('/login'); // ❌ 로그인 안 되어 있으면 LoginScreen으로 이동
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
