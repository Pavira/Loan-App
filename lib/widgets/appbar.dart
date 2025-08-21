import 'package:flutter/material.dart';
import 'package:loan_app/core/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? centerTitle;
  final Widget? actionWidget; // <-- custom widget for right corner

  const CustomAppBar({
    Key? key,
    required this.title,
    this.centerTitle = false,
    this.actionWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: appBarColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.only(top: 12),
        alignment: Alignment.center,
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: centerTitle,
          automaticallyImplyLeading: true,
          actions: actionWidget != null ? [actionWidget!] : null,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
