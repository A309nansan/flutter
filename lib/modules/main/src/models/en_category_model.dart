class EnCategoryModel {
  final int id;
  final String name;
  final String imagePath;
  final String? problemCode;
  final String? serviceName;
  final String? description;

  EnCategoryModel({
    required this.id,
    required this.name,
    required this.imagePath,
    this.problemCode,
    this.serviceName,
    this.description,
  });

  factory EnCategoryModel.fromJson(Map<String, dynamic> json) {
    return EnCategoryModel(
      id: json['id'],
      name: json['name'],
      imagePath: json['image_path'],
      problemCode: json['problem_code'],
      serviceName: json['service_name'],
      description: json['description'],
    );
  }
}
