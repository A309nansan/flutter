import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class ToastMessage {
  static void show(
    String message, {
    Toast? toastLength,
    Color? backgroundColor,
    Color? textColor,
    double horizontalPadding = 10.0,
  }) {
    Fluttertoast.showToast(
      msg:
          " " * (horizontalPadding ~/ 2) +
          message +
          " " * (horizontalPadding ~/ 2),
      toastLength: toastLength ?? Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor ?? Colors.grey,
      textColor: textColor ?? Colors.white,
      fontSize: 16.0,
    );
  }
}
