import 'package:flutter/material.dart';
import '../../../../../shared/widgets/global_bottom_nav.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../domain/entities/orden_entity.dart';
import '../../domain/entities/orden_detail_entity.dart';
import '../providers/orden_detail_provider.dart';
import '../widgets/detail/detail_app_bar.dart';
import '../widgets/detail/detail_status_views.dart';
import '../widgets/detail/progreso_card.dart';
import '../widgets/detail/etapas_card.dart';
import '../widgets/detail/flujo_proceso_card.dart';
import '../widgets/detail/produccion_terceros_card.dart';
import '../widgets/detail/referencias_card.dart';
import '../widgets/detail/historial_card.dart';
import '../state/orden_detail_state.dart';

class OrdenDetailPage extends StatefulWidget {
  final OrdenEntity orden;
  const OrdenDetailPage({super.key, required this.orden});

  @override
  State<OrdenDetailPage> createState() => _OrdenDetailPageState();
}

class _OrdenDetailPageState extends State<OrdenDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdenDetailProvider>().loadDetail(widget.orden.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const GlobalBottomNav(activeIndex: 3),
      appBar: DetailAppBar(ordenNumero: widget.orden.numero),
      body: Consumer<OrdenDetailProvider>(
        builder: (context, provider, _) {
          final state = provider.state;
          if (state.isLoading) return const DetailLoadingView();
          if (state.hasError) {
            return DetailErrorView(
              message: state.error ?? 'Error desconocido',
              onRetry: () => provider.loadDetail(widget.orden.id),
            );
          }
          if (!state.isLoaded || state.detail == null)
            return const SizedBox.shrink();
          return _DetailBody(
            ordenId: widget.orden.id,
            state: state,
            onConfirmarEtapa: () => provider.confirmarEtapa(widget.orden.id),
          );
        },
      ),
    );
  }
}

class _DetailBody extends StatefulWidget {
  final String ordenId;
  final OrdenDetailState state;
  final Future<bool> Function() onConfirmarEtapa;
  const _DetailBody({
    required this.ordenId,
    required this.state,
    required this.onConfirmarEtapa,
  });

  OrdenDetailEntity get detail => state.detail!;

  @override
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeAc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );
  late final Animation<double> _fadeAnim = CurvedAnimation(
    parent: _fadeAc,
    curve: Curves.easeOutCubic,
  );

  bool _showFullHistorial = false;

  @override
  void initState() {
    super.initState();
    _fadeAc.forward();
  }

  @override
  void didUpdateWidget(covariant _DetailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final err = widget.state.actionError;
    if (err != null && err != oldWidget.state.actionError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _fadeAc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.detail;
    return FadeTransition(
      opacity: _fadeAnim,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // 1. Resumen: número, cliente, progreso real, sede/tercero, fechas
          ProgresoCard(detail: d),
          const SizedBox(height: 12),

          // 2. Stepper horizontal del flujo completo
          EtapasCard(detail: d),
          const SizedBox(height: 12),

          // 2b. Confirmación de etapa — solo el Empleado confirma que
          // terminó su etapa (ver FlujoProcesoCard). El avance de estado
          // se gestiona desde el web.
          FlujoProcesoCard(
            detail: d,
            isEmpleado: widget.state.isEmpleado,
            isActionLoading: widget.state.isActionLoading,
            onConfirmarEtapa: () async {
              await widget.onConfirmarEtapa();
            },
          ),
          const SizedBox(height: 12),

          // 3. Terceros asignados solo en producción de terceros
          if (d.isTerceros && d.isEnProduccion && d.terceros.isNotEmpty) ...[
            ProduccionTercerosCard(
              esTerceros: d.isTerceros,
              terceros: d.terceros,
            ),
            const SizedBox(height: 12),
          ],

          // 4. Referencias (colores / tallas)
          if (d.referencias.isNotEmpty) ...[
            ReferenciasCard(referencias: d.referencias),
            const SizedBox(height: 12),
          ],

          // 5. Historial con opción de ver todo
          HistorialCard(
            historial: _showFullHistorial
                ? d.historial
                : d.historial.take(4).toList(),
            onVerTodo: () =>
                setState(() => _showFullHistorial = !_showFullHistorial),
          ),
        ],
      ),
    );
  }
}
