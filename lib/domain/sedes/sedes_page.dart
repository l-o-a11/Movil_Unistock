import 'package:flutter/material.dart';
import 'package:movil_unistock/shared/widgets/global_bottom_nav.dart';
import '../../shared/widgets/app_back_button.dart';
import '../../shared/widgets/profile_menu_button.dart';
import 'sede.dart';
import 'sede_card.dart';
import 'sede_detail.dart';
import 'sede_service.dart';

class SedesPage extends StatefulWidget {
  const SedesPage({super.key});

  @override
  State<SedesPage> createState() => _SedesPageState();
}

class _SedesPageState extends State<SedesPage> {
  final SedeService _service = SedeService();
  final TextEditingController _busqueda = TextEditingController();

  List<Sede> _sedes = [];
  bool _loading = true;
  String? _error;

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
      });
      final data = await _service.getSedes();
      if (!mounted) return;
      setState(() {
        _sedes = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar la información de sedes.';
        _loading = false;
      });
    }
  }

  List<Sede> get _filtrados {
    final q = _busqueda.text.toLowerCase();
    if (q.isEmpty) return _sedes;
    return _sedes.where((r) {
      return r.nombre.toLowerCase().contains(q) ||
          r.ciudad.toLowerCase().contains(q) ||
          r.barrio.toLowerCase().contains(q) ||
          r.direccion.toLowerCase().contains(q) ||
          r.telefono.toLowerCase().contains(q);
    }).toList();
  }

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
                    'Sedes',
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
                        controller: _busqueda,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText:
                              'Buscar por nombre, ciudad, barrio o dirección...',
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
                                'No se encontraron sedes.',
                                style: TextStyle(color: Color(0xFF8E8E93)),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _filtrados.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final sede = _filtrados[index];
                                return SedeCard(
                                  sede: sede,
                                  onDetailTap: () =>
                                      showSedeDetail(context, sede),
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