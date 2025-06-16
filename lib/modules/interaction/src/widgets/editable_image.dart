import 'package:flutter/material.dart';
import '../models/placed_image.dart';

class EditableImage extends StatefulWidget {
  final PlacedImage placedImage;
  final VoidCallback onDelete;

  const EditableImage({super.key, required this.placedImage, required this.onDelete});

  @override
  State<EditableImage> createState() => _EditableImageState();
}

class _EditableImageState extends State<EditableImage> {
  late Offset _offset;
  late double _rotation;
  late double _scale;
  Offset _initialFocalPoint = Offset.zero;
  double _initialRotation = 0.0;
  double _initialScale = 1.0;

  @override
  void initState() {
    super.initState();
    _offset = widget.placedImage.position;
    _rotation = widget.placedImage.rotation;
    _scale = widget.placedImage.scale;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += details.delta;
      widget.placedImage.position = _offset;
    });
  }

  void _onScaleStart(ScaleStartDetails details) {
    _initialFocalPoint = details.focalPoint;
    _initialRotation = _rotation;
    _initialScale = _scale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // 이동 처리
      _offset += details.focalPointDelta;
      widget.placedImage.position = _offset;

      // 회전
      _rotation = _initialRotation + details.rotation;
      widget.placedImage.rotation = _rotation;

      // 스케일
      _scale = (_initialScale * details.scale).clamp(0.5, 2.0);
      widget.placedImage.scale = _scale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageWidth = (widget.placedImage.image.width.toDouble() / 3) * _scale;
    final imageHeight = (widget.placedImage.image.height.toDouble() / 3) * _scale;

    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateZ(_rotation)
                ..scale(_scale),
              child: Stack(
                children: [
                  RawImage(
                    image: widget.placedImage.image,
                    color: Colors.white.withAlpha(150),
                    fit: BoxFit.contain,
                    width: imageWidth + 3,
                    height: imageHeight + 3,
                  ),
                  RawImage(
                    image: widget.placedImage.image,
                    fit: BoxFit.contain,
                    width: imageWidth,
                    height: imageHeight,
                  ),
                ],
              ),
            ),
            Positioned(
              top: -16,
              right: -16,
              child: SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  icon: Icon(Icons.close, size: 16, color: Colors.white),
                  onPressed: widget.onDelete,
                  style: IconButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      elevation: 2.0,
                    padding: EdgeInsets.zero, // 👈 눌림 영역 정확하게 설정
                    minimumSize: const Size(32, 32), // 👈 실제 터치 영역 보장
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}