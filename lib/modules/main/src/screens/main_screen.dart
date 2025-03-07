import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/auth/src/services/auth_service.dart';
import 'package:nansan_flutter/shared/services/secure_storage_service.dart';
import 'package:nansan_flutter/shared/widgets/toase_message.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Modular.get<AuthService>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        // leading: IconButton(
        //   onPressed: () {
        //     ToastMessage.show("메뉴 클릭!");
        //   },
        //   icon: Icon(Icons.menu, size: 28),
        //   // margin: EdgeInsets.only(left: 10),
        // ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: InkWell(
              onTap: () {
                ToastMessage.show("프로필필 클릭!");
              },
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.3 * 255).toInt()),
                      blurRadius: 1,
                      spreadRadius: 1,
                      offset: Offset(1.5, 1.5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundImage: AssetImage("assets/images/icon_img.jpg"),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("샘플"),
            TextButton(
              onPressed: () {
                authService.logout();
              },
              child: Text("로그아웃"),
            ),
          ],
        ),
      ),
    );
  }
}
