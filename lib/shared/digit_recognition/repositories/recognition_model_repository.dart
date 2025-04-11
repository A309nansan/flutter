import 'package:flutter/material.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

class RecognitionModelRepository {
  static final RecognitionModelRepository _instance =
      RecognitionModelRepository._();

  RecognitionModelRepository._();

  static RecognitionModelRepository get instance => _instance;

  final DigitalInkRecognizerModelManager _modelManager =
      DigitalInkRecognizerModelManager();

  /// 특정 언어 모델이 다운로드되었는지 확인
  Future<bool> isModelDownloaded(String languageCode) async {
    return await _modelManager.isModelDownloaded(languageCode);
  }

  /// 특정 언어 모델 다운로드
  Future<bool> downloadModel(String languageCode) async {
    try {
      return await _modelManager.downloadModel(languageCode);
    } catch (e) {
      debugPrint('모델 다운로드 오류 ($languageCode): $e');
      return false;
    }
  }

  /// 특정 언어 모델 삭제
  Future<bool> deleteModel(String languageCode) async {
    try {
      return await _modelManager.deleteModel(languageCode);
    } catch (e) {
      debugPrint('모델 삭제 오류 ($languageCode): $e');
      return false;
    }
  }
}
