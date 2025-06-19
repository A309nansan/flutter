import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/main/src/screens/pfp_screen.dart';
import '../../../../shared/services/secure_storage_service.dart';
import '../../../../shared/widgets/toase_message.dart';
import '../../../auth/src/services/auth_service.dart';

class ProfilePopupMenu extends StatefulWidget {
  const ProfilePopupMenu({super.key});

  @override
  State<ProfilePopupMenu> createState() => _ProfilePopupMenuState();
}

class _ProfilePopupMenuState extends State<ProfilePopupMenu> {
  late Future<Map<String, dynamic>?> _equipItemsFuture;

  @override
  void initState() {
    super.initState();
    _loadEquipItems();
  }

  void _loadEquipItems() {
    _equipItemsFuture = _getEquipItems();
  }

  void _refreshEquipItems() {
    setState(() {
      _loadEquipItems();
    });
  }

  Future<Map<String, dynamic>?> _getEquipItems() async {
    try {
      final jsonStr = await SecureStorageService.getChildProfile();
      if (jsonStr == null) return null;

      final profile = jsonDecode(jsonStr);
      final equipItem = profile['equippedItemsResponse'];
      return equipItem as Map<String, dynamic>?;
    } catch (e) {
      print('Error loading equipped items: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Modular.get<AuthService>();

    return ValueListenableBuilder<int>(
      valueListenable: SecureStorageService.profileVersion,
      builder: (context, _, __) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: _getEquipItems(),
          builder: (context, snapshot) {
            Widget avatarChild;

            if (snapshot.connectionState == ConnectionState.waiting) {
              avatarChild = const Center(child: CircularProgressIndicator(strokeWidth: 2));
            } else if (snapshot.hasData && snapshot.data != null) {
              final equipItem = snapshot.data!;
              final background = equipItem['background']?['itemCode'] as int?;
              final character = equipItem['character']?['itemCode'] as int?;
              final clothes = (equipItem['clothes'] as List<dynamic>?)
                  ?.map((e) => e['itemCode'] as int)
                  .toList() ?? [];
              final accessories = (equipItem['accessories'] as List<dynamic>?)
                  ?.map((e) => e['itemCode'] as int)
                  .toList() ?? [];

              final selectedItemCodesByCategory = {
                'backgrounds': background != null ? [background] : <int>[],
                'characters': character != null ? [character] : <int>[],
                'clothes': clothes,
                'accessories': accessories,
              };

              avatarChild = Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  gradient: background != null ? getGradientByCode(background) : null,
                ),
                child: ClipOval(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ...['characters', 'clothes', 'accessories'].expand((category) {
                        final codes = selectedItemCodesByCategory[category]!;
                        return codes.map((code) => Image.asset(
                          'assets/images/profile/$category/$code.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ));
                      }),
                    ],
                  ),
                ),
              );
            } else {
              avatarChild = const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(right: 15),
              child: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'profile') {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfilePicPage()),
                    );
                    // 🔄 No need to manually refresh; ValueNotifier handles it
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
                    child: ClipOval(child: avatarChild),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}