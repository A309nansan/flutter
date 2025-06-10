import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

Future<void> showColorPickerDialog({
  required BuildContext context,
  required Color selectedColor,
  required ValueChanged<Color> onColorChanged,
}) async {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("색상 선택", style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: Colors.white,
      content: SingleChildScrollView(
        child: BlockPicker(
          pickerColor: selectedColor,
          onColorChanged: onColorChanged,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("확인", style: TextStyle(color: Colors.black, fontSize: 20)),
        ),
      ],
    ),
  );
}
