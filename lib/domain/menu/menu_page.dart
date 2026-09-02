import 'package:flutter/material.dart';
import '../auth/data/auth_session_repository_impl.dart';
import '../auth/domain/auth_session_repository.dart';
import '../auth/domain/modulo_constants.dart';
import '../auth/presentation/route_guard.dart';
import '../empleados/presentation/empleados_page.dart';
import '../usuarios/presentation/usuarios_page.dart';
import '../../shared/widgets/global_bottom_nav.dart';
import '../../shared/widgets/profile_menu_button.dart';
import '../product_categories/presentation/product_categories_page.dart';
import '../compras/domain/compra.dart';
import '../compras/presentation/compras_page.dart';
import '../insumos/presentation/insumos_page.dart';
import '../proveedores/features/presentation/pages/proveedores_page.dart';
import '../produccion/produccion.dart';
import '../roles/presentation/roles_page.dart';
import '../sedes/presentation/sedes_page.dart';
import '../categoriainsumo/presentation/categorias_page.dart';
import '../products/presentation/products_page.dart';

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

                  return _MenuList(modulos: modulos);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Calcula tamaños de ícono/tipografía/columnas según el ancho disponible,
/// para que en celulares angostos (incluso los alargados tipo "candy bar")
/// los botones no se amontonen ni el texto se vea apretado.
class _GridMetrics {
  final double itemSize;
  final double iconSize;
  final double fontSize;
  final double spacing;
  final double soloSize;
  final double soloIconSize;
  final double soloFontSize;

  const _GridMetrics({
    required this.itemSize,
    required this.iconSize,
    required this.fontSize,
    required this.spacing,
    required this.soloSize,
    required this.soloIconSize,
    required this.soloFontSize,
  });

  /// [contentWidth] es el ancho ya disponible dentro del padding horizontal
  /// del ListView (16 a cada lado).
  factory _GridMetrics.of(double contentWidth) {
    final bool angosto = contentWidth < 340; // ~360px de pantalla real
    final int columns = angosto ? 3 : 4;
    const double spacing = 14.0;

    final double rawItemSize =
        (contentWidth - spacing * (columns - 1)) / columns;
    final double itemSize = rawItemSize.clamp(56.0, 78.0);

    return _GridMetrics(
      itemSize: itemSize,
      iconSize: itemSize * 0.40,
      fontSize: angosto ? 11.0 : 12.0,
      spacing: spacing,
      soloSize: angosto ? 64.0 : 74.0,
      soloIconSize: angosto ? 26.0 : 30.0,
      soloFontSize: angosto ? 11.0 : 12.0,
    );
  }
}

class _MenuList extends StatelessWidget {
  const _MenuList({required this.modulos});

  final List<String> modulos;

  bool _tiene(String modulo) => modulos.contains(modulo);

