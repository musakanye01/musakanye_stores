import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF2457C5);
  static const Color primaryDark = Color(0xFF19449F);

  // Neutral
  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF737B8C);
  static const Color heading = Color(0xFF202938);

  // Semantic
  static const Color success = Color(0xFF16834A);
  static const Color warning = Color(0xFFB7791F);
  static const Color danger = Color(0xFFBA3030);
  static const Color info = Color(0xFF2871C8);

  // Borders and surfaces
  static const Color outline = Color(0xFFE1E5ED);
  static const Color subtleSurface = Color(0xFFF0F2F7);

  static const Color primaryContainer = Color(0xFFE8EEFC);
  static const Color onPrimaryContainer = Color(0xFF173B83);
}
