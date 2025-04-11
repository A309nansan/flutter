import 'package:flutter/material.dart';
import 'package:nansan_flutter/modules/auth/src/models/role.dart';

class CustomRoleRadio extends StatelessWidget {
  final Role _role;

  const CustomRoleRadio(this._role, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.2,
      height: MediaQuery.of(context).size.height * 0.2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Icon(
              _role.icon,
              color: _role.isSelected ? _role.value == 0 ? Colors.deepPurpleAccent : Colors.blueAccent : Colors.grey,
              size: 35,
            ),
          ),
          Text(
            _role.name,
            style: TextStyle(
              color: _role.isSelected ? _role.value == 0 ? Colors.deepPurpleAccent : Colors.blueAccent : Colors.grey,
              fontWeight:
              _role.isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}