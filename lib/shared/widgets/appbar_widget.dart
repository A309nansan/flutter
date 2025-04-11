import 'package:flutter/material.dart';
import '../../modules/main/src/widgets/profile_popup_menu.dart';

class AppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool? isCenter;

  const AppbarWidget({
    super.key,
    required this.title,
    this.leading,
    this.actions = const [ProfilePopupMenu()],
    this.isCenter = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFFFFBF4),
      automaticallyImplyLeading: false,
      elevation: 0.0,
      title: title,
      leading: leading,
      actions: actions,
      centerTitle: isCenter ?? false,
    );
  }
}
