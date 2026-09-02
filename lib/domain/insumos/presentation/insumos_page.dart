import 'package:flutter/material.dart';
import 'package:movil_unistock/shared/widgets/global_bottom_nav.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/profile_menu_button.dart';
import '../../../shared/utils/paginated_list.dart';
import '../domain/insumo.dart';
import '../data/insumo_service.dart';
import 'insumo_card.dart';
import 'insumo_detail.dart';

class InsumosPage extends StatefulWidget {
  const InsumosPage({super.key});

  @override
  State<InsumosPage> createState() => _InsumosPageState();
}

class _InsumosPageState extends State<InsumosPage> {
  final InsumoService _service = InsumoService();
  final TextEditingController _busqueda = TextEditingController();

  List<Insumo> _insumos = [];
  bool _loading = true;
  String? _error;
  int _visibleCount = 5;

  static const _pink = Color(0xFFFF4FA3);
  static const _bg = Color(0xFFF5F5F7);
  static const _text = Color(0xFF1C1C1E);

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      if (!mounted) return;
      setState(() {
        _loading = true;
        _error = null;
        _visibleCount = 5;
      });
      final data = await _service.getInsumos();
      if (!mounted) return;
      setState(() {
        _insumos = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar la información de insumos.';
        _loading = false;
      });
    }
  }

  List<Insumo> get _filtrados {
    final q = _busqueda.text.toLowerCase();
    if (q.isEmpty) return _insumos;
    return _insumos.where((i) {
      return i.nombre.toLowerCase().contains(q) ||
          i.categoria.toLowerCase().contains(q) ||
          i.medida.toLowerCase().contains(q);
    }).toList();
  }

  List<Insumo> get _visibles =>
      paginateItems(_filtrados, visibleCount: _visibleCount, pageSize: 5);

  bool get _hayMas =>
      hasMoreItems(_filtrados, visibleCount: _visibleCount, pageSize: 5);

  @override
  void dispose() {
    _busqueda.dispose();
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
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  AppBackButton(),
                  const SizedBox(width: 14),
                  const Text(
                    'Insumos',
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

            // ── Buscador ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
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
                        controller: _busqueda,
                        onChanged: (_) => setState(() => _visibleCount = 5),
                        decoration: const InputDecoration(
                          hintText: 'Buscar por nombre, categoría...',
                          hintStyle: TextStyle(
                            color: Color(0xFFAEAEB2),
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Lista ───────────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: _pink))
                  : _error != null
                  ? Center(
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
                            _error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: _pink,
                      onRefresh: _cargar,
                      child: _filtrados.isEmpty
                          ? const Center(
                              child: Text(
                                'No se encontraron insumos.',
                                style: TextStyle(color: Color(0xFF8E8E93)),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _visibles.length + (_hayMas ? 1 : 0),
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                if (index == _visibles.length) {
                                  return Center(
                                    child: OutlinedButton(
                                      onPressed: () => setState(() {
                                        _visibleCount = nextVisibleCount(
                                          _filtrados,
                                          visibleCount: _visibleCount,
                                          pageSize: 5,
                                        );
                                      }),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: _pink,
                                        side: BorderSide(
                                          color: _pink.withValues(alpha: 0.4),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Ver más'),
                                    ),
                                  );
                                }
                                final insumo = _visibles[index];
                                return InsumoCard(
                                  insumo: insumo,
                                  onDetailTap: () =>
                                      showInsumoDetail(context, insumo),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
