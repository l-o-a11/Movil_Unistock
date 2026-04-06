import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary (rosa) ──────────────────────────────────────────────
  static const Color primary = Color(0xFFE91E8C);
  static const Color primaryLight = Color(0xFFFCE4F3);
  static const Color primarySoft = Color(0xFFFFF0F8);
  static const Color primaryBorder = Color(0xFFE91E8C); // alias semántico

  // ── Estados ─────────────────────────────────────────────────────
  static const Color pending = Color(0xFF8E8E93);
  static const Color pendingLight = Color(0xFFF2F2F2);

  // ── Superficies ─────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE8E8E8);

  // ── Texto ───────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFADB5BD);

  // ── Íconos / divisores ──────────────────────────────────────────
  static const Color iconInactive = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFF0F0F0);

  // ── Nav bar ─────────────────────────────────────────────────────
  static const Color navBar = Color(0xFFFFFFFF);
  static const Color navBarBorder = Color(0xFFEEEEEE);

  // ── Chips / búsqueda ────────────────────────────────────────────
  static const Color chipBackground = Color(0xFFF0F0F0);
  static const Color chipText = Color(0xFF555555);
  static const Color searchBackground = Color(0xFFF2F2F2);
}
