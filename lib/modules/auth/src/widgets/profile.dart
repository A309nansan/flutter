import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/main/src/screens/pfp_screen.dart';
import '../../../../shared/services/request_service.dart';
import '../../../../shared/services/secure_storage_service.dart';
import '../models/child_profile_model.dart';

class Profile extends StatefulWidget {
  final ChildProfileModel profile;

  const Profile({super.key, required this.profile});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Future<void> fetchChildId() async {
    try {
      final selectedChildId = widget.profile.id;
      final response = await RequestService.rawGet("/user/child/select/$selectedChildId");
      final headers = response.headers;
      final childId = headers.value("X-Child-Id");

      if (childId != null) {
        final profileJson = jsonEncode(widget.profile.toJson());
        await SecureStorageService.saveChildProfile(profileJson);
      } else {
        print("⚠️ X-Child-Id 헤더가 없습니다.");
      }
    } catch (e) {
      print("❌ 아이 Id 불러오기 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    final equip = widget.profile.equipItem;
    final backgroundCode = equip.background?['itemCode'] as int?;
    final characterCode = equip.character?['itemCode'] as int?;
    final clothesList = equip.clothes ?? [];
    final accessoriesList = equip.accessories ?? [];

    List<int> clothesCodes = clothesList.map<int>((item) => item['itemCode'] as int).toList();
    List<int> accessoriesCodes = accessoriesList.map<int>((item) => item['itemCode'] as int).toList();

    return ElevatedButton(
      onPressed: () async {
        await fetchChildId();
        Modular.to.pushNamed('/main/main-list');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 249, 241, 196),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        elevation: 3,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: screenWidth * 0.18,
            height: screenWidth * 0.18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xAAC2BCBC),
                  blurRadius: 5.0,
                  offset: const Offset(0, 7),
                ),
              ],
              gradient: backgroundCode != null ? getGradientByCode(backgroundCode) : null,
              color: backgroundCode == null ? Colors.grey.shade300 : null,
            ),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (characterCode != null)
                    Image.asset(
                      'assets/images/profile/characters/$characterCode.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ...clothesCodes.map((code) => Image.asset(
                    'assets/images/profile/clothes/$code.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  )),
                  ...accessoriesCodes.map((code) => Image.asset(
                    'assets/images/profile/accessories/$code.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.profile.name,
            style: TextStyle(
              fontSize: screenWidth * 0.025,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            "아이",
            style: TextStyle(
              fontSize: screenWidth * 0.016,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
