import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/auth/src/models/child_profile_model.dart';
import 'package:nansan_flutter/modules/auth/src/widgets/add_profile.dart';
import 'package:nansan_flutter/modules/auth/src/widgets/profile.dart';
import 'package:nansan_flutter/shared/services/secure_storage_service.dart';
import 'package:nansan_flutter/shared/widgets/toase_message.dart';
import '../../../../shared/services/request_service.dart';
import '../models/user_info_model.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  List<ChildProfileModel> profileList = [];
  String? userRole;
  bool isLoading = true;
  double _opacity = 0.0;
  DateTime? _lastBackPressed;

  Future<List<ChildProfileModel>> fetchChildProfiles() async {
    try {
      final response = await RequestService.get("/user/parent/childList");
      final List<dynamic> profiles = response;
      print(profiles.toString());

      return profiles.map((json) => ChildProfileModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("❌ 아이 정보 불러오기 실패: $e");
      return [];
    }
  }

  void loadProfiles() async {
    final children = await fetchChildProfiles();
    setState(() {
      profileList = children;
      isLoading = false;
    });
  }

  void loadUserInfo() async {
    final jsonStr = await SecureStorageService.getUserInfoJson();
    if (jsonStr != null) {
      final user = UserInfoModel.fromJson(jsonStr);
      userRole = user.role;
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        _opacity = 1.0;
      });
    });
    loadProfiles();
    loadUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    final authService = Modular.get<AuthService>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;
          ToastMessage.show('한 번 더 누르면 종료됩니다.');
        } else {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOut,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          width: screenWidth * 0.5,
                          height: screenHeight * 0.15,
                          child: Image.asset("assets/images/logo1.png"),
                        ),
                        SizedBox(height: screenHeight * 0.1),
                        Text(
                          "사용할 프로필을 선택해주세요.",
                          style: TextStyle(
                            fontFamily: "SingleDay",
                            fontSize: screenHeight * 0.02,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9C6A17),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          width: screenWidth * 0.55,
                          height: screenHeight * 0.45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              const BoxShadow(
                                color: Colors.black38,
                              ),
                              const BoxShadow(
                                color: Colors.black38,
                                spreadRadius: -12.0,
                                blurRadius: 12.0,
                              ),
                            ],
                          ),
                          child:
                              isLoading
                                  ? SizedBox(
                                    height: screenHeight * 0.2,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                  : profileList.isEmpty
                                  ? SizedBox(
                                    height: screenHeight * 0.15,
                                    child: AddProfile(
                                      onProfileAdded: () {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        loadProfiles();
                                      },
                                      userRole: userRole,
                                    ),
                                  )
                                  : GridView.builder(
                                    shrinkWrap: true,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: screenWidth * 0.025,
                                          mainAxisSpacing: screenWidth * 0.025,
                                          childAspectRatio: 0.80,
                                        ),
                                    itemCount: profileList.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index == profileList.length) {
                                        return AddProfile(
                                          onProfileAdded: () {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            loadProfiles();
                                          },
                                          userRole: userRole,
                                        );
                                      }
                                      return Profile(profile: profileList[index]);
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20, right: 29),
                  child: TextButton(
                    onPressed: () {
                      authService.logout();
                      ToastMessage.show("로그아웃되었습니다.");
                    },
                    style: ButtonStyle(
                      overlayColor: WidgetStateProperty.resolveWith<Color?>(
                            (states) {
                          if (states.contains(WidgetState.pressed)) {
                            return Colors.black12.withAlpha(10); // 클릭 시 나타날 색상
                          }
                          return null;
                        },
                      ),
                    ),
                    child: Text(
                      "로그아웃",
                      style: TextStyle(
                        fontSize: screenWidth * 0.02,
                        color: Color(0xFF9C6A17),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
