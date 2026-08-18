import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../shared/widgets/global_bottom_nav.dart';
import '../../../../../../shared/widgets/app_back_button.dart';
import '../../../../../../shared/widgets/profile_menu_button.dart';
import '../../../../produccion/core/constants/app_colors.dart';
import '../../../terceros_dependencies.dart';
import '../providers/terceros_provider.dart';
import '../widgets/tercero_card.dart';

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

class _TercerosBody extends StatefulWidget {
  const _TercerosBody();

  @override
  State<_TercerosBody> createState() => _TercerosBodyState();
}

class _TercerosBodyState extends State<_TercerosBody> {
  final _ctrl = TextEditingController();

  static const _pink = Color(0xFFFF4FA3);
  static const _bg = Color(0xFFF5F5F7);
  static const _text = Color(0xFF1C1C1E);
  static const _grey = Color(0xFF8E8E93);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const GlobalBottomNav(),
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  AppBackButton(),
                  const SizedBox(width: 14),
                  const Text(
                    'Terceros',
                    style: TextStyle(
                      color: _text,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Spacer(),
                  ProfileMenuButton(size: 42, iconSize: 20),
                ],
              ),
            ),

            // ── Buscador (mismo estilo que los demás módulos) ───────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.search_rounded,
                    color: Color(0xFFAEAEB2),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      onChanged: (v) {
                        context.read<TercerosProvider>().updateSearch(v);
                      },
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Buscar terceros...',
                        hintStyle: TextStyle(
                          color: Color(0xFFAEAEB2),
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Consumer<TercerosProvider>(
                builder: (context, provider, _) {
                  final s = provider.state;

                  if (s.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: _pink),
                    );
                  }

                  if (s.error != null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Colors.red,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s.error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: provider.loadTerceros,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  final filtrados = s.tercerosFiltrados;

                  return RefreshIndicator(
                    color: _pink,
                    onRefresh: provider.loadTerceros,
                    child: filtrados.isEmpty
                        ? ListView(
                            // ListView (no Center) para que RefreshIndicator
                            // funcione aunque la lista esté vacía.
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        s.searchActive
                                            ? Icons.search_off_rounded
                                            : Icons.people_outline,
                                        size: 44,
                                        color: _grey.withAlpha(150),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        s.searchActive
                                            ? 'No se encontraron resultados para "${s.searchQuery}"'
                                            : 'No se encontraron terceros.',
                                        style: const TextStyle(color: _grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount:
                                s.tercerosVisibles.length +
                                (s.hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              final visibles = s.tercerosVisibles;
                              if (index == visibles.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    bottom: 12,
                                  ),
                                  child: Center(
                                    child: OutlinedButton(
                                      onPressed: provider.showMore,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: _pink,
                                        side: BorderSide(
                                          color: _pink.withOpacity(0.4),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text('Ver más'),
                                    ),
                                  ),
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: TerceroCard(
                                  tercero: visibles[index],
                                  animIndex: index,
                                ),
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}