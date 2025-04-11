import '../services/m_response.dart';
import '../screens/m_problem_display.dart';
import '../services/basa_math_encoder.dart';
import 'm_problem_metadata.dart';
import 'package:flutter/material.dart';

class MProblemBundle {
  final MProblemMetadata problemMetaData;
  final MResponse userResponse;
  final List<List<List<String>>> correctResponse3DList;
  final Map<String, dynamic> requestToSend;
  final GlobalKey<MProblemDisplayState> problemDisplayKey;
  final int categoryIndex;
  final int parentCategory;
  final int childCategory;
  bool _isSent;

  MProblemBundle({
    required this.problemMetaData,
    required this.userResponse,
    required this.correctResponse3DList,
    required this.requestToSend,
    required this.problemDisplayKey,
    required this.categoryIndex,
    required this.parentCategory,
    required this.childCategory,
    bool isSent = false,
  }) : _isSent = isSent;

  void finishRawJsonForRequest(BasaMathEncoder encoder) {
    //todo Map<String, dynamic> userData는 알아서 생성하자
    List<List<List<String>>> list = [
      userResponse.recognitionCarryResults,
      userResponse.recognitionProgressResults,
      userResponse.recognitionAnswerResults,
    ];
    List<int> lenList = userResponse.matrixVolume;
    Map<String, dynamic> userData = encoder.responseToAnswerMap(list, lenList);
    return encoder.addUserDataToRequest(requestToSend, userData);
  }

  void sendRequest(BasaMathEncoder encoder) {
    finishRawJsonForRequest(encoder);
    Map<String, dynamic> data = requestToSend;

    encoder.sendAPIData(parentCategory, childCategory, data).catchError((
      e,
      stackTrace,
    ) {
      debugPrint("❗ API 전송 실패: $e");
    });
  }

  Future<void> sendResultOnceIfNeeded(BasaMathEncoder encoder) async {
    debugPrint("❗IS DATA SENT? $_isSent");
    if (!_isSent) {
      debugPrint("	✅ sending data now");
      finishRawJsonForRequest(encoder);
      await encoder.sendAPIData(parentCategory, childCategory, requestToSend);
      _isSent = true;
    } else {
      debugPrint("❌The Data is already sent");
    }
  }
}
