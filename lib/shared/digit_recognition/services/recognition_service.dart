import 'package:flutter/foundation.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
// ✅ 꼭 필요

class DigitalInkRecognitionService {
  static final DigitalInkRecognitionService _instance =
  DigitalInkRecognitionService._();
  DigitalInkRecognizer? _recognizer;
  String _languageCode = 'ko';
  bool _modelDownloaded = false;

  DigitalInkRecognitionService._();

  static DigitalInkRecognitionService get instance => _instance;

  Future<void> initialize({String languageCode = 'ko'}) async {
    debugPrint('[🖋️ DigitalInk] 초기화 시작 - 언어 코드: $languageCode');

    if (_recognizer != null && _languageCode != languageCode) {
      debugPrint('[🖋️ DigitalInk] 언어 변경 감지됨. 기존 인식기 종료');
      await _recognizer!.close();
      _recognizer = null;
    }

    _languageCode = languageCode;
    _recognizer = DigitalInkRecognizer(languageCode: _languageCode);
    debugPrint('[🖋️ DigitalInk] 인식기 생성 완료');

    final modelManager = DigitalInkRecognizerModelManager();
    _modelDownloaded = await modelManager.isModelDownloaded(_languageCode);
    debugPrint('[🖋️ DigitalInk] 모델 다운로드 여부: $_modelDownloaded');

    if (!_modelDownloaded) {
      debugPrint('[🖋️ DigitalInk] 모델 다운로드 시작');

      _modelDownloaded = await modelManager.downloadModel(
        _languageCode,
        isWifiRequired: false,
        // conditions: downloadConditions,
      );

      debugPrint('[🖋️ DigitalInk] 모델 다운로드 결과: $_modelDownloaded');

      if (!_modelDownloaded) {
        debugPrint('[🖋️ DigitalInk] ❌ 모델 다운로드 실패');
        throw Exception('$_languageCode 인식 모델 다운로드 실패');
      }
    }

    debugPrint('[🖋️ DigitalInk] 초기화 완료');
  }

  Future<List<RecognitionCandidate>> recognize(Ink ink) async {
    if (_recognizer == null) {
      throw Exception('인식기가 초기화되지 않았습니다. 먼저 initialize()를 호출하세요.');
    }

    if (!_modelDownloaded) {
      throw Exception('언어 모델이 다운로드되지 않았습니다. 먼저 서비스를 초기화하세요.');
    }

    try {
      final candidates = await _recognizer!.recognize(ink);
      final numericCandidates = candidates.where((candidate) {
        return RegExp(r'^[0-9]$').hasMatch(candidate.text);
      }).toList();

      return numericCandidates.isNotEmpty ? numericCandidates : [];
    } catch (e) {
      print('인식 오류: $e');
      return [];
    }
  }

  Future<void> dispose() async {
    if (_recognizer != null) {
      await _recognizer!.close();
      _recognizer = null;
    }
  }
}
