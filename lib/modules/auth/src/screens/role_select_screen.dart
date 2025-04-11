import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/auth/src/models/user_model.dart';
import 'package:nansan_flutter/modules/auth/src/services/auth_service.dart';
import 'package:nansan_flutter/modules/auth/src/widgets/role_selector.dart';
import 'package:nansan_flutter/shared/widgets/button_widget.dart';

class RoleSelectScreen extends StatefulWidget {
  final UserModel userModel;

  const RoleSelectScreen({
    super.key,
    required this.userModel
  });

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  int selectedRole = 0;
  final AuthService authService = Modular.get<AuthService>();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onStartPressed() async {
    String role = selectedRole == 0 ? "PARENT" : "TEACHER";
    // final updatedUserModel = widget.userModel.copyWith(role: selectedRole);
    // await authService.createOrGetUser(updatedUserModel);
    await authService.updateRole(role);
  }

  void onRoleSelected(int value) {
    setState(() {
      selectedRole = value;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "선생님이신가요, 부모님이신가요?",
              style: TextStyle(
                fontFamily: "SingleDay",
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9C6A17),
              ),
            ),
            SizedBox(height: 40),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
              child: RoleSelector(
                onSelected: onRoleSelected,
                initialRole: selectedRole,
              )
            ),
            SizedBox(height: 100),
            Align(
              alignment: Alignment.center,
              child: ButtonWidget(
                height: 40,
                width: MediaQuery.of(context).size.height * 0.15,
                buttonText: "시작하기",
                fontSize: 16,
                onPressed: _onStartPressed,
              ),
            )
          ],
        ),
      ),
    );
  }
}