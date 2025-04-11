import 'package:nansan_flutter/modules/level_api/models/problem_response.dart';
import 'package:nansan_flutter/shared/services/request_service.dart';

class ProblemApiService {
  Future<ProblemResponse> loadProblemData(String problemCode) async {
    try {
      final response = await RequestService.post(
        '/en/problem/make',
        data: {"problem_code": problemCode},
      );
      // JSON 데이터를 ProblemResponse 객체로 변환
      return ProblemResponse.fromJson(response);
    } catch (e) {
      throw Exception('문제 데이터 로드 실패: ${e.toString()}');
    }
  }

  Future<bool> submitAnswer(submit) async {
    try {
      final response = await RequestService.post(
        '/en/problem/save',
        data: submit,
      );

      if (response == "성공적으로 저장되었습니다.") {
        return true;
      } else {
        throw Exception('답변 제출 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('답변 제출 중 오류 발생: ${e.toString()}');
    }
  }
}
