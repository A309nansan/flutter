import 'package:equatable/equatable.dart';

class CardData extends Equatable {
  final String id;
  final String imageName;
  final String imageUrl;

  const CardData({
    required this.id,
    required this.imageName,
    required this.imageUrl,
  });

  @override
  List<Object> get props => [id, imageName, imageUrl];

  CardData copyWith({String? id, String? imageName, String? imageUrl}) {
    return CardData(
      id: id ?? this.id,
      imageName: imageName ?? this.imageName,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'image_name': imageName,
    'image_url': imageUrl,
  };

  factory CardData.fromJson(Map<String, dynamic> json) => CardData(
    id: json['id'],
    imageName: json['image_name'],
    imageUrl: json['image_url'],
  );
}