  @override
  Widget build(BuildContext context) {
    final mostrarRoles = _tiene(moduloRoles);
    final mostrarEmpleados = _tiene(moduloEmpleados);
    final mostrarSedes = _tiene(moduloSedes);

    return LayoutBuilder(
      builder: (context, constraints) {
        // El ListView de abajo tiene padding horizontal de 16 a cada lado.
        final metrics = _GridMetrics.of(constraints.maxWidth - 32);

        final comprasItems = <Widget>[
          if (_tiene(moduloCategoriasInsumos))
            _MI(
              icon: Icons.grid_view_rounded,
              label: 'Categorías\nde insumo',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RouteGuard(
                    requiredModule: moduloCategoriasInsumos,
                    child: CategoriasPage(),
                  ),
                ),
              ),
              backgroundColor: const Color(0xFFC63A8F),
              shadowColor: Colors.black.withOpacity(0.20),
              size: metrics.itemSize,
              iconSize: metrics.iconSize,
              fontSize: metrics.fontSize,
            ),
          if (_tiene(moduloInsumos))
            _MI(
              icon: Icons.inventory_2_outlined,
              label: 'Insumo',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RouteGuard(
                    requiredModule: moduloInsumos,
                    child: InsumosPage(),
                  ),
                ),
              ),
              backgroundColor: const Color(0xFFC63A8F),
              shadowColor: Colors.black.withOpacity(0.20),
              size: metrics.itemSize,
              iconSize: metrics.iconSize,
              fontSize: metrics.fontSize,
            ),
          if (_tiene(moduloProveedores))
            _MI(
              icon: Icons.local_shipping_outlined,
              label: 'Proveedores',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RouteGuard(
                    requiredModule: moduloProveedores,
                    child: ProveedoresPage(),
                  ),
                ),
              ),
              backgroundColor: const Color(0xFFC63A8F),
              shadowColor: Colors.black.withOpacity(0.20),
              size: metrics.itemSize,
              iconSize: metrics.iconSize,
              fontSize: metrics.fontSize,
            ),
          if (_tiene(moduloCompras))
            _MI(
              icon: Icons.shopping_cart_outlined,
              label: 'Compras',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RouteGuard(
                    requiredModule: moduloCompras,
                    child: ComprasPage(),
                  ),
                ),
              ),
              backgroundColor: const Color(0xFFC63A8F),
              shadowColor: Colors.black.withOpacity(0.20),
              size: metrics.itemSize,
              iconSize: metrics.iconSize,
              fontSize: metrics.fontSize,
            ),
        ];

        final produccionItems = <Widget>[
          if (_tiene(moduloCategoriasProductos))
            _MI(
              icon: Icons.grid_view_rounded,
              label: 'Categoría\nde producto',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RouteGuard(
                    requiredModule: moduloCategoriasProductos,
                    child: ProductCategoriesPage(),
                  ),
                ),
              ),
              backgroundColor: const Color(0xFFFB8FD0),
              shadowColor: const Color(0xFFFFC7E6).withOpacity(0.45),
              size: metrics.itemSize,
              iconSize: metrics.iconSize,
              fontSize: metrics.fontSize,
            ),
          if (_tiene(moduloProductos))
            _MI(
              icon: Icons.inventory_2_outlined,
              label: 'Producto',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RouteGuard(
                    requiredModule: moduloProductos,
                    child: ProductsPage(),
                  ),
                ),
              ),
              backgroundColor: const Color(0xFFFB8FD0),
              shadowColor: const Color(0xFFFFC7E6).withOpacity(0.45),
              size: metrics.itemSize,
              iconSize: metrics.iconSize,
              fontSize: metrics.fontSize,
            ),
          if (_tiene(moduloTerceros))
            _MI(
              icon: Icons.group_outlined,
              label: 'Terceros',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RouteGuard(
                    requiredModule: moduloTerceros,
                    child: ProduccionApp(openTerceros: true),
                  ),
                ),
              ),
              backgroundColor: const Color(0xFFFB8FD0),
              shadowColor: const Color(0xFFFFC7E6).withOpacity(0.45),
              size: metrics.itemSize,
              iconSize: metrics.iconSize,
              fontSize: metrics.fontSize,
            ),
          if (_tiene(moduloProduccion))
            _MI(
              icon: Icons.work_outline_rounded,
              label: 'Producción',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RouteGuard(
                    requiredModule: moduloProduccion,
                    child: ProduccionApp(),
                  ),
                ),
              ),
              backgroundColor: const Color(0xFFFB8FD0),
              shadowColor: const Color(0xFFFFC7E6).withOpacity(0.45),
              size: metrics.itemSize,
              iconSize: metrics.iconSize,
              fontSize: metrics.fontSize,
            ),
        ];

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            if (mostrarRoles) ...[
              const _SH('Roles'),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MI(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Roles',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RouteGuard(
                          requiredModule: moduloRoles,
                          child: RolesPage(),
                        ),
                      ),
                    ),
                    size: metrics.soloSize,
                    iconSize: metrics.soloIconSize,
                    fontSize: metrics.soloFontSize,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFF0F0F0), thickness: 1),
              const SizedBox(height: 8),
            ],

            if (mostrarEmpleados) ...[
              const _SH('Usuarios'),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MI(
                    icon: Icons.person_outline_rounded,
                    label: 'Usuarios',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RouteGuard(
                          requiredModule: moduloEmpleados,
                          child: UsuariosPage(),
                        ),
                      ),
                    ),
                    backgroundColor: const Color(0xFFFF4DB8),
                    shadowColor: const Color(0xFFFF4DB8).withOpacity(0.40),
                    size: metrics.soloSize,
                    iconSize: metrics.soloIconSize,
                    fontSize: metrics.soloFontSize,
                  ),
                  SizedBox(width: metrics.spacing + 2),
                  _MI(
                    icon: Icons.group_outlined,
                    label: 'Empleados',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RouteGuard(
                          requiredModule: moduloEmpleados,
                          child: EmpleadosPage(),
                        ),
                      ),
                    ),
                    backgroundColor: const Color(0xFFFF4DB8),
                    shadowColor: const Color(0xFFFF4DB8).withOpacity(0.40),
                    size: metrics.soloSize,
                    iconSize: metrics.soloIconSize,
                    fontSize: metrics.soloFontSize,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFF0F0F0), thickness: 1),
              const SizedBox(height: 8),
            ],

            if (comprasItems.isNotEmpty) ...[
              const _SH('Compras'),
              const SizedBox(height: 12),
              Wrap(
                spacing: metrics.spacing,
                runSpacing: 16,
                children: comprasItems,
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFF0F0F0), thickness: 1),
              const SizedBox(height: 8),
            ],

            if (produccionItems.isNotEmpty) ...[
              const _SH('Producción'),
              const SizedBox(height: 12),
              Wrap(
                spacing: metrics.spacing,
                runSpacing: 16,
                children: produccionItems,
              ),
              const SizedBox(height: 24),
            ],

            if (mostrarSedes) ...[
              const _SH('Sedes'),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MI(
                    icon: Icons.location_on_outlined,
                    label: 'Sedes',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RouteGuard(
                          requiredModule: moduloSedes,
                          child: SedesPage(),
                        ),
                      ),
                    ),
                    size: metrics.soloSize,
                    iconSize: metrics.soloIconSize,
                    fontSize: metrics.soloFontSize,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFF0F0F0), thickness: 1),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
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
    this.fontSize = 12,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color shadowColor;
  final double size;
  final double iconSize;
  final double fontSize;

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
            const SizedBox(height: 8),
            // Alto fijo para el texto: así todos los botones de una misma
            // fila quedan alineados aunque unos tengan 1 línea de label y
            // otros 2 (evita el desnivel que se ve feo en pantallas angostas).
            SizedBox(
              height: fontSize * 2.6,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  color: const Color(0xFF444444),
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
