import 'package:flutter/material.dart';
import 'package:movil_unistock/shared/widgets/global_bottom_nav.dart';
import '../../shared/widgets/app_back_button.dart';
import '../../shared/widgets/profile_menu_button.dart';
import '../../shared/utils/responsive.dart';
import 'compra.dart';
import 'compra_card.dart';
import 'compra_detail.dart';
import 'compra_service.dart';

class ComprasPage extends StatefulWidget {
  const ComprasPage({super.key});

  @override
  State<ComprasPage> createState() => _ComprasPageState();
}

class _ComprasPageState extends State<ComprasPage> {
  final CompraService _service = CompraService();
  final TextEditingController _busqueda = TextEditingController();

  List<Compra> _compras = [];
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

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _verDetalle(Compra compra) async {
    // FIX: el listado GET /compras no trae "detalles" (solo GET /compras/:id
    // lo hace — el controller adjunta los ítems ahí). Antes se le pasaba
    // directo el objeto de la lista al modal, así que la tabla de "Detalle
    // de compras" siempre salía vacía. Ahora se pide el detalle completo
    // primero, con un loader mientras carga.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: _pink)),
    );
    try {
      final completa = await _service.getCompraById(compra.id);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // cierra el loader
      showCompraDetail(context, completa);
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // cierra el loader
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cargar el detalle de la compra.'),
          backgroundColor: Colors.red,
        ),
      );
      // Respaldo: al menos muestra lo que ya se tenía en la lista, aunque
      // no traiga items, para no dejar al usuario sin nada.
      showCompraDetail(context, compra);
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
      bottomNavigationBar: const GlobalBottomNav(activeKey: 'compras'),
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            ResponsiveCenter(
              maxWidth: 900,
              child: Padding(
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
                    ProfileMenuButton(size: 42, iconSize: 20),
                  ],
                ),
              ),
            ),

            // ── Buscador ────────────────────────────────────────────────────
            ResponsiveCenter(
              maxWidth: 900,
              child: Padding(
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
                                'Buscar por factura, proveedor o fecha...',
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
                          : ResponsiveCenter(
                              maxWidth: 1100,
                              child: ResponsiveCardGrid(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: _filtrados.length,
                                childAspectRatio: 2.4,
                                itemBuilder: (context, index) {
                                  final compra = _filtrados[index];
                                  return CompraCard(
                                    compra: compra,
                                    onDetailTap: () => _verDetalle(compra),
                                  );
                                },
                              ),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
