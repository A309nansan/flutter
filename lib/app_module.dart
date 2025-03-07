import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter/material.dart';
import 'package:nansan_flutter/modules/auth/src/auth_module.dart';
import 'package:nansan_flutter/modules/auth/src/models/user_model.dart';
import 'package:nansan_flutter/modules/auth/src/screens/login_screen.dart';
import 'package:nansan_flutter/modules/main/src/screens/draw_screen.dart';
import 'package:nansan_flutter/modules/main/src/screens/main_screen.dart';
import 'package:nansan_flutter/shared/services/secure_storage_service.dart';

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
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Access Token 가져오기
    String? accessToken = await SecureStorageService.getAccessToken();

    // User 정보 가져오기
    UserModel? user = await SecureStorageService.getUserModel();

    if (accessToken != null && accessToken.isNotEmpty && user != null) {
      Modular.to.navigate('/main');
    } else {
      Modular.to.navigate('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
