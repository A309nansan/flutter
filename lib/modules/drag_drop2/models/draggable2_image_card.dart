class Draggable2ImageCard {
  final String id;
  final String imageUrl;

  Draggable2ImageCard({required this.id, required this.imageUrl});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Draggable2ImageCard &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
