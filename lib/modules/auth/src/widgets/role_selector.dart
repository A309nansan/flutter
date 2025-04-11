import 'package:flutter/material.dart';
import 'package:nansan_flutter/modules/auth/src/widgets/custom_role_radio.dart';

import '../models/role.dart';

class RoleSelector  extends StatefulWidget {
  final Function(int) onSelected;
  final int initialRole;


  const RoleSelector({
    super.key,
    required this.onSelected,
    required this.initialRole,
  });

  @override
  State<RoleSelector> createState() => _RoleSelectorState();
}

class _RoleSelectorState extends State<RoleSelector> {
  late int selectedRole;

  final List<Role> roles = [
    Role("부모님", 0, Icons.person, false),
    Role("선생님", 1, Icons.person, false),
  ];

  @override
  void initState() {
    super.initState();
    selectedRole = widget.initialRole;

    for (var role in roles) {
      role.isSelected = role.value == selectedRole;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount: roles.length,
      itemBuilder: (context, index) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Color.fromARGB(255, 249, 241, 196),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            elevation: 4,
          ),
          onPressed: () {
            setState(() {
              for (var role in roles) {
                role.isSelected = false;
              }
              roles[index].isSelected = true;
              selectedRole = roles[index].value;
            });

            widget.onSelected(selectedRole);
          },
          child: CustomRoleRadio(roles[index]),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(width: 12), // 가로 간격
    );
  }
}