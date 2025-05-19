import 'package:nansan_flutter/shared/digit_recognition/models/handwriting_data.dart';
import 'package:nansan_flutter/shared/services/request_service.dart';

class HandwritingDataService {
  Future sendHandwritingData(HandwritingData data) {
    return RequestService.post('/handwriting', data: data.toJson());
  }
}
