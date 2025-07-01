// gacha_box.dart
import 'package:flutter/material.dart';
import 'package:nansan_flutter/shared/services/request_service.dart';
import 'gacha_popup_fail.dart'; // GachaBoxFailPopup import
import 'pfp_screen.dart'; // Item 클래스 등 필요 시


class GachaBox {
  static Future<Item?> open({
    required BuildContext context,
    required int userId,
    required String category,
    required int categoryId,
    required int coinBalance,
    List<int> remainingItems = const [],
    void Function(Item)? onNewItem,
  }) async {
    Item? picked;
    await showDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      builder: (_) => _GachaDialog(
        userId: userId,
        category: category,
        categoryId: categoryId,
        coinBalance: coinBalance,
        remainingItems: remainingItems,
        onItemDrawn: (i) {
          picked = i;
          onNewItem?.call(i);
        },
      ),
    );
    return picked;
  }
}

class _GachaDialog extends StatefulWidget {
  final int userId;
  final String category;
  final int categoryId;
  final int coinBalance;
  final List<int> remainingItems;
  final void Function(Item) onItemDrawn;
  const _GachaDialog({
    super.key,
    required this.userId,
    required this.category,
    required this.categoryId,
    required this.coinBalance,
    required this.remainingItems,
    required this.onItemDrawn,
  });
  @override
  State<_GachaDialog> createState() => _GachaDialogState();
}

enum Phase { ready, animating, result }

