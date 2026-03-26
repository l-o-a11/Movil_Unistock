import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../domain/entities/orden_entity.dart';
import '../providers/produccion_provider.dart';
import '../state/produccion_state.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/orden_card.dart';
import '../widgets/toggle_tab_bar.dart';
import '../../../../terceros/features/presentation/providers/terceros_provider.dart';
import '../../../../terceros/features/presentation/widgets/terceros_embedded_list.dart';
import '../../../../../shared/widgets/global_bottom_nav.dart';
import 'calendario_page.dart';

class ProduccionPage extends StatelessWidget {
  const ProduccionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const GlobalBottomNav(),
      appBar: _AppBar(),
      body: Consumer<ProduccionProvider>(
        builder: (context, provider, _) {
          final state = provider.state;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(provider: provider, state: state),
              const SizedBox(height: 4),
              Expanded(child: _Body(provider: provider, state: state)),
            ],
          );
        },
      ),
    );
  }
}

// ── AppBar ────────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 56,
      backgroundColor: AppColors.background,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFFFF6EC7)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          ),
        ),
      ),
      title: const Text('Producción',
          style: TextStyle(fontSize: 16, color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySoft, shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.5)),
            child: const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.primary)),
        ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final ProduccionProvider provider;
  final ProduccionState state;
  const _Header({required this.provider, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Orden de producción',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        AppSearchBar(
          onChanged: (q) {
            if (state.activeTab == ProduccionTab.terceros) {
              context.read<TercerosProvider>().updateSearch(q);
            } else {
              provider.updateSearch(q);
            }
          },
        ),
        const SizedBox(height: 12),
        ToggleTabBar(activeTab: state.activeTab, onTabChanged: provider.changeTab),
        const SizedBox(height: 12),
        if (state.activeTab == ProduccionTab.producciones)
          FilterChipsRow(
            filtroEstado: state.filtroEstado,
            onEstadoTap: () => _showEstadoSheet(context),
            onTercerosTap: () {},
            onCalendarioTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const CalendarioPage())),
          ),
        const SizedBox(height: 16),
      ]),
    );
  }

  void _showEstadoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Filtrar por Estado',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            _EstadoOpt('Todos', state.filtroEstado == null, () { provider.updateFiltroEstado(null); Navigator.pop(context); }),
            _EstadoOpt('En producción', state.filtroEstado == OrdenEstado.enProduccion,
                () { provider.updateFiltroEstado(OrdenEstado.enProduccion); Navigator.pop(context); }),
            _EstadoOpt('Pendiente', state.filtroEstado == OrdenEstado.pendiente,
                () { provider.updateFiltroEstado(OrdenEstado.pendiente); Navigator.pop(context); }),
          ])),
      ),
    );
  }
}

class _EstadoOpt extends StatelessWidget {
  final String label; final bool isSelected; final VoidCallback onTap;
  const _EstadoOpt(this.label, this.isSelected, this.onTap);
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label, style: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
    trailing: isSelected
        ? const Icon(Icons.check_circle, color: AppColors.primary)
        : const Icon(Icons.circle_outlined, color: AppColors.textHint),
    onTap: onTap,
  );
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _Body extends StatelessWidget {
  final ProduccionProvider provider;
  final ProduccionState state;
  const _Body({required this.provider, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.activeTab == ProduccionTab.terceros) return const TercerosEmbeddedList();

    if (state.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

    if (state.error != null) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, color: AppColors.primary, size: 48),
        const SizedBox(height: 12),
        Text(state.error!, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: provider.loadOrdenes,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text('Reintentar')),
      ]));
    }

    if (state.ordenes.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.inbox_outlined, size: 56, color: AppColors.textHint.withAlpha(150)),
        const SizedBox(height: 12),
        const Text('No hay órdenes disponibles',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
      ]));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: state.ordenes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final orden = state.ordenes[i];
        return OrdenCard(
          orden: orden,
          isExpanded: state.isExpanded(orden.id),
          onToggle: () => provider.toggleExpanded(orden.id),
        );
      },
    );
  }
}
