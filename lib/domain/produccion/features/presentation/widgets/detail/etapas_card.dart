import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../domain/entities/orden_detail_entity.dart';

/// Stepper HORIZONTAL con scroll — mismo flujo de 8 estados que la web.
/// El estado actual queda centrado automáticamente al cargar.
class EtapasCard extends StatefulWidget {
  final OrdenDetailEntity detail;
  const EtapasCard({super.key, required this.detail});
  @override
  State<EtapasCard> createState() => _EtapasCardState();
}

class _EtapasCardState extends State<EtapasCard> {
  final _scrollCtrl = ScrollController();

  static const _stepW = 90.0; // ancho de cada paso

  @override
  void initState() {
    super.initState();
    // Centrar el estado actual al renderizar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idx = widget.detail.estadoIndex;
      if (idx <= 0) return;
      final offset = (idx * _stepW) - (_scrollCtrl.position.viewportDimension / 2) + (_stepW / 2);
      _scrollCtrl.animateTo(
        offset.clamp(0.0, _scrollCtrl.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() { _scrollCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final currentIdx = widget.detail.estadoIndex;
    final estados    = kProductionStates;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Container(width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.linear_scale_rounded, color: AppColors.primary, size: 17)),
            const SizedBox(width: 10),
            const Expanded(child: Text('Flujo de producción',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700))),
            // Badge etapa actual
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: currentIdx >= 0 ? AppColors.primaryLight : AppColors.chipBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                currentIdx >= 0 ? estados[currentIdx] : widget.detail.estado,
                style: TextStyle(
                  color: currentIdx >= 0 ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 11, fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // Stepper horizontal con scroll
          SizedBox(
            height: 88,
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(estados.length * 2 - 1, (i) {
                  // Índices impares → conectores
                  if (i.isOdd) {
                    final stepIdx = i ~/ 2;
                    final done = currentIdx >= 0 && stepIdx < currentIdx;
                    return SizedBox(
                      width: 24,
                      child: Column(children: [
                        const SizedBox(height: 14), // alinear con centro del círculo
                        Container(
                          height: 2.5,
                          width: 24,
                          decoration: BoxDecoration(
                            color: done ? AppColors.primary : AppColors.divider,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ]),
                    );
                  }

                  // Índices pares → pasos
                  final idx     = i ~/ 2;
                  final isDone    = currentIdx >= 0 && idx < currentIdx;
                  final isCurrent = idx == currentIdx;

                  return SizedBox(
                    width: _stepW,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Círculo
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300 + idx * 40),
                          curve: Curves.easeOutBack,
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isCurrent || isDone
                                ? const LinearGradient(
                                    colors: [AppColors.primary, Color(0xFFFF6EC7)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight)
                                : null,
                            color: isCurrent || isDone ? null : AppColors.chipBackground,
                            border: isCurrent || isDone
                                ? null
                                : Border.all(color: AppColors.divider, width: 1.5),
                            boxShadow: isCurrent
                                ? [BoxShadow(color: AppColors.primary.withAlpha(80),
                                    blurRadius: 12, offset: const Offset(0, 4))]
                                : null,
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                                : isCurrent
                                    ? const Icon(Icons.circle, color: Colors.white, size: 10)
                                    : Text('${idx + 1}',
                                        style: const TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 10, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Etiqueta
                        Text(
                          estados[idx],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isCurrent
                                ? AppColors.primary
                                : isDone
                                    ? AppColors.textPrimary
                                    : AppColors.textHint,
                            fontSize: 10,
                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
