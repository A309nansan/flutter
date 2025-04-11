class AnimalImage {
  final String imagelink;
  final String imageName;

  AnimalImage({required this.imagelink, required this.imageName});

  factory AnimalImage.fromJson(Map<String, dynamic> json) {
    return AnimalImage(
      imagelink: json['imagelink'],
      imageName: json['imageName'],
    );
  }
}
