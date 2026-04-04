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
import '../widgets/detail/produccion_terceros_card.dart';
import '../widgets/detail/referencias_card.dart';
import '../widgets/detail/historial_card.dart';
import '../widgets/detail/ficha_costos_card.dart';

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
      // Bolsita (producción) activa = index 3
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
          if (!state.isLoaded || state.detail == null) return const SizedBox.shrink();
          return _DetailBody(detail: state.detail!);
        },
      ),
    );
  }
}

class _DetailBody extends StatefulWidget {
  final OrdenDetailEntity detail;
  const _DetailBody({required this.detail});
  @override State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeAc = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 480));
  late final Animation<double> _fadeAnim = CurvedAnimation(
    parent: _fadeAc, curve: Curves.easeOutCubic);

  @override void initState() { super.initState(); _fadeAc.forward(); }
  @override void dispose() { _fadeAc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // 1. Progreso general
          ProgresoCard(detail: widget.detail),
          const SizedBox(height: 12),

          // 2. Etapas (Diseño → FechaTécnica → Corte)
          EtapasCard(detail: widget.detail),
          const SizedBox(height: 12),

          // 3. Producción con terceros
          ProduccionTercerosCard(onTap: () {}),
          const SizedBox(height: 12),

          // 4. Referencias
          if (widget.detail.referencias.isNotEmpty) ...[
            ReferenciasCard(referencias: widget.detail.referencias),
            const SizedBox(height: 12),
          ],

          // 5. Historial
          HistorialCard(
            historial: widget.detail.historial,
            onVerTodo: () {},
          ),
          const SizedBox(height: 12),

          // 6. Ficha técnica y costos — siempre visible
          FichaCostosCard(ficha: widget.detail.fichaCosto),
        ],
      ),
    );
  }
}
