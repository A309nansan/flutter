import 'package:flutter/material.dart';
import 'basa_math_decoder.dart';
import 'basa_math_encoder.dart';
import '../models/m_problem_metadata.dart';
import '../models/m_problem_bundle.dart';
import 'm_response.dart';
import '../screens/m_problem_display.dart'; // MProblemState가 여기 있다고 가정

class MProblemManager {
  final BasaMathDecoder decoder;
  final BasaMathEncoder encoder;

  final List<MProblemBundle> _history = [];

  MProblemManager(this.decoder, this.encoder);

  Future<MProblemBundle> load(
    int parentCategory,
    int childCategory,
    int problemIndex,
    int categoryIndex,
  ) async {
    final raw = await decoder.fetchAPIData(parentCategory, childCategory);
    final problemMetaData = decoder.getMathDataFromResponse(raw, categoryIndex);
    final answer = decoder.getAnswerFromResponse(
      raw,
      problemIndex,
      categoryIndex,
    );
    final userResponse = MResponse.init([], problemMetaData.matrixVolume);
    final request = encoder.initiateRequest(raw);
    // ✅ GlobalKey 생성
    final GlobalKey<MProblemDisplayState> key =
        GlobalKey<MProblemDisplayState>();
    final bundle = MProblemBundle(
      problemMetaData: problemMetaData,
      correctResponse3DList: answer,
      userResponse: userResponse,
      requestToSend: request,
      problemDisplayKey: key,
      parentCategory: parentCategory,
      childCategory: childCategory,
      categoryIndex: categoryIndex, // ✅ 키 포함
    );
    _history.add(bundle);
    return bundle;
  }

  MProblemBundle loadLite(
    int parentCategory,
    int childCategory,
    int problemIndex,
    int categoryIndex,
    Map<String, dynamic> raw,
  ) {
    final problemMetaData = decoder.getMathDataFromReportResponse(
      raw,
      categoryIndex,
    );
    //debugPrint("GETTING GENERATED ANSWER");
    final generatedAnswer = decoder.getDataFromReportResponse(
      raw,
      problemIndex,
      categoryIndex,
      "generatedAnswer",
    );
    //debugPrint("GETTING  USER ANSWER");
    final userAnswer = decoder.getDataFromReportResponse(
      raw,
      problemIndex,
      categoryIndex,
      "userAnswer",
    );
    //debugPrint("CREATING LITE MRESPONSE");
    final userResponse = MResponse.initLite(
      userAnswer,
      problemMetaData.matrixVolume,
    );
    //debugPrint("MAKING DUMB REQUEST");
    final request = {"null": 0};
    final GlobalKey<MProblemDisplayState> key =
        GlobalKey<MProblemDisplayState>();
    //debugPrint("MAKING BUNDLE");
    final bundle = MProblemBundle(
      problemMetaData: problemMetaData,
      correctResponse3DList: generatedAnswer,
      userResponse: userResponse,
      requestToSend: request,
      problemDisplayKey: key,
      parentCategory: parentCategory,
      childCategory: childCategory,
      categoryIndex: categoryIndex, // ✅ 키 포함
    );
    debugPrint("FINISH");
    _history.add(bundle);
    return bundle;
  }

  List<MProblemBundle> get history => List.unmodifiable(_history);

  MProblemBundle get(int idx) {
    if (idx < 0 || idx >= _history.length) {
      throw Exception('잘못된 index 접근: $idx');
    }
    return _history[idx];
  }

  void resetHistory() {
    _history.clear();
  }

  Future<Map<String, dynamic>> fetchRawJsonFromResponse(
    parentCategory,
    childCategory,
  ) async {
    debugPrint("I AM CALLING API HERE");
    return await decoder.fetchAPIData(parentCategory, childCategory);
  }

  MProblemMetadata fetchMathDataFromResponse(
    Map<String, dynamic> response,
    int problemIndex,
    int categoryIndex,
  ) {
    debugPrint("FETCH MATH DATA FROM RESPONSE");
    return decoder.getMathDataFromResponse(response, categoryIndex);
  }

  List<List<List<String>>> fetchAnswerFromResponse(
    Map<String, dynamic> response,
    int problemIndex,
    int categoryIndex,
  ) {
    debugPrint("FETCH ANSWER FROM RESPONSE");
    return decoder.getAnswerFromResponse(response, problemIndex, categoryIndex);
  }
}
