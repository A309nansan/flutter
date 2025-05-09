import 'package:flutter/foundation.dart';

class MProblemCheckResponse {
  final bool isCorrect;
  final int basaTotalScore;
  final int basaMyScore;
  final List<String> errorCodes;

  MProblemCheckResponse({
    required this.isCorrect,
    required this.basaTotalScore,
    required this.basaMyScore,
    required this.errorCodes,
  });

  factory MProblemCheckResponse.fromJson(Map<String, dynamic> json) {
    return MProblemCheckResponse(
      isCorrect: json['isCorrect'] ?? false,
      basaTotalScore: json['basaTotalScore'] ?? 0,
      basaMyScore: json['basaMyScore'] ?? 0,
      errorCodes: (json['errorCodes'] as List<dynamic>? ?? []).cast<String>(),
    );
  }
  @override
  String toString() {
    return 'MProblemCheckResponse('
        'isCorrect: $isCorrect, '
        'basaTotalScore: $basaTotalScore, '
        'basaMyScore: $basaMyScore, '
        'errorCodes: $errorCodes'
        ')';
  }
}