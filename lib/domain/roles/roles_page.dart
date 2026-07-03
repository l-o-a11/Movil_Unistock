import 'package:flutter/material.dart';
import 'package:movil_unistock/shared/widgets/global_bottom_nav.dart';
import '../../shared/widgets/app_back_button.dart';
import '../../shared/widgets/profile_menu_button.dart';
import 'rol.dart';
import 'rol_card.dart';
import 'rol_detail.dart';
import 'rol_service.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  final RolService _service = RolService();
  final TextEditingController _busqueda = TextEditingController();

  List<Rol> _roles = [];
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
      final data = await _service.getRoles();
      setState(() {
        _roles = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Rol> get _filtrados {
    final q = _busqueda.text.toLowerCase();
    if (q.isEmpty) return _roles;
    return _roles.where((r) {
      return r.nombre.toLowerCase().contains(q) ||
          r.descripcion.toLowerCase().contains(q);
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
                  'Roles',
                  style: TextStyle(
                    color: _text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const Spacer(),
                 ProfileMenuButton(
                  size: 42,
                  iconSize: 20,
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
                  const Icon(Icons.search_rounded,
                      color: Color(0xFFAAAAAA), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _busqueda,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nombre o descripción...',
                        hintStyle: TextStyle(
                            color: Color(0xFFAAAAAA), fontSize: 15),
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
                ? const Center(
                    child: CircularProgressIndicator(color: _pink))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: Colors.red, size: 40),
                            const SizedBox(height: 8),
                            Text(_error!,
                                style:
                                    const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            TextButton(
                                onPressed: _cargar,
                                child: const Text('Reintentar')),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: _pink,
                        onRefresh: _cargar,
                        child: _filtrados.isEmpty
                            ? const Center(
                                child: Text(
                                  'No se encontraron roles.',
                                  style:
                                      TextStyle(color: Color(0xFFAAAAAA)),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                itemCount: _filtrados.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final rol = _filtrados[index];
                                  return RolCard(
                                    rol: rol,
                                    onDetailTap: () =>
                                        showRolDetail(context, rol),
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
