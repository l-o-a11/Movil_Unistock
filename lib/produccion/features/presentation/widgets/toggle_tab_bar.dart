import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../state/produccion_state.dart';

class ToggleTabBar extends StatelessWidget {
  final ProduccionTab activeTab;
  final ValueChanged<ProduccionTab> onTabChanged;

  const ToggleTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _Tab(
            label: 'Producciones',
            isActive: activeTab == ProduccionTab.producciones,
            onTap: () => onTabChanged(ProduccionTab.producciones),
          ),
          _Tab(
            label: 'Terceros',
            isActive: activeTab == ProduccionTab.terceros,
            onTap: () => onTabChanged(ProduccionTab.terceros),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha((0.3 * 255).round()),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
