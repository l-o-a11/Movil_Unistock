import 'package:flutter/material.dart';
import 'package:movil_unistock/shared/widgets/global_bottom_nav.dart';
import '../../shared/widgets/app_back_button.dart';
import '../../shared/widgets/profile_menu_button.dart';
import 'compra.dart';
import 'compra_card.dart';
import 'compra_detail.dart';
import 'compra_export_service.dart';
import 'compra_service.dart';

class ComprasPage extends StatefulWidget {
  const ComprasPage({super.key});

  @override
  State<ComprasPage> createState() => _ComprasPageState();
}

class _ComprasPageState extends State<ComprasPage> {
  final CompraService _service = CompraService();
  final CompraExportService _exportService = CompraExportService();
  final TextEditingController _busqueda = TextEditingController();

  List<Compra> _compras = [];
  bool _loading = true;
  bool _exportando = false;
  String? _error;

  static const _pink = Color(0xFFFF4FA3);
  static const _bg = Color(0xFFF5F5F7);
  static const _text = Color(0xFF1C1C1E);

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _exportar() async {
    if (_exportando) return;
    if (_filtrados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay compras para exportar')),
      );
      return;
    }
    setState(() => _exportando = true);
    try {
      await _exportService.exportarYCompartir(_filtrados);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo generar el reporte. Intenta de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  Future<void> _cargar() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final data = await _service.getCompras();
      setState(() {
        _compras = data;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'No se pudo cargar la información de compras.';
        _loading = false;
      });
    }
  }

  List<Compra> get _filtrados {
    final q = _busqueda.text.toLowerCase();
    if (q.isEmpty) return _compras;
    return _compras.where((c) {
      return c.numeroFactura.toLowerCase().contains(q) ||
          (c.proveedorNombre?.toLowerCase().contains(q) ?? false) ||
          c.fecha.toLowerCase().contains(q) ||
          c.observaciones.toLowerCase().contains(q);
    }).toList();
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
                    'Compras',
                    style: TextStyle(
                      color: _text,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _exportar,
                    child: Container(
                      width: 42,
                      height: 42,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: _pink.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: _pink.withOpacity(0.4)),
                      ),
                      child: _exportando
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _pink,
                              ),
                            )
                          : const Icon(
                              Icons.ios_share_rounded,
                              size: 18,
                              color: _pink,
                            ),
                    ),
                  ),
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
                          hintText: 'Buscar por factura, proveedor o fecha...',
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
                                'No se encontraron compras.',
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
                                final compra = _filtrados[index];
                                return CompraCard(
                                  compra: compra,
                                  onDetailTap: () =>
                                      showCompraDetail(context, compra),
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
