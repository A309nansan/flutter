// gacha_box.dart — 코인 차감 로직 추가 (2025‑06)
//  • _coins: 뽑을 때마다 1씩 차감, 0이면 버튼 비활성
//  • 헤더에 "코인: n / 남은 아이템: m" 표시

import 'package:flutter/material.dart';
import 'package:nansan_flutter/shared/services/request_service.dart';
import 'pfp_screen.dart';


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
  final int LEASTCOINS = 45;
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
    if (_loading || _coins <= LEASTCOINS) return;
    setState(() => _loading = true);

    try {
      final res = await RequestService.post(
        '/user/${widget.userId}/avatar/items/draw/${widget.categoryId}',
      );
      final item = Item(id: res['id'], itemCode: res['itemCode'], equipped: false);
      widget.onItemDrawn(item);
      _coins--; _leftCodes.remove(item.itemCode);

      setState(() => _phase = Phase.animating);
      _fadeCtrl.forward(from: 0); // dim in

      await Future.delayed(const Duration(milliseconds: 1500));
      _fadeCtrl.reverse();
      setState(() {
        _item = item;
        _phase = Phase.result;
      });
    } catch (e) {
      debugPrint('❌ Gacha failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('상자 열기에 실패했습니다.')),
        );
        Navigator.of(context).pop();
      }
    } finally {
      _loading = false;
    }
  }
  void _alert() async {
    showDialog(
      context: context, // 'context'는 위젯 트리의 BuildContext를 의미합니다.
      // 이 함수가 StatefulWidget 내부에 있다면 바로 사용 가능하며,
      // StatelessWidget에서 사용 시 BuildContext를 파라미터로 받아야 합니다.
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // 모서리 둥글게
          ),
          title: Column(
            children: [
              Image.asset(
                'assets/images/profile/question.png', // 사용할 이미지 경로
                width: 100, // 이미지 너비
                height: 100, // 이미지 높이
                fit: BoxFit.contain, // 이미지 비율 유지
              ),
              SizedBox(height: 16), // 이미지와 텍스트 사이 간격
              Text(
                '작업을 수행할 수 없습니다.', // 다이얼로그 제목 또는 주 메시지
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            '보유중인 코인이 없거나 모든 아이템을 뽑았습니다.', // 상세 메시지
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인', style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }
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
                        Text('🪙 x $_coins / 남은 아이템: ${_leftCodes.length}',
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
                        onTap: (_leftCodes.isNotEmpty && _coins > LEASTCOINS) ? _startGacha : _alert,
                          child:                      Container(
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
                                'assets/images/profile/${widget.category}/${_item!.itemCode}.png',
                                fit: BoxFit.cover,
                                color: _item!.id == null ? Colors.grey.withOpacity(0.6) : null,
                                colorBlendMode: _item!.id == null ? BlendMode.saturation : null,
                              ))
                                  : Image.asset('assets/images/profile/question.png', width: 400, color: Colors.grey.withOpacity(0.6), colorBlendMode: BlendMode.saturation),
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
                  // (나머지 리스트·버튼 섹션은 그대로)
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
        itemCount: widget.remainingItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, idx) {
          final code = widget.remainingItems[idx];
          final notObtained = _leftCodes.contains(code);
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
              'assets/images/profile/${widget.category}/$code.png',
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
            //disabledBackgroundColor: Colors.grey,
            //disabledForegroundColor: Colors.white70,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          ),
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
