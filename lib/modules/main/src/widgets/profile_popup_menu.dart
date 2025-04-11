import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../../shared/services/secure_storage_service.dart';
import '../../../../shared/widgets/toase_message.dart';
import '../../../auth/src/services/auth_service.dart';

class ProfilePopupMenu extends StatelessWidget {
  const ProfilePopupMenu({super.key});

  Future<String?> _getProfileImg() async {
    try {
      final jsonStr = await SecureStorageService.getChildProfile();
      if (jsonStr == null) return null;

      final profile = jsonDecode(jsonStr);
      return profile['profileImageUrl'] ?? '';
    } catch (e) {
      print('프로필 이미지 로딩 오류: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Modular.get<AuthService>();

    return FutureBuilder<String?>(
      future: _getProfileImg(),
      builder: (context, snapshot) {
        Widget avatarChild;

        if (snapshot.connectionState == ConnectionState.waiting) {
          // 로딩 중: 인디케이터 보여줌
          avatarChild = const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          // 데이터 있음: 프로필 이미지
          avatarChild = CircleAvatar(
            backgroundImage: NetworkImage(snapshot.data!),
          );
        } else {
          // 데이터 없음: 기본 아이콘이나 빈 원
          avatarChild = const CircleAvatar(
            child: Icon(Icons.person, color: Colors.white),
            backgroundColor: Colors.grey,
          );
        }

        return Padding(
          padding: const EdgeInsets.only(right: 15),
          child: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                ToastMessage.show("내 정보 클릭!");
              } else if (value == 'logout') {
                authService.logout();
                ToastMessage.show("로그아웃되었습니다.");
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Colors.white,
            offset: const Offset(0, 50),
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem<String>(
                value: "profile",
                child: Text("내 정보", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              PopupMenuItem<String>(
                value: "logout",
                child: Text("로그아웃", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
            child: InkWell(
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
                      offset: const Offset(1.5, 1.5),
                    ),
                  ],
                ),
                child: ClipOval(child: avatarChild), // 원형 클리핑
              ),
            ),
          ),
        );
      },
    );
  }
}
