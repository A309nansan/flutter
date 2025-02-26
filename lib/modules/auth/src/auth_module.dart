import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/auth/src/screens/login_screen.dart';
import 'package:nansan_flutter/modules/auth/src/services/google_sign_in_service.dart';
import 'package:nansan_flutter/modules/auth/src/services/kakao_sign_in_service.dart';

class AuthModule extends Module {
  @override
  void binds(i) {
    i.add(KakaoSignInService.new);
    i.add(GoogleSignInService.new);
  }

  @override
  void routes(r) {
    r.child('/login', child: (context) => const LoginScreen());
  }
}
