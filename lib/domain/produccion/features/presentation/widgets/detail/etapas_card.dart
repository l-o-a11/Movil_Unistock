import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../domain/entities/orden_detail_entity.dart';

/// Tarjeta de flujo de etapas de producción con animación.
/// 
/// Muestra:
/// - 3 etapas: Diseño → Ficha Técnica → Corte
/// - Ícono animado para la etapa activa
/// - Conectores entre etapas
/// - Progreso visual del flujo
/// - Indicador de etapa siguiente
class EtapasCard extends StatefulWidget {
  final OrdenDetailEntity detail;

  const EtapasCard({super.key, required this.detail});

  @override
  State<EtapasCard> createState() => _EtapasCardState();
}

class _EtapasCardState extends State<EtapasCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  static const _etapas = [
    _Etapa(icon: Icons.brush_rounded, label: 'Diseño'),
    _Etapa(icon: Icons.calendar_today_rounded, label: 'Fecha\nTécnica'),
    _Etapa(icon: Icons.content_cut_rounded, label: 'Corte'),
  ];

  @override
  void initState() {
    super.initState();
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progreso de Producción',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(_etapas.length * 2 - 1, (i) {
              // Índices impares → conectores
              if (i.isOdd) {
                final stepIdx = i ~/ 2;
                final done = stepIdx < widget.detail.etapaActual;
                return Expanded(
                  child: AnimatedBuilder(
                    animation: _ac,
                    builder: (_, __) => Container(
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: done ? AppColors.primary : AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                );
              }

              // Índices pares → burbujas de etapa
              final idx = i ~/ 2;
              final done = idx < widget.detail.etapaActual;
              final current = idx == widget.detail.etapaActual;

              return Column(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 400 + idx * 80),
                    curve: Curves.easeOutBack,
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: done || current
                          ? const LinearGradient(
                              colors: [AppColors.primary, Color(0xFFFF6EC7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: done || current ? null : AppColors.chipBackground,
                      borderRadius: BorderRadius.circular(23),
                      boxShadow: done || current
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(77),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: done
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 22)
                        : Icon(
                            _etapas[idx].icon,
                            color: current ? Colors.white : AppColors.iconInactive,
                            size: 20,
                          ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _etapas[idx].label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: done || current
                          ? AppColors.primary
                          : AppColors.textHint,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Etapa {
  final IconData icon;
  final String label;
  const _Etapa({required this.icon, required this.label});
}
