import 'package:flutter/material.dart';

class BottomSheetItem {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const BottomSheetItem({
    required this.text,
    required this.icon,
    required this.onTap,
  });
}
