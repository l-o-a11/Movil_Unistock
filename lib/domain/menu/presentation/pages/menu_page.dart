import 'package:flutter/material.dart';

import '../../../auth/data/auth_session_repository_impl.dart';
import '../../../auth/domain/auth_session_repository.dart';
import '../../../auth/domain/modulo_constants.dart';
import '../../../auth/presentation/route_guard.dart';
import '../../../categoriainsumo/presentation/pages/categorias_page.dart';
import '../../../compras/presentation/pages/compras_page.dart';
import '../../../empleados/presentation/empleados_page.dart';
import '../../../insumos/presentation/pages/insumos_page.dart';
import '../../../productcategories/presentation/pages/product_categories_page.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../../../proveedores/features/presentation/pages/proveedores_page.dart';
import '../../../roles/presentation/pages/roles_page.dart';
import '../../../sedes/presentation/pages/sedes_page.dart';
import '../../../produccion/produccion.dart';
import '../../../usuarios/presentation/usuarios_page.dart';
import '../../../../shared/widgets/global_bottom_nav.dart';
import '../../../../shared/widgets/profile_menu_button.dart';
import '../widgets/menu_grid.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final AuthSessionRepository _repository = AuthSessionRepositoryImpl();
  late Future<List<String>> _modulosFuture;

  @override
  void initState() {
    super.initState();
    _modulosFuture = _repository.getModulosPermitidos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const GlobalBottomNav(activeKey: 'explorar'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4FA3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const ProfileMenuButton(size: 42, iconSize: 22),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: _modulosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Error cargando módulos:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  final modulos = snapshot.data ?? const <String>[];

                  if (modulos.isEmpty) {
                    return const Center(
                      child: Text(
                        'No tienes módulos asignados.\n(modulos llegó vacío)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return MenuGrid(modulos: modulos);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
