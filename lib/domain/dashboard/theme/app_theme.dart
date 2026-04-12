import 'package:flutter/material.dart';

abstract class AppTheme {
  // ── Colors ──────────────────────────────────────────────────────
  static const Color titleColor  = Color(0xFF101828);
  static const Color textColor   = Color(0xFF1F1F1F);
  static const Color mutedColor  = Color(0xFF9CA3AF);
  static const Color cardColor   = Colors.white;
  static const Color bgColor     = Color(0xFFF9FAFB);

  static const Color purple = Color(0xFFA78BFA);
  static const Color green  = Color(0xFF4ADE80);
  static const Color pink   = Color(0xFFFF4DB8);

  static const Color purpleLight = Color(0xFFF3F0FF);
  static const Color greenLight  = Color(0xFFECFDF5);
  static const Color pinkLight   = Color(0xFFFFEDF7);

  // ── Shape ───────────────────────────────────────────────────────
  static const double cardRadius = 16.0;

  // ── Shadows ─────────────────────────────────────────────────────
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.5),
      blurRadius: 20,
      spreadRadius: 1,
    ),
  ];

  // ── ThemeData ───────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bgColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: purple,
      background: bgColor,
    ),
    fontFamily: 'SF Pro Display', // Falls back to system font gracefully
  );
}
