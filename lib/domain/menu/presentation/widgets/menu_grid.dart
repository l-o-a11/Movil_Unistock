import 'package:flutter/material.dart';

import '../../../auth/domain/modulo_constants.dart';
import '../../../auth/presentation/route_guard.dart';
import '../../../categoriainsumo/presentation/pages/categorias_page.dart';
import '../../../compras/presentation/pages/compras_page.dart';
import '../../../empleados/presentation/empleados_page.dart';
import '../../../insumos/presentation/pages/insumos_page.dart';
import '../../../productcategories/presentation/pages/product_categories_page.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../../../produccion/produccion.dart';
import '../../../proveedores/features/presentation/pages/proveedores_page.dart';
import '../../../roles/presentation/pages/roles_page.dart';
import '../../../sedes/presentation/pages/sedes_page.dart';
import '../../../usuarios/presentation/usuarios_page.dart';

class MenuGrid extends StatelessWidget {
  const MenuGrid({super.key, required this.modulos});

  final List<String> modulos;

  bool _tiene(String modulo) => modulos.contains(modulo);

  @override
  Widget build(BuildContext context) {
    final mostrarRoles = _tiene(moduloRoles);
    final mostrarEmpleados = _tiene(moduloEmpleados);
    final mostrarSedes = _tiene(moduloSedes);

    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = _GridMetrics.of(constraints.maxWidth - 32);

        final comprasItems = <Widget>[
          if (_tiene(moduloCategoriasInsumos))
            _MenuItem(
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
            _MenuItem(
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
            _MenuItem(
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
            _MenuItem(
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
            _MenuItem(
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
            _MenuItem(
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
            _MenuItem(
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
            _MenuItem(
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
              const _SectionHeader('Roles'),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MenuItem(
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
              const _SectionHeader('Usuarios'),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MenuItem(
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
                  _MenuItem(
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
              const _SectionHeader('Compras'),
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
              const _SectionHeader('Producción'),
              const SizedBox(height: 12),
              Wrap(
                spacing: metrics.spacing,
                runSpacing: 16,
                children: produccionItems,
              ),
              const SizedBox(height: 24),
            ],
            if (mostrarSedes) ...[
              const _SectionHeader('Sedes'),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MenuItem(
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

  factory _GridMetrics.of(double contentWidth) {
    final angosto = contentWidth < 340;
    final columns = angosto ? 3 : 4;
    const spacing = 14.0;
    final rawItemSize = (contentWidth - spacing * (columns - 1)) / columns;
    final itemSize = rawItemSize.clamp(56.0, 78.0);

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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

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

class _MenuItem extends StatelessWidget {
  const _MenuItem({
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
