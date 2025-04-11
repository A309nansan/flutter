import 'package:flutter/material.dart';
import '../models/gender.dart';

class CustomGenderRadio extends StatelessWidget {
  final Gender _gender;

  const CustomGenderRadio(this._gender, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _gender.icon,
            color: _gender.isSelected ? _gender.value == 0 ? Colors.blue : Colors.redAccent : Colors.grey,
            size: MediaQuery.of(context).size.width * 0.04,
          ),
          Text(
            _gender.name,
            style: TextStyle(
              color: _gender.isSelected ? _gender.value == 0 ? Colors.blue : Colors.redAccent : Colors.grey,
              fontWeight:
                  _gender.isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: MediaQuery.of(context).size.width * 0.018,
            ),
          ),
        ],
      ),
    );
  }
}
