import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:scribble/scribble.dart';

Future<void> showDrawingPopup({
  required BuildContext context,
  required ScribbleNotifier notifier,
  required Future<ui.Image> Function(ByteData byteData) byteDataToUiImage,
  required void Function(ui.Image image) onImageCreated,
  required Widget strokeToolbar,
  required Widget eraserButton
}) async {
  final screenHeight = MediaQuery.of(context).size.height;

  Color selectedColor = Colors.black;

  void showColorPicker() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            "색상 선택",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                selectedColor = color;
                notifier.setColor(color); // 색상 즉시 적용
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                notifier.setColor(selectedColor);
                Navigator.of(context).pop();
              },
              child: Text(
                "선택",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  await Dialogs.materialDialog(
    color: Colors.white,
    title: '그림판',
    titleStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    msg: '그림을 자유롭게 그려보세요!',
    msgStyle: const TextStyle(fontSize: 18),
    customView: Column(
      children: [
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.color_lens_rounded, size: 42),
                onPressed: showColorPicker,
              ),
              const SizedBox(width: 20),
              strokeToolbar,
              const SizedBox(width: 20),
              eraserButton,
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.undo, size: 32),
                onPressed: notifier.canUndo ? notifier.undo : null,
              ),
              IconButton(
                icon: const Icon(Icons.redo, size: 32),
                onPressed: notifier.canRedo ? notifier.redo : null,
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 32),
                onPressed: notifier.clear,
              ),
            ],
          ),
        ),
        Container(
          height: screenHeight * 0.6,
          padding: const EdgeInsets.all(20),
          child: ClipRect(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 1.5, color: Colors.black26),
              ),
              child: Scribble(
                notifier: notifier,
                drawPen: true,
                drawEraser: true,
              ),
            ),
          ),
        ),
      ],
    ),
    customViewPosition: CustomViewPosition.BEFORE_ACTION,
    context: context,
    actionsBuilder: (context) => [
      IconsButton(
        onPressed: () {
          notifier.clear();
          Navigator.of(context).pop();
        },
        text: '취소',
        iconData: Icons.close_rounded,
        color: Colors.redAccent,
        textStyle: const TextStyle(color: Colors.white),
        iconColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      IconsButton(
        onPressed: () async {
          final byteData = await notifier.renderImage();
          final image = await byteDataToUiImage(byteData);
          onImageCreated(image);
          notifier.clear();
          Navigator.of(context).pop();
        },
        text: '추가',
        iconData: Icons.done,
        color: Colors.blue,
        textStyle: const TextStyle(color: Colors.white),
        iconColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    ],
  );
}