class _GachaDialogState extends State<_GachaDialog>
    with SingleTickerProviderStateMixin {
  Phase _phase = Phase.ready;
  Item? _item;
  bool _loading = false;
  late List<int> _leftCodes;
  late int _coins;
  int? _focusedCode;
  final int LEASTCOINS = 0;
  late final AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _leftCodes = List<int>.from(widget.remainingItems);
    _coins = widget.coinBalance;
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _startGacha() async {
    // 버튼 `onPressed`에서 이미 조건을 체크하므로, 여기서 바로 로딩 상태로 진입합니다.
    // if (_loading || _coins <= LEASTCOINS || _leftCodes.isEmpty) return; // 이 부분 제거
    if (_loading) return; // 로딩 중일 때만 리턴

    setState(() => _loading = true);

    try {
      final res = await RequestService.post(
        '/user/${widget.userId}/avatar/items/draw/${widget.categoryId}',
      );
      final item = Item(id: res['id'], itemCode: res['itemCode'], equipped: false);
      widget.onItemDrawn(item);
      _coins--;
      _leftCodes.remove(item.itemCode);

      setState(() => _phase = Phase.animating);
      _fadeCtrl.forward(from: 0); // dim in

      await Future.delayed(const Duration(milliseconds: 1500));
      _fadeCtrl.reverse();
      setState(() {
        _item = item;
        _phase = Phase.result;
      });

      // --- 뽑기 후 자동 종료 로직 ---
      if (_leftCodes.isEmpty || _coins <= LEASTCOINS) {
        await Future.delayed(const Duration(seconds: 1)); // 사용자 결과 확인 시간

        if (mounted) {
          String mainMessage;
          String subMessage;
          String imageUrl;

          if (_leftCodes.isEmpty) {
            mainMessage = '모든 아이템을 획득했습니다!';
            subMessage = '축하합니다! 이 카테고리의 모든 아이템을 모았습니다.';
            imageUrl = 'assets/images/profile/no_items_left.webp'; // 적절한 이미지 경로
          } else { // _coins <= LEASTCOINS
            mainMessage = '코인이 부족하여 더 이상 뽑을 수 없습니다.';
            subMessage = '아쉽지만, 다음 기회를 노려보세요.';
            imageUrl = 'assets/images/profile/no_coin.webp'; // 적절한 이미지 경로
          }

          // GachaBoxFailPopup을 호출하여 종료 메시지 다이얼로그 표시
          await GachaBoxFailPopup.show(
            context: context,
            message: mainMessage,
            subMessage: subMessage,
            imageUrl: imageUrl,
          );
          // 팝업이 닫힌 후 다이얼로그 자체를 닫습니다.
          if (mounted) { // 팝업 후에도 mounted 체크
            Navigator.of(context).pop();
          }
        }
      }
      // --- 자동 종료 로직 끝 ---

    } catch (e) {
      debugPrint('❌ Gacha failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('상자 열기에 실패했습니다.')),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) { // finally 블록에서도 mounted 체크
        setState(() => _loading = false);
      }
    }
  }

  // --- 기존 _alert 함수를 GachaBoxFailPopup으로 대체 ---
  void _alert() async {
    String mainMessage;
    String subMessage;
    String imageUrl;

    if (_coins <= LEASTCOINS) {
      mainMessage = '당근이 부족합니다!';
      subMessage = '아이템을 뽑기 위한 당근이 충분하지 않습니다. 당근을 모아주세요.';
      imageUrl = 'assets/images/profile/no_coin.webp'; // 적절한 이미지 경로
    } else { // _leftCodes.isEmpty
      mainMessage = '남은 아이템이 없습니다!';
      subMessage = '이 카테고리의 모든 아이템을 이미 획득했습니다.';
      imageUrl = 'assets/images/profile/no_items_left.webp'; // 적절한 이미지 경로
    }

    // GachaBoxFailPopup을 호출하여 경고 다이얼로그 표시
    await GachaBoxFailPopup.show(
      context: context,
      message: mainMessage,
      subMessage: subMessage,
      imageUrl: imageUrl,
    );
    // ✨ 추가: GachaBoxFailPopup이 닫힌 후, 현재 _GachaDialog를 닫습니다. ✨
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
  // --- _alert 함수 대체 끝 ---

  @override
  Widget build(BuildContext context) {
    final titleKo = {
      'backgrounds': '배경',
      'characters': '캐릭터',
      'clothes': '의상',
      'accessories': '악세사리',
    }[widget.category] ?? widget.category;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ─── Dim overlay ───
          FadeTransition(
            opacity: _fadeCtrl,
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
          // ─── Main card ───
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9EF),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF0D8A6), width: 4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text.rich(
                          TextSpan(children: [
                            const TextSpan(text: '⭐ ', style: TextStyle(fontSize: 18)),
                            TextSpan(text: '$titleKo 뽑기', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ]),
                          style: const TextStyle(color: Color(0xFFA26A13), fontSize: 16),
                        ),
                        // ✨ 헤더에 코인과 남은 아이템 개수 표시 ✨
                        Text('🥕 x $_coins',
                            style: const TextStyle(color: Color(0xFFA26A13), fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ─── 중앙 영역 ───
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        // 버튼 활성화/비활성화 및 _startGacha 또는 _alert 호출
                        onTap: (_leftCodes.isNotEmpty && _coins > LEASTCOINS) ? _startGacha : _alert,
                        child: Container(
                          width: 500,
                          height: 500,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFA26A13), width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: _phase == Phase.result && _item != null
                                ? (widget.category == 'backgrounds'
                                ? _BackgroundPreview(code: _item!.itemCode)
                                : Image.asset(
                              'assets/images/profile/${widget.category}/${_item!.itemCode}.webp',
                              fit: BoxFit.cover,
                              color: _item!.id == null ? Colors.grey.withOpacity(0.6) : null,
                              colorBlendMode: _item!.id == null ? BlendMode.saturation : null,
                            ))
                                : Image.asset('assets/images/profile/question.webp', width: 400, color: Colors.grey.withOpacity(0.6), colorBlendMode: BlendMode.saturation),
                          ),
                        ),
                      ),

                      if (_phase == Phase.animating)
                        FadeTransition(
                          opacity: _fadeCtrl,
                          child: Container(width: 500, height: 500, decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), borderRadius: BorderRadius.circular(16))),
                        ),
                      if (_phase == Phase.animating)
                        Image.asset('assets/images/profile/box_full.gif', width: 280),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildItemStrip(),
                  const SizedBox(height: 36),
                  _buildButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemStrip() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 30),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xFFfff6e6),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.12), offset: const Offset(4, 4), blurRadius: 6, spreadRadius: 1),
        BoxShadow(color: Colors.black.withOpacity(0.12), offset: const Offset(-4, -4), blurRadius: 6, spreadRadius: 1),
      ],
    ),
    child: SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _leftCodes.length, // 남은 아이템만 표시
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, idx) {
          final code = _leftCodes[idx];
          // 이 리스트는 항상 남은 아이템을 보여주므로 notObtained는 항상 true
          final notObtained = true;
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFF0D8A6)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: widget.category == 'backgrounds'
                ? _BackgroundPreview(code: code)
                : Image.asset(
              'assets/images/profile/${widget.category}/$code.webp',
              fit: BoxFit.cover,
              color: notObtained ? Colors.grey.withOpacity(0.6) : null,
              colorBlendMode: notObtained ? BlendMode.saturation : null,
            ),
          );
        },
      ),
    ),
  );

  Widget _buildButtons() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 30),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.brown,
            side: const BorderSide(color: Colors.brown, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('돌아가기'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: (_leftCodes.isNotEmpty && _coins > LEASTCOINS) ? Colors.brown : Colors.grey,
            foregroundColor: (_leftCodes.isNotEmpty && _coins > LEASTCOINS) ? Colors.white : Colors.white70,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          ),
          // 조건이 맞지 않으면 _alert() 호출
          onPressed: (_leftCodes.isNotEmpty && _coins > LEASTCOINS) ? _startGacha : _alert,
          child: Text(_phase == Phase.ready ? '뽑기' : '한 번 더!'),
        ),
      ],
    ),
  );
}

class _BackgroundPreview extends StatelessWidget {
  final int code;
  const _BackgroundPreview({required this.code});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: _gradient(code),
      borderRadius: BorderRadius.circular(12),
    ),
  );

  LinearGradient _gradient(int code) {
    const m = {
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
    final bottom = m[code] ?? Colors.white;
    return LinearGradient(colors: [Colors.white, bottom], begin: Alignment.topCenter, end: Alignment.bottomCenter);
  }
}