import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final double elevation;
  final double borderRadius;

  CustomAppBar({
    required this.title,
    this.actions,
    this.leading,
    this.elevation = 4.0,
    this.borderRadius = 18.0,
  });

  @override
  Size get preferredSize => Size.fromHeight(63);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(borderRadius),
      ),
      child: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 33),
        elevation: elevation,
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: leading,
        actions: actions,
      ),
    );
  }
}
