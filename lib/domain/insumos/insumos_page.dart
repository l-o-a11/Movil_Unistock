import 'package:flutter/material.dart';
import 'package:movil_unistock/shared/widgets/global_bottom_nav.dart';
import 'insumo.dart';
import 'insumo_card.dart';
import 'insumo_service.dart';
// import 'detalle_insumo.dart'; // descomenta cuando tengas la pantalla de detalle

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

  static const pink = Color(0xFFE91E8C);

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      setState(() { _loading = true; _error = null; });
      final data = await _service.getInsumos();
      setState(() { _insumos = data; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Insumo> get _filtrados {
    final q = _busqueda.text.toLowerCase();
    if (q.isEmpty) return _insumos;
    return _insumos.where((i) =>
      i.nombre.toLowerCase().contains(q) ||
      i.categoria.toLowerCase().contains(q),
    ).toList();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            'Insumos',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ícono + botón usuario
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE91E8C), Color(0xFFFF6EB4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: pink.withOpacity(0.5),
                      width: 1.5,
                    ),
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: pink,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Título
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Insumos',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Buscador
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
                  const Icon(Icons.search_rounded, color: Color(0xFFAAAAAA), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _busqueda,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Buscar...',
                        hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: 15),
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

          // Lista
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator(color: pink))
              : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : RefreshIndicator(
                    color: pink,
                    onRefresh: _cargar,
                    child: _filtrados.isEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron insumos.',
                            style: TextStyle(color: Color(0xFFAAAAAA)),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filtrados.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final insumo = _filtrados[index];
                            return InsumoCard(
                              insumo: insumo,
                              onDetailTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (_) => DetalleInsumo(insumo: insumo),
                                //   ),
                                // );
                              },
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