import 'package:flutter/material.dart';
import '../empleados/presentation/empleados_page.dart';
import '../../shared/widgets/global_bottom_nav.dart';
import '../../shared/widgets/profile_menu_button.dart';
import '../categories/categories_page.dart';
import '../compras/compras_page.dart';
import '../insumos/insumos_page.dart';
import '../proveedores/features/presentation/pages/proveedores_page.dart';
import '../produccion/produccion.dart';
import '../roles/roles_page.dart';
import '../sedes/sedes_page.dart';
import '../categoriainsumo/categorias_page.dart';
import '../products/products_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});
  static const _pink = Color(0xFFFF4FA3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const GlobalBottomNav(),
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
                      color: _pink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  ProfileMenuButton(
                    size: 42,
                    iconSize: 22,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Sede 1',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C1C1C),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Roles
                  const _SH('Roles'), const SizedBox(height: 12),
                  Row(
                    children: [
                      _MI(
                        icon: Icons.admin_panel_settings_outlined,
                        label: 'Roles',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RolesPage()),
                        ),
                        size: 74,
                        iconSize: 30,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFF0F0F0), thickness: 1),
                  const SizedBox(height: 8),
                  // Usuarios
                  const _SH('Usuarios'), const SizedBox(height: 12),
                  Row(
                    children: [
                      _MI(
                        icon: Icons.group_outlined,
                        label: 'Empleados',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EmpleadosPage(),
                          ),
                        ),
                        backgroundColor: const Color(0xFFFF4DB8),
                        shadowColor: const Color(0xFFFF4DB8).withOpacity(0.40),
                        size: 74,
                        iconSize: 30,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFF0F0F0), thickness: 1),
                  const SizedBox(height: 8),

                  // Compras
                  const _SH('Compras'), const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _MI(
                        icon: Icons.grid_view_rounded,
                        label: 'Categorías\nde insumo',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategoriasPage(),
                          ),
                        ),
                        backgroundColor: const Color(0xFFC63A8F),
                        shadowColor: Colors.black.withOpacity(0.20),
                        size: 74,
                        iconSize: 30,
                      ),
                      _MI(
                        icon: Icons.inventory_2_outlined,
                        label: 'Insumo',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InsumosPage(),
                          ),
                        ),
                        backgroundColor: const Color(0xFFC63A8F),
                        shadowColor: Colors.black.withOpacity(0.20),
                        size: 74,
                        iconSize: 30,
                      ),
                      _MI(
                        icon: Icons.local_shipping_outlined,
                        label: 'Proveedores',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProveedoresPage(),
                          ),
                        ),
                        backgroundColor: const Color(0xFFC63A8F),
                        shadowColor: Colors.black.withOpacity(0.20),
                        size: 74,
                        iconSize: 30,
                      ),
                      _MI(
                        icon: Icons.shopping_cart_outlined,
                        label: 'Compras',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ComprasPage(),
                          ),
                        ),
                        backgroundColor: const Color(0xFFC63A8F),
                        shadowColor: Colors.black.withOpacity(0.20),
                        size: 74,
                        iconSize: 30,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFF0F0F0), thickness: 1),
                  const SizedBox(height: 8),

                  // Producción — sin "Órdenes"
                  const _SH('Producción'), const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _MI(
                        icon: Icons.grid_view_rounded,
                        label: 'Categoría\nde producto',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategoriesPage(),
                          ),
                        ),
                        backgroundColor: const Color(0xFFFB8FD0),
                        shadowColor: const Color(0xFFFFC7E6).withOpacity(0.45),
                        size: 74,
                        iconSize: 30,
                      ),
                      _MI(
                        icon: Icons.inventory_2_outlined,
                        label: 'Producto',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProductsPage(),
                          ),
                        ),
                        backgroundColor: const Color(0xFFFB8FD0),
                        shadowColor: const Color(0xFFFFC7E6).withOpacity(0.45),
                        size: 74,
                        iconSize: 30,
                      ),
                      // Terceros → abre Producción en tab Terceros
                      _MI(
                        icon: Icons.group_outlined,
                        label: 'Terceros',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ProduccionApp(openTerceros: true),
                          ),
                        ),
                        backgroundColor: const Color(0xFFFB8FD0),
                        shadowColor: const Color(0xFFFFC7E6).withOpacity(0.45),
                        size: 74,
                        iconSize: 30,
                      ),
                      // Producción → abre Producción en tab Producciones
                      _MI(
                        icon: Icons.work_outline_rounded,
                        label: 'Producción',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProduccionApp(),
                          ),
                        ),
                        backgroundColor: const Color(0xFFFB8FD0),
                        shadowColor: const Color(0xFFFFC7E6).withOpacity(0.45),
                        size: 74,
                        iconSize: 30,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Sedes
                  const _SH('Sedes'), const SizedBox(height: 12),
                  Row(
                    children: [
                      _MI(
                        icon: Icons.location_on_outlined,
                        label: 'Sedes',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SedesPage()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFF0F0F0), thickness: 1),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SH extends StatelessWidget {
  const _SH(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1C1C1C),
    ),
  );
}

class _MI extends StatelessWidget {
  const _MI({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor = const Color(0xFFFF4FA3),
    this.shadowColor = const Color(0x33FF4FA3),
    this.size = 74,
    this.iconSize = 30,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color shadowColor;
  final double size;
  final double iconSize;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        child: Column(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                    spreadRadius: 0.3,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: iconSize),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF444444),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}