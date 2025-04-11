import 'package:nansan_flutter/level_1/2_1/models/animal_image.dart';

class QuizData {
  final Map<String, AnimalImage> images;
  final List<int> questions;

  QuizData({required this.images, required this.questions});

  factory QuizData.fromJson(Map<String, dynamic> json) {
    Map<String, AnimalImage> imageMap = {};
    Map<String, dynamic> imagesJson = json['images'];

    imagesJson.forEach((key, value) {
      imageMap[key] = AnimalImage.fromJson(value);
    });

    return QuizData(
      images: imageMap,
      questions: List<int>.from(json['question']),
    );
  }
}
