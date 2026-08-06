import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/widgets/global_bottom_nav.dart';
import '../../../../../shared/widgets/app_back_button.dart';
import '../../../../../shared/widgets/profile_menu_button.dart';
import '../../../app_dependencies.dart';
import '../../../core/constants/app_colors.dart';
import '../../domain/entities/orden_entity.dart';
import '../providers/produccion_provider.dart';
import '../providers/orden_detail_provider.dart';
import '../state/produccion_state.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/orden_card.dart';
import '../widgets/toggle_tab_bar.dart';
import '../../../../../domain/terceros/features/presentation/widgets/terceros_embedded_list.dart';
import '../../../../../domain/terceros/features/presentation/providers/terceros_provider.dart';
import 'orden_detail_page.dart';
import 'calendario_page.dart';

class ProduccionPage extends StatefulWidget {
  const ProduccionPage({super.key});
  @override
  State<ProduccionPage> createState() => _ProduccionPageState();
}

class _ProduccionPageState extends State<ProduccionPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _goToDetail(BuildContext context, OrdenEntity orden) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
            ChangeNotifierProvider<OrdenDetailProvider>(
              create: (_) => AppDependencies.createOrdenDetailProvider(),
              child: OrdenDetailPage(orden: orden),
            ),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: animation.drive(
            Tween(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
          ),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProduccionProvider>(
      builder: (context, provider, _) {
        final state = provider.state;
        final isProduccion = state.activeTab == ProduccionTab.produccion;

        return Scaffold(
          backgroundColor: AppColors.background,
          bottomNavigationBar: const GlobalBottomNav(activeIndex: 3),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: [
                      AppBackButton(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isProduccion ? 'Orden de producción' : 'Terceros',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      // Botón calendario — CalendarioPage ya lee el provider
                      if (isProduccion)
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            PageRouteBuilder(
                              // Proveer explicitamente el ProduccionProvider a la nueva ruta
                              pageBuilder: (_, __, ___) =>
                                  ChangeNotifierProvider<
                                    ProduccionProvider
                                  >.value(
                                    value: provider,
                                    child: const CalendarioPage(),
                                  ),
                              transitionsBuilder: (_, animation, __, child) =>
                                  SlideTransition(
                                    position: animation.drive(
                                      Tween(
                                        begin: const Offset(1, 0),
                                        end: Offset.zero,
                                      ).chain(
                                        CurveTween(curve: Curves.easeOutCubic),
                                      ),
                                    ),
                                    child: child,
                                  ),
                              transitionDuration: const Duration(
                                milliseconds: 320,
                              ),
                            ),
                          ),
                          child: Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                        ),
                      ProfileMenuButton(size: 42, iconSize: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Buscador ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AppSearchBar(
                    controller: _searchCtrl,
                    onChanged: (v) {
                      // Refresca el botón de limpiar del buscador.
                      setState(() {});
                      if (!isProduccion) {
                        // Pestaña Terceros → filtrar la lista de terceros.
                        context.read<TercerosProvider>().updateSearch(v);
                      } else {
                        // Pestaña Producciones → filtrar las órdenes.
                        provider.setSearch(v);
                      }
                    },
                    hintText: 'Buscar...',
                  ),
                ),
                const SizedBox(height: 12),

                // ── Toggle Producciones / Terceros ────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ToggleTabBar(
                    labels: const ['Producciones', 'Terceros'],
                    activeIndex: isProduccion ? 0 : 1,
                    onChanged: (i) {
                      final targetProduccion = i == 0;
                      provider.changeTab(
                        targetProduccion
                            ? ProduccionTab.produccion
                            : ProduccionTab.terceros,
                      );
                      // Al cambiar de pestaña, la barra de búsqueda refleja el
                      // término del proveedor correspondiente y limpia el del
                      // otro para evitar filtrar listas que no se ven.
                      final tercerosProvider = context.read<TercerosProvider>();
                      if (targetProduccion) {
                        tercerosProvider.updateSearch('');
                      } else {
                        provider.setSearch('');
                        _searchCtrl.text = tercerosProvider.state.searchQuery;
                      }
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // ── Filtros por estado (strings reales del backend) ───────
                if (isProduccion) ...[
                  FilterChipsRow(
                    filtroEstado: state.filtroEstado,
                    // estadosDisponibles viene del provider con los estados
                    // reales cargados desde la API
                    estadosDisponibles: provider.estadosDisponibles,
                    onEstadoChanged: provider.setFiltroEstado,
                  ),
                  const SizedBox(height: 10),
                ],

                // ── Lista ─────────────────────────────────────────────────
                Expanded(
                  child: isProduccion
                      ? _OrdenList(
                          state: state,
                          onTap: (o) => _goToDetail(context, o),
                          onToggle: provider.toggleExpanded,
                          onRetry: provider.loadOrdenes,
                        )
                      : const TercerosEmbeddedList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Lista de órdenes ──────────────────────────────────────────────────────────

class _OrdenList extends StatelessWidget {
  final ProduccionState state;
  final ValueChanged<OrdenEntity> onTap;
  final ValueChanged<String> onToggle;
  final VoidCallback onRetry;

  const _OrdenList({
    required this.state,
    required this.onTap,
    required this.onToggle,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.5,
        ),
      );
    }
    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.primary,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              state.error!,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    // Usar ordenesFiltradas (aplica HIDDEN_STATUSES y filtroEstado)
    final ordenes = state.ordenesFiltradas;

    if (ordenes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 52,
              color: AppColors.textHint.withAlpha(120),
            ),
            const SizedBox(height: 12),
            const Text(
              'No hay órdenes',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: ordenes.length,
      itemBuilder: (_, i) {
        final orden = ordenes[i];
        return OrdenCard(
          orden: orden,
          isExpanded: state.isExpanded(orden.id),
          onToggle: () => onToggle(orden.id),
          onTap: () => onTap(orden),
          animIndex: i,
        );
      },
    );
  }
}
