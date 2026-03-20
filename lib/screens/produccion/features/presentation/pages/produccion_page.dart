import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../domain/entities/orden_entity.dart';
import '../providers/produccion_provider.dart';
import '../state/produccion_state.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/orden_card.dart';
import '../widgets/toggle_tab_bar.dart';

class ProduccionPage extends StatefulWidget {
  const ProduccionPage({super.key});

  @override
  State<ProduccionPage> createState() => _ProduccionPageState();
}

class _ProduccionPageState extends State<ProduccionPage> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<ProduccionProvider>(
        builder: (context, provider, _) {
          final state = provider.state;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(provider, state),
              const SizedBox(height: 4),
              Expanded(child: _buildBody(provider, state)),
            ],
          );
        },
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      toolbarHeight: 56,
      backgroundColor: AppColors.background,
      title: const Text(
        'Produccion',
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFFFF6EC7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ProduccionProvider provider, ProduccionState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Orden de producción',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          AppSearchBar(onChanged: provider.updateSearch),
          const SizedBox(height: 12),
          ToggleTabBar(
            activeTab: state.activeTab,
            onTabChanged: provider.changeTab,
          ),
          const SizedBox(height: 12),
          FilterChipsRow(
            filtroEstado: state.filtroEstado,
            onEstadoTap: () => _showEstadoSheet(context, provider, state),
            onTercerosTap: () {},
            onCalendarioTap: () => _showDatePicker(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBody(ProduccionProvider provider, ProduccionState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.primary, size: 48),
            const SizedBox(height: 12),
            Text(
              state.error!,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: provider.loadOrdenes,
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

    if (state.ordenes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 56,
              color: AppColors.textHint.withAlpha((0.6 * 255).round()),
            ),
            const SizedBox(height: 12),
            const Text(
              'No hay órdenes disponibles',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: state.ordenes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final orden = state.ordenes[index];
        return OrdenCard(
          orden: orden,
          isExpanded: state.isExpanded(orden.id),
          onToggle: () => provider.toggleExpanded(orden.id),
        );
      },
    );
  }

  void _showEstadoSheet(
    BuildContext context,
    ProduccionProvider provider,
    ProduccionState state,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filtrar por Estado',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _EstadoOption(
                  label: 'Todos',
                  isSelected: state.filtroEstado == null,
                  onTap: () {
                    provider.updateFiltroEstado(null);
                    Navigator.pop(context);
                  },
                ),
                _EstadoOption(
                  label: 'En producción',
                  isSelected: state.filtroEstado == OrdenEstado.enProduccion,
                  onTap: () {
                    provider.updateFiltroEstado(OrdenEstado.enProduccion);
                    Navigator.pop(context);
                  },
                ),
                _EstadoOption(
                  label: 'Pendiente',
                  isSelected: state.filtroEstado == OrdenEstado.pendiente,
                  onTap: () {
                    provider.updateFiltroEstado(OrdenEstado.pendiente);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
  }
}

class _EstadoOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _EstadoOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : const Icon(Icons.circle_outlined, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
