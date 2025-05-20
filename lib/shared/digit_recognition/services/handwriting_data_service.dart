import 'package:flutter/cupertino.dart';
import 'package:nansan_flutter/shared/digit_recognition/models/handwriting_data.dart';
import 'package:nansan_flutter/shared/services/request_service.dart';

class HandwritingDataService {
  Future<void> sendHandwritingData(HandwritingData data) async {
    try {
      await RequestService.post('/handwrite/', data: data.toJson());
    } catch (e, stack) {
      // 에러 로깅, 사용자에게 에러 메시지 전달 등
      debugPrint('HandwritingData 전송 실패: $e');
      // 필요하다면 rethrow 하거나, 커스텀 예외로 감싸서 throw
      throw Exception('HandwritingData 전송 중 오류 발생');
    }
  }
}
