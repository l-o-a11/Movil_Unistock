import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../produccion/core/constants/app_colors.dart';
import '../providers/terceros_provider.dart';
import 'tercero_card.dart';

/// Lista de terceros sin Scaffold — diseñada para embeberse dentro
/// del body de [ProduccionPage] cuando el tab activo es "Terceros".
class TercerosEmbeddedList extends StatelessWidget {
  const TercerosEmbeddedList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TercerosProvider>(
      builder: (context, provider, _) {
        final state = provider.state;

        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
          );
        }

        if (state.error != null) {
          return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline, color: AppColors.primary, size: 48),
              const SizedBox(height: 12),
              Text(state.error!, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: provider.loadTerceros,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Reintentar'),
              ),
            ]),
          );
        }

        if (state.terceros.isEmpty) {
          return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.people_outline, size: 52, color: AppColors.textHint.withAlpha(120)),
              const SizedBox(height: 12),
              const Text('No hay terceros disponibles',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
            ]),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: state.terceros.length,
          itemBuilder: (context, index) => TerceroCard(
            tercero: state.terceros[index],
            animIndex: index,
          ),
        );
      },
    );
  }
}
