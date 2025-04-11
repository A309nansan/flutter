import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
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

  @override
  void initState() {
    super.initState();
  }

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
    var screenHeight = MediaQuery.of(context).size.height;

    return ElevatedButton(
      onPressed: () async  {
        await fetchChildId();
        Modular.to.pushNamed('/main/main-list');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Color.fromARGB(255, 249, 241, 196),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        elevation: 3,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.18,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xAAC2BCBC),
                  blurRadius: 5.0,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.1,
              backgroundImage: NetworkImage(widget.profile.profileImageUrl.toString()),
              backgroundColor: Colors.white,
            ),
          ),
          Text(
            widget.profile.name,
            style: TextStyle(
              fontSize: screenWidth * 0.025,
              fontWeight: FontWeight.bold,
              color: Colors.black
            ),
          ),
          Text(
            "아이",
            style: TextStyle(
                fontSize: screenWidth * 0.016,
              fontWeight: FontWeight.bold,
              color: Colors.black54
            ),
          )
        ],
      ),
    );
  }
}
