// 문제 아이템을 위한 클래스 정의
class QuestionItem {
  final String imageLink;
  final String imageName;
  final List<String> candidates;
  final String answer;

  QuestionItem({
    required this.imageLink,
    required this.imageName,
    required this.candidates,
    required this.answer,
  });

  factory QuestionItem.fromJson(Map<String, dynamic> json) {
    return QuestionItem(
      imageLink: json['Imagelink'],
      imageName: json['ImageName'],
      candidates: List<String>.from(json['candidates']),
      answer: json['answer'],
    );
  }
}
