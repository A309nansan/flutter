import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:nansan_flutter/shared/widgets/appbar_widget.dart';
import 'package:nansan_flutter/shared/services/request_service.dart';
import 'package:nansan_flutter/shared/services/secure_storage_service.dart';
import 'gacha_box.dart';
import 'package:collection/collection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class Item {
  final int? id;
  final int itemCode;
  bool equipped;

  Item({this.id, required this.itemCode, this.equipped = false});
}

class EquippedItems {
  final List<Item> backgrounds;
  final List<Item> characters;
  final List<Item> clothes;
  final List<Item> accessories;

  EquippedItems({
    required this.backgrounds,
    required this.characters,
    required this.clothes,
    required this.accessories,
  });

  factory EquippedItems.fromJson(Map<String, dynamic> json) {
    return EquippedItems(
      backgrounds: (json['backgrounds'] as List<dynamic>? ?? []).map((e) => Item(
        id: e['id'],
        itemCode: e['itemCode'],
        equipped: e['equipped'] ?? false,
      )).toList(),
      characters: (json['characters'] as List<dynamic>? ?? []).map((e) => Item(
        id: e['id'],
        itemCode: e['itemCode'],
        equipped: e['equipped'] ?? false,
      )).toList(),
      clothes: (json['clothes'] as List<dynamic>? ?? []).map((e) => Item(
        id: e['id'],
        itemCode: e['itemCode'],
        equipped: e['equipped'] ?? false,
      )).toList(),
      accessories: (json['accessories'] as List<dynamic>? ?? []).map((e) => Item(
        id: e['id'],
        itemCode: e['itemCode'],
        equipped: e['equipped'] ?? false,
      )).toList(),
    );
  }
}

Gradient getGradientByCode(int itemCode) {
  const Map<int, Color> bottomColors = {
    101: Color(0xFFBFF0F9),
    102: Color(0xFFD6EFBF),
    103: Color(0xFFEFEEBF),
    104: Color(0xFFBEF5DD),
    105: Color(0xFFF6E1C1),
    106: Color(0xFFFFD6CD),
    107: Color(0xFFFFCEF3),
    108: Color(0xFFE8D5FF),
    109: Color(0xFFD7DDFF),
    110: Color(0xFFD2E4FF),
  };

  final bottom = bottomColors[itemCode] ?? Colors.white;

  Color lighten(Color color, double amount) {
    return Color.lerp(color, Colors.white, amount) ?? color;
  }

  final top = lighten(bottom, 0.5);

  return LinearGradient(
    colors: [top, bottom],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class ProfilePicPage extends ConsumerStatefulWidget {
  const ProfilePicPage({super.key});

  @override
  ConsumerState createState() => _ProfilePicPageState();
}

class _ProfilePicPageState extends ConsumerState<ProfilePicPage> {
  int? _coinBalance;
  bool _isLoadingCoins = false;
  bool _isLoadingEquip = false;
  EquippedItems? _equipped;
  final GlobalKey previewKey = GlobalKey();

  final ScrollController _itemScrollController = ScrollController();

  String selectedCategory = 'characters';

  final List<String> categoryOrder = [
    'characters',
    'clothes',
    'accessories',
    'backgrounds',
  ];

  final Map<String, List<int>> codeRanges = {
    'backgrounds': List.generate(10, (i) => 101 + i),
    'characters': List.generate(2, (i) => 201 + i),
    'clothes': List.generate(5, (i) => 301 + i),
    'accessories': List.generate(5, (i) => 401 + i),
  };

  final Map<String, Set<int>> selectedItemCodesByCategory = {
    'backgrounds': {},
    'characters': {},
    'clothes': {},
    'accessories': {},
  };

  final Map<String, List<Item>> ownedItemsByCategory = {
    'backgrounds': [],
    'characters': [],
    'clothes': [],
    'accessories': [],
  };

  final Map<String, int> categoryIdMap = {
    'backgrounds': 100,
    'characters': 200,
    'clothes': 300,
    'accessories': 400,
  };

  List<Item> _generateItems(String category) {
    final codes = codeRanges[category] ?? [];
    final ownedItems = ownedItemsByCategory[category] ?? [];

    return codes.map((code) {
      final ownedItem = ownedItems.firstWhere(
            (item) => item.itemCode == code,
        orElse: () => Item(id: null, itemCode: code, equipped: false),
      );

      return Item(
        id: ownedItem.id,
        itemCode: code,
        equipped: selectedItemCodesByCategory[category]?.contains(code) ?? false,
      );
    }).toList();
  }

  Future<int?> getUserId() async {
    final childProfileJson = await SecureStorageService.getChildProfile();
    final childProfile = jsonDecode(childProfileJson!);
    return childProfile['id'];
  }

  Future<void> _fetchCoinBalance() async {
    final userId = await getUserId();
    if (userId == null) return;
    setState(() => _isLoadingCoins = true);
    try {
      final response = await RequestService.get('/user/$userId/avatar/coins');
      setState(() => _coinBalance = response['coin'] ?? 0);
    } catch (e) {
      debugPrint('❌ Failed to fetch coins: $e');
    } finally {
      setState(() => _isLoadingCoins = false);
    }
  }

  Future<void> _loadEquipped() async {
    final userId = await getUserId();
    if (userId == null) return;
    setState(() => _isLoadingEquip = true);
    try {
      final data = await RequestService.get('/user/$userId/avatar/items');
      _equipped = EquippedItems.fromJson(data);

      setState(() {
        ownedItemsByCategory['backgrounds'] = _equipped!.backgrounds;
        ownedItemsByCategory['characters'] = _equipped!.characters;
        ownedItemsByCategory['clothes'] = _equipped!.clothes;
        ownedItemsByCategory['accessories'] = _equipped!.accessories;

        selectedItemCodesByCategory['backgrounds'] =
            _equipped!.backgrounds.where((e) => e.equipped).map((e) => e.itemCode).toSet();
        selectedItemCodesByCategory['characters'] =
            _equipped!.characters.where((e) => e.equipped).map((e) => e.itemCode).toSet();
        selectedItemCodesByCategory['clothes'] =
            _equipped!.clothes.where((e) => e.equipped).map((e) => e.itemCode).toSet();
        selectedItemCodesByCategory['accessories'] =
            _equipped!.accessories.where((e) => e.equipped).map((e) => e.itemCode).toSet();
      });
    } catch (e) {
      debugPrint('❌ Failed to load equipped items: $e');
    } finally {
      setState(() => _isLoadingEquip = false);
    }
  }

  bool _hasUnownedItems(String category) {
    final ownedCodes = ownedItemsByCategory[category]?.map((e) => e.itemCode).toSet() ?? {};
    final allCodes = codeRanges[category]?.toSet() ?? {};
    return allCodes.difference(ownedCodes).isNotEmpty;
  }

  bool get _hasChanges {
    if (_equipped == null) return false;
    for (final category in categoryOrder) {
      final original = {
        for (final item in ownedItemsByCategory[category] ?? [])
          if (item.equipped) item.itemCode,
      };
      final current = selectedItemCodesByCategory[category] ?? {};
      if (!const SetEquality().equals(original, current)) return true;
    }
    return false;
  }

  Future<void> _saveChanges() async {
    final userId = await getUserId();

    Item? singleSelectedItem(String category) {
      final selectedCodes = selectedItemCodesByCategory[category] ?? {};
      final ownedItems = ownedItemsByCategory[category] ?? [];
      if (selectedCodes.isEmpty) return null;
      final code = selectedCodes.first;
      return ownedItems.firstWhere(
            (item) => item.itemCode == code,
        orElse: () => Item(id: null, itemCode: code),
      );
    }

    List<Item> multiSelectedItems(String category) {
      final selectedCodes = selectedItemCodesByCategory[category] ?? {};
      final ownedItems = ownedItemsByCategory[category] ?? [];
      return selectedCodes.map((code) {
        return ownedItems.firstWhere(
              (item) => item.itemCode == code,
          orElse: () => Item(id: null, itemCode: code),
        );
      }).toList();
    }

    final body = {
      'background': (() {
        final item = singleSelectedItem('backgrounds');
        return item == null
            ? null
            : {'id': item.id, 'itemCode': item.itemCode};
      })(),
      'character': (() {
        final item = singleSelectedItem('characters');
        return item == null
            ? null
            : {'id': item.id, 'itemCode': item.itemCode};
      })(),
      'clothes': multiSelectedItems('clothes')
          .map((item) => {'id': item.id, 'itemCode': item.itemCode})
          .toList(),
      'accessories': multiSelectedItems('accessories')
          .map((item) => {'id': item.id, 'itemCode': item.itemCode})
          .toList(),
    };

    try {
      final response = await RequestService.put(
        '/user/$userId/avatar/items/equip',
        data: body,
      );
      await _loadEquipped();

      await SecureStorageService.saveChildAvatar(body);
      final childProfileJson = await SecureStorageService.getChildProfile();
      final childProfile = jsonDecode(childProfileJson!);
      print(childProfile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장되었습니다.')),
      );
    } catch (e, stacktrace) {
      debugPrint('❌ Save failed: $e');
      debugPrint('Stacktrace: $stacktrace');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장에 실패했습니다.')),
      );
    }
  }
  final Map<String, List<int>> _allItemsByCategory = {
    'backgrounds': List.generate(10, (index) => 101 + index), // 101부터 110까지
    'characters': List.generate(5, (index) => 201 + index),   // 201부터 205까지
    'clothes': List.generate(5, (i) => 301 + i),
    'accessories': List.generate(5, (i) => 401 + i),
    // ... 다른 카테고리들 추가
  };

// 사용자가 현재 소유하고 있는 아이템들을 담고 있는 Map
// 이 변수는 PfpScreenState의 상태로 관리되어야 합니다.

  List<int> _getRemainingItemCodes(String category) {
    // 1. 해당 카테고리의 모든 가능한 아이템 코드 목록을 가져옵니다.
    final allPossibleCodes = _allItemsByCategory[category] ?? [];

    // 2. 사용자가 이미 소유하고 있는 해당 카테고리의 아이템 코드 목록을 추출합니다.
    final ownedCodes = ownedItemsByCategory[category]?.map((item) => item.itemCode).toSet() ?? {};

    // 3. 전체 코드 목록에서 소유하고 있는 코드를 제외한 나머지 코드를 필터링합니다.
    return allPossibleCodes.where((code) => !ownedCodes.contains(code)).toList();
  }

// gacha_box.dart - PFP Screen에 위치한다고 가정 (아마도 PfpScreenState 클래스 내부에 있을 것입니다)
  Future<void> _openBox() async {
    final userId = await getUserId();
    if (userId == null) return;

    final categoryId = categoryIdMap[selectedCategory];
    if (categoryId == null) return;

    // 코인 잔액과 남은 아이템 코드를 PfpScreenState에서 가져와야 합니다.
    // 이 예시에서는 _coins와 _leftCodes가 PfpScreenState에 있다고 가정합니다.
    // 실제 구현에서는 해당 상태를 관리하는 곳에서 가져와야 합니다.
    final currentCoinBalance = _coinBalance; // PfpScreenState의 _coins 변수 사용
    final currentRemainingItems = _getRemainingItemCodes(selectedCategory);

    try {
      // GachaBox.open을 호출하여 다이얼로그를 띄우고 아이템을 뽑습니다.
      final newItem = await GachaBox.open(
        context: context,
        userId: userId,
        category: selectedCategory,
        categoryId: categoryId,
        coinBalance: currentCoinBalance ?? 0, // 현재 코인 잔액 전달
        remainingItems: currentRemainingItems, // 남은 아이템 코드 전달
        onNewItem: (item) {
          // 아이템이 뽑혔을 때 이 콜백이 호출됩니다.
          // PfpScreenState의 ownedItemsByCategory를 업데이트하고 스낵바를 표시합니다.
          setState(() {
            ownedItemsByCategory[selectedCategory]!.add(item);
            _coinBalance = (_coinBalance ?? 0) - 1; // 코인 차감 (GachaBox 내부에서도 차감되지만, PfpScreenState의 상태도 업데이트해야 함)
            currentRemainingItems.remove(item.itemCode); // 남은 아이템 목록 업데이트
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('아이템을 획득했습니다!')),
          );
        },
      );

      // GachaBox.open이 닫힌 후 추가적인 로직이 필요하다면 여기에 작성
      if (newItem != null) {
        // 예를 들어, 뽑은 아이템이 있을 때 추가 작업
      }

    } catch (e, stack) {
      debugPrint('❌ Box open failed: $e');
      debugPrint('Stacktrace: $stack');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('상자 열기에 실패했습니다.')),
      );
    }
  }
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdk = androidInfo.version.sdkInt;

      if (sdk >= 33) {
        final status = await Permission.photos.request();
        return status.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    // Fallback for other platforms
    return true;
  }

  Future<void> _downloadAvatarPreview(GlobalKey previewKey, BuildContext context) async {
    final hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장 권한이 필요합니다.')),
      );
      return;
    }

    try {
      final boundary = previewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final result = await ImageGallerySaverPlus.saveImage(
        pngBytes,
        quality: 100,
        name: 'nansan_avatar_${DateTime.now().millisecondsSinceEpoch}',
      );

      debugPrint('🖼️ Save result: $result');

      if (result['isSuccess'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지가 갤러리에 저장되었습니다.')),
        );
      } else {
        throw Exception("Gallery save failed");
      }
    } catch (e, stacktrace) {
      debugPrint('❌ Download failed: $e');
      debugPrint('🧱 Stacktrace:\n$stacktrace');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('다운로드에 실패했습니다.')),
      );
    }
  }

  Widget _buildBoxButtonTile() {
    final sreenHeight = MediaQuery.of(context).size.height;
    final hasUnowned = _hasUnownedItems(selectedCategory);
    return GestureDetector(
      onTap: hasUnowned ? _openBox : null,
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasUnowned ? const Color(0xFFA26A13) : const Color(0xFFF9DBAA),
          ),
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFFFF9EF),
        ),
        child: Center(
          child: Text(
            hasUnowned ? '상자 열기' : '모두 보유',
            style: TextStyle(
              fontSize: sreenHeight * 0.03,
              fontWeight: FontWeight.bold,
              color: hasUnowned ? const Color(0xFFA26A13) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchCoinBalance();
    _loadEquipped();
  }

  @override
  Widget build(BuildContext context) {
    final sreenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final currentItems = _generateItems(selectedCategory);

    return Scaffold(
      appBar: AppbarWidget(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 40),
          onPressed: () => Modular.to.pop(),
        ),
        title: null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await _downloadAvatarPreview(previewKey, context);
                  },
                  icon: const Icon(Icons.download, size: 28),
                  label: const Text('다운로드', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF9EF),
                    foregroundColor: const Color(0xFFA26A13),
                    minimumSize: const Size(150, 60),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                _isLoadingCoins
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9EF),
                    border: Border.all(color: const Color(0xFFF9DBAA)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text.rich(
                    TextSpan(children: [
                      const TextSpan(text: '🥕 ', style: TextStyle(fontSize: 28)),
                      TextSpan(
                        text: 'x $_coinBalance',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFA26A13),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: screenWidth * 0.75,
            height: screenWidth * 0.75,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: Stack(
              children: [
                RepaintBoundary(
                  key: previewKey,
                  child: Stack(
                    children: [
                      // background, character, clothes, accessories only
                      if (selectedItemCodesByCategory['backgrounds']!.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            gradient: getGradientByCode(
                              selectedItemCodesByCategory['backgrounds']!.first,
                            ),
                          ),
                        ),
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
                // Save button is outside the captured area
                if (_hasChanges)
                  Positioned(
                    bottom: 24,
                    right: 0,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFFA26A13),
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 0,
                        padding: EdgeInsets.all(screenWidth * 0.05),
                      ),
                      child: const Text(
                        '저장하기',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: sreenHeight * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: categoryOrder.map((category) {
              final label = {
                'backgrounds': '배경',
                'characters': '캐릭터',
                'clothes': '의상',
                'accessories': '악세사리',
              }[category]!;
              final isSelected = selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => setState(() => selectedCategory = category),
                  child: Container(
                    width: screenWidth * 0.18,
                    height: screenWidth * 0.1,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : const Color(0xFFFFF9EF),
                      border: Border.all(color: const Color(0xFFF9DBAA)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: sreenHeight * 0.025, // 기준 크기. 자동 축소
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFA26A13),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: sreenHeight * 0.01),
          Expanded(
            child: GridView.count(
              controller: _itemScrollController,
              crossAxisCount: 4,
              padding: const EdgeInsets.all(16),
              childAspectRatio: 1,
              children: [
                _buildBoxButtonTile(),
                ...currentItems.map((item) {
                  final isSelected =
                  selectedItemCodesByCategory[selectedCategory]!.contains(item.itemCode);
                  return GestureDetector(
                    onTap: item.id == null
                        ? null
                        : () => setState(() {
                      final set = selectedItemCodesByCategory[selectedCategory]!;
                      if (selectedCategory == 'clothes' ||
                          selectedCategory == 'accessories') {
                        isSelected ? set.remove(item.itemCode) : set.add(item.itemCode);
                      } else {
                        set.clear();
                        set.add(item.itemCode);
                      }
                    }),
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                          isSelected ? const Color(0xFFA26A13) : const Color(0xFFF9DBAA),
                          width: 4,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFFFF9EF),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (selectedCategory == 'backgrounds')
                                    Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            // item.id가 null이면 회색 배경, 아니면 gradient
                                            color: item.id == null
                                                ? Colors.grey.withOpacity(0.6)
                                                : null,
                                            gradient: item.id == null
                                                ? null
                                                : getGradientByCode(item.itemCode),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        'assets/images/profile/$selectedCategory/${item.itemCode}.png',
                                        fit: BoxFit.cover,
                                        color: item.id == null
                                            ? Colors.grey.withOpacity(0.6)
                                            : null,
                                        colorBlendMode: item.id == null
                                            ? BlendMode.saturation
                                            : null,
                                        errorBuilder: (_, __, ___) =>
                                        const Center(child: Text("No image")),
                                      ),
                                    ),
                                  if (item.id == null)
                                    Container(color: Colors.white.withOpacity(0.5)),
                                ],
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Positioned(
                              top: 8,
                              right: 8,
                              child: Icon(Icons.check_circle, color: Color(0xFFA26A13), size: 36,),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}