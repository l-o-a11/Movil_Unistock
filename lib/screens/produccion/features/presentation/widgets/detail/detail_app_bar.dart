import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// AppBar personalizada para la pantalla de detalle de orden.
class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int ordenNumero;

  const DetailAppBar({super.key, required this.ordenNumero});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
      title: Text(
        'Orden de Producción #$ordenNumero',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
