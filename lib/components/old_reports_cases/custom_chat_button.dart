import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({super.key, required this.onTap, required this.icon});
  final VoidCallback onTap;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
      child: IconButton(
          onPressed: onTap,
          iconSize: 22,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 45,
            minHeight: 45,
          ),
          icon: Icon(
            icon,
            color: Colors.white,
          )),
    );
  }
}
