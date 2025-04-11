import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String labelText;
  final Widget? icon;
  final FormFieldValidator<String>? validator;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.labelText,
    required this.icon,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      focusNode: focusNode ?? FocusNode(),
      keyboardType: TextInputType.text,
      maxLength: 20,
      decoration: InputDecoration(
        labelText: labelText,
        counterText: "",
        errorStyle: const TextStyle(height: 0.8),
        disabledBorder: _borderStyle(Colors.black26),
        enabledBorder: _borderStyle(Colors.black26),
        focusedBorder: _borderStyle(Colors.blue),
        errorBorder: _borderStyle(const Color.fromARGB(255, 255, 123, 123)),
        focusedErrorBorder: _borderStyle(const Color.fromARGB(255, 255, 123, 123)),
        suffixIcon: icon
      ),
      validator: validator,
    );
  }

  OutlineInputBorder _borderStyle(Color color) {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(width: 1.5, color: color),
    );
  }
}
