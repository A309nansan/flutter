import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../../shared/widgets/toase_message.dart';

class AddProfile extends StatelessWidget {
  final VoidCallback? onProfileAdded;
  final String? userRole;

  const AddProfile({super.key, this.onProfileAdded, this.userRole});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () async {
          if (userRole == "PARENT") {
            final result = await Modular.to.pushNamed('/auth/add_child');
            if (result == true && onProfileAdded != null) {
              onProfileAdded!();
            }
          } else if (userRole == "CHILD") {
            ToastMessage.show("권한이 없습니다.");
          } else if (userRole == "TEACHER") {
            Modular.to.pushNamed('/teacher/add_class');
          } else {
            ToastMessage.show("지원하지 않는 사용자입니다.");
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Color.fromARGB(255, 249, 241, 196),
          shape: CircleBorder(),
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          elevation: 3,
        ),
        child: Icon(Icons.add, size: screenWidth * 0.06, color: Colors.black54),
      ),
    );
  }
}
