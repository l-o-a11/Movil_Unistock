import 'package:flutter/material.dart';
import '../../../../../../shared/widgets/app_back_button.dart';
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
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(child: AppBackButton()),
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
            width: 42, height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFFF8ACD), width: 2),
              boxShadow: [BoxShadow(color: const Color(0xFFFF4DA6).withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.person_2_sharp, size: 20, color: Color(0xFFFF4DA6)),
          ),
        ),
      ],
    );
  }
}
