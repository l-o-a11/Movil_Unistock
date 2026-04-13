import 'package:flutter/material.dart';
import 'package:movil_unistock/shared/widgets/global_bottom_nav.dart';
import '../../shared/widgets/app_back_button.dart';
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

  static const _pink = Color(0xFFE91E8C);
  static const _bg = Color(0xFFF5F5F7);
  static const _text = Color(0xFF1C1C1E);

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final data = await _service.getSedes();
      setState(() {
        _sedes = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
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
      body: Column(
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
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFFF8ACD),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4DA6).withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_2_sharp,
                    color: Color(0xFFFF4DA6),
                    size: 20,
                  ),
                ),
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
                    color: Color(0xFFAAAAAA),
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
                          color: Color(0xFFAAAAAA),
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
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _cargar,
                          child: const Text('Reintentar'),
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
                              style: TextStyle(color: Color(0xFFAAAAAA)),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }
}
