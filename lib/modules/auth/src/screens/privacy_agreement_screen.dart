import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PrivacyAgreementScreen extends StatefulWidget {
  const PrivacyAgreementScreen({super.key});

  @override
  State<PrivacyAgreementScreen> createState() => _PrivacyAgreementScreenState();
}

class _PrivacyAgreementScreenState extends State<PrivacyAgreementScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // 동의 여부
  bool agreeRequired1 = false;
  bool agreeAll = false;

  // 펼침 여부
  bool expand1 = false;

  void _onAgree() async {
    await storage.write(key: 'privacy_agreed', value: 'true');
    if (mounted) {
      Modular.to.pop(true);
    }
  }

  Widget _buildExpandableAgreement({
    required String title,
    required String content,
    required bool isChecked,
    required bool isRequired,
    required bool isExpanded,
    required Function(bool?) onChecked,
    required VoidCallback onToggle,
  }) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: Row(
            children: [
              Text(
                isRequired ? '[필수] $title' : '[선택] $title',
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.bold,
                  color: isRequired ? Colors.black : Colors.grey[700],
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 40,
                ),
              ),
            ],
          ),
          value: isChecked,
          onChanged: onChecked,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          child: ConstrainedBox(
            constraints: isExpanded
                ? const BoxConstraints()
                : const BoxConstraints(maxHeight: 0),
            child: Container(
              width: screenWidth * 0.915,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(left: 20, bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: isExpanded ? Border.all(color: Colors.grey.shade300) : Border.all(color: Colors.transparent),
              ),
              child: Text(
                content,
                style: TextStyle(fontSize: screenWidth * 0.027),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final allRequiredAgreed = agreeRequired1;
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '개인정보 동의',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildExpandableAgreement(
              title: '개인정보 수집 및 이용 동의',
              content: '''
가. 수집 및 이용 목적:
  - 회원가입, 사용자 이용 정보 분석 및 요약 보고서 제공
  - 맞춤 콘텐츠 추천, BASA 연구 및 지식 창출
  - 표본 자료 수집, 서비스 개발

나. 개인정보 수집 항목:
  1) 소셜 로그인 시: 이메일, 플랫폼 ID, 닉네임
  2) 프로필 생성 시: 이름, 생년월일, 성별, 사진(선택)
  3) 사용자 풀이 기록, 숫자 이미지 데이터
  4) 자동 수집 정보 (로그 등)

다. 보유 및 이용기간: 회원 탈퇴 시

※ 개인정보 수집에 동의하지 않을 경우 서비스 이용이 제한될 수 있습니다.''',
              isChecked: agreeRequired1,
              isRequired: true,
              isExpanded: expand1,
              onChecked: (val) {
                setState(() {
                  agreeRequired1 = val ?? false;
                  agreeAll = agreeRequired1;
                });
              },
              onToggle: () => setState(() => expand1 = !expand1),
            ),
            const Divider(height: 32),
            CheckboxListTile(
              title: Text(
                '[전체 동의] 위의 모든 항목에 동의합니다.',
                style: TextStyle(fontSize: screenWidth * 0.03, fontWeight: FontWeight.bold),
              ),
              value: agreeAll,
              onChanged: (val) {
                setState(() {
                  agreeAll = val ?? false;
                  agreeRequired1 = agreeAll;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: screenHeight * 0.04,
              child: ElevatedButton(
                onPressed: allRequiredAgreed ? _onAgree : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: Color(0xFFFFFAE1)
                ),
                child: Text(
                  '동의하고 시작하기',
                  style: TextStyle(
                    color: allRequiredAgreed ? Colors.black : Colors.black26,
                    fontSize: screenWidth * 0.02,
                    fontWeight: FontWeight.bold
                  ),

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
