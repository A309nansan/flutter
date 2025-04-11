import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/auth/src/models/user_model.dart';
import 'package:nansan_flutter/modules/auth/src/screens/add_child_screen.dart';
import 'package:nansan_flutter/modules/auth/src/screens/login_screen.dart';
import 'package:nansan_flutter/modules/auth/src/screens/privacy_agreement_screen.dart';
import 'package:nansan_flutter/modules/auth/src/screens/role_select_screen.dart';
import 'package:nansan_flutter/modules/auth/src/services/auth_service.dart';
import 'package:nansan_flutter/modules/auth/src/services/facebook_sign_in_service.dart';
import 'package:nansan_flutter/modules/auth/src/services/google_sign_in_service.dart';
import 'package:nansan_flutter/modules/auth/src/services/kakao_sign_in_service.dart';

class AuthModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(KakaoSignInService.new);
    i.addSingleton(GoogleSignInService.new);
    i.addSingleton(FacebookSignInService.new);
    i.addSingleton(AuthService.new);
  }

  @override
  void routes(r) {
    r.child('/login', child: (context) => const LoginScreen());
    r.child('/privacy-agreement', child: (context) => const PrivacyAgreementScreen());
    r.child('/add_child', child: (context) => const AddChildScreen());
    r.child('/role-select', child: (context) {
      final args = r.args.data as UserModel;
      return RoleSelectScreen(userModel: args);
    });
  }
}
