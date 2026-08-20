import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../produccion/core/constants/app_colors.dart';
import '../../../../produccion/features/presentation/widgets/app_search_bar.dart';
import '../../../../../../shared/widgets/app_back_button.dart';
import '../../../../../../shared/widgets/profile_menu_button.dart';
import '../providers/terceros_provider.dart';
import '../../../terceros_dependencies.dart';
import '../widgets/tercero_card.dart';

/// Página standalone de terceros.
/// Se navega desde el menú principal.
/// Crea su propio [TercerosProvider] via [TercerosDependencies].
///
/// Muestra:
/// - Buscador de terceros
/// - Lista de tarjetas de terceros
/// - Modal resumen al presionar tarjeta
class TercerosPage extends StatelessWidget {
  const TercerosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TercerosProvider>(
      create: (_) => TercerosDependencies.createTercerosProvider(),
      child: const _TercerosBody(),
    );
  }
}

/// Body interno con controlador de búsqueda.
class _TercerosBody extends StatefulWidget {
  const _TercerosBody();

  @override
  State<_TercerosBody> createState() => _TercerosBodyState();
}

class _TercerosBodyState extends State<_TercerosBody> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: AppColors.background,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: AppBackButton(),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFFFF6EC7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.people_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Terceros',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ProfileMenuButton(size: 42, iconSize: 20),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: AppSearchBar(
              controller: _ctrl,
              onChanged: (v) {
                setState(() {});
                context.read<TercerosProvider>().updateSearch(v);
              },
              hintText: 'Buscar...',
            ),
          ),
          // Title
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Terceros',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
          // List
          Expanded(
            child: Consumer<TercerosProvider>(
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

                if (s.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.primary,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          s.error!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: provider.loadTerceros,
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

                final filtered = s.tercerosFiltrados;
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          s.searchActive
                              ? Icons.search_off_rounded
                              : Icons.people_outline,
                          size: 52,
                          color: AppColors.textHint.withAlpha(120),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          s.searchActive
                              ? 'No se encontraron resultados para "${s.searchQuery}"'
                              : 'No hay terceros disponibles',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final visibles = s.tercerosVisibles;
                final hasMore = s.hasMore;

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: visibles.length + (hasMore ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    if (i >= visibles.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 12),
                        child: Center(
                          child: OutlinedButton(
                            onPressed: provider.showMore,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(
                                color: AppColors.primary.withOpacity(0.4),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                            ),
                            child: const Text(
                              'Ver más',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return TerceroCard(tercero: visibles[i], animIndex: i);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}