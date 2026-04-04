import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Selector de tabs (toggle bar) entre Producciones y Terceros.
/// 
/// Características:
/// - Dos opciones intercambiables
/// - Indicador visual animado con sombra
/// - Reutilizable para otros tabs
/// - Estilo moderno con fondo de chip
class ToggleTabBar extends StatelessWidget {
  final List<String> labels;
  final int activeIndex;
  final ValueChanged<int> onChanged;
  const ToggleTabBar({
    super.key,
    required this.labels,
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
          color: AppColors.chipBackground,
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: labels.asMap().entries.map((e) {
          final active = e.key == activeIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: active ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: active
                      ? [BoxShadow(color: Colors.black.withAlpha(12),
                          blurRadius: 6, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Text(e.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: active ? AppColors.textPrimary : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
