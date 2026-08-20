import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../produccion/core/constants/app_colors.dart';
import '../../domain/entities/tercero_entity.dart';
import '../providers/tercero_detail_provider.dart';
import '../../../terceros_dependencies.dart';
import 'tercero_detail/tercero_info_tab.dart';
import 'tercero_detail/tercero_producciones_tab.dart';

class TerceroCard extends StatelessWidget {
  final TerceroEntity tercero;
  final int animIndex;
  const TerceroCard({super.key, required this.tercero, this.animIndex = 0});

  void _openDetail(BuildContext context) {
    // ─── Solución: showModalBottomSheet con backdrop manual ───────────────────
    // showGeneralDialog con Stack(StackFit.expand) no tiene constraints
    // acotados y provoca overflow infinito. showModalBottomSheet sí los da.
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // permite altura personalizada
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.38),
      useSafeArea: false,
      builder: (ctx) => ChangeNotifierProvider<TerceroDetailProvider>(
        create: (_) => TercerosDependencies.createTerceroDetailProvider(),
        child: _TerceroSheet(tercero: tercero),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + animIndex * 65),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 18),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFF4FA3).withOpacity(0.22),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: const Color(0xFFFF4DA6).withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CÓDIGO: ${tercero.codigo}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tercero.nombre,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tercero.contacto,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _openDetail(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary.withAlpha(60),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.remove_red_eye_outlined,
                        size: 15,
                        color: AppColors.primary.withAlpha(180),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ver detalles',
                        style: TextStyle(
                          color: AppColors.primary.withAlpha(220),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sheet del detalle (mostrado desde abajo) ─────────────────────────────────

class _TerceroSheet extends StatefulWidget {
  final TerceroEntity tercero;
  const _TerceroSheet({required this.tercero});

  @override
  State<_TerceroSheet> createState() => _TerceroSheetState();
}

class _TerceroSheetState extends State<_TerceroSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tc = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TerceroDetailProvider>().loadDetail(widget.tercero.id);
    });
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // DraggableScrollableSheet da altura acotada correctamente.
    // Tamaño reducido para ahorrar espacio en pantalla: el sheet arranca
    // más bajo y el usuario puede arrastrarlo hasta un máximo más
    // compacto que antes.
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.7,
      snap: true,
      snapSizes: const [0.55, 0.7],
      builder: (ctx, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // ── Drag handle ────────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // ── Header ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 2, 18, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CÓDIGO: ${widget.tercero.codigo}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.4,
                            ),
                          ),
                          Text(
                            widget.tercero.nombre,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            widget.tercero.contacto,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.chipBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              // ── Tab bar ─────────────────────────────────────────────────────
              Container(
                color: AppColors.background,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.chipBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TabBar(
                    controller: _tc,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(text: 'Información general'),
                      Tab(text: 'Producciones'),
                    ],
                  ),
                ),
              ),
              // ── Content (ocupa el resto del sheet) ─────────────────────────
              Expanded(
                child: Consumer<TerceroDetailProvider>(
                  builder: (_, provider, __) {
                    final s = provider.state;

                    if (s.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2.5,
                        ),
                      );
                    }

                    if (s.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              s.error ?? 'Error',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () =>
                                  provider.loadDetail(widget.tercero.id),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!s.isLoaded || s.detail == null) {
                      return const SizedBox.shrink();
                    }

                    return TabBarView(
                      controller: _tc,
                      children: [
                        TerceroInfoTab(detail: s.detail!),
                        TerceroProduccionesTab(
                          producciones: s.detail!.producciones,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}