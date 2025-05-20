import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

class HandwritingData {
  final int childId;
  final int answer;
  final Ink ink;
  final int candidateDigit1;
  final int candidateDigit2;
  final int candidateDigit3;
  final double candidateSimilarity1;
  final double candidateSimilarity2;
  final double candidateSimilarity3;

  HandwritingData({
    required this.childId,
    required this.answer,
    required this.ink,
    // TODO : 기본값 설정 수정
    this.candidateDigit1 = 8,
    this.candidateDigit2 = 7,
    this.candidateDigit3 = 6,
    this.candidateSimilarity1 = 0.8,
    this.candidateSimilarity2 = 0.7,
    this.candidateSimilarity3 = 0.6,
  });

  Map<String, dynamic> toJson() {
    return {
      "childId": childId,
      "answer": answer,
      "ink" : {
        "ink": [
          {
            "strokes": ink.strokes
                .map(
                  (s) =>
              {
                "points": s.points
                    .map(
                      (p) =>
                  {
                    "x": p.x.toInt(),
                    "y": p.y.toInt(),
                    "t": p.t.toInt(),
                  },
                )
                    .toList(),
              },
            )
                .toList(),
          },
        ]},
      "candidateDigit1": candidateDigit1,
      "candidateDigit2": candidateDigit2,
      "candidateDigit3": candidateDigit3,
      "candidateSimilarity1": candidateSimilarity1,
      "candidateSimilarity2": candidateSimilarity2,
      "candidateSimilarity3": candidateSimilarity3,
    };
  }
}