import 'package:flutter/material.dart';
import '../../domain/auth/data/auth_session_repository_impl.dart';
import '../../domain/auth/domain/auth_session_repository.dart';
import '../../domain/auth/domain/modulo_constants.dart';

/// Bottom nav global presente en TODAS las pantallas.
///
/// [activeKey] indica qué ícono se resalta: 'dashboard', 'productos',
/// 'explorar', 'compras' o 'produccion'. Pasa null (o no pases nada) para
/// ninguno activo — se usa una CLAVE por nombre en vez de un índice fijo
/// porque la cantidad de íconos varía según el rol (ver abajo), así que la
/// posición de cada uno ya no es siempre la misma.
///
/// Cada ícono de acceso rápido (Dash/Productos/Compras/Producción) se
/// muestra SOLO si el rol del usuario tiene permiso sobre ese módulo
/// (mismo criterio que MenuPage). "Explorar" siempre se muestra: solo
/// exige sesión iniciada, no un módulo puntual — es la puerta a todo lo
/// demás (Usuarios, Empleados, Roles, Insumos, etc.).
///
/// FIX: antes, los íconos sin permiso se reemplazaban por un
/// `SizedBox(width: 64)` invisible para "no romper" el `activeIndex` fijo
/// por posición. Pero con `spaceAround` eso deja huecos muertos y una
/// barra descuadrada para roles con menos permisos (p. ej. Empleado sin
/// acceso a Productos). Ahora la fila se arma SOLO con los íconos
/// visibles y se reparten con `spaceEvenly`, así que un Gerente/Admin ve
/// las 5 posiciones normales, y un Empleado ve, por ejemplo, 4 íconos
/// parejos — ambos casos se ven "completos", no rotos.
class GlobalBottomNav extends StatefulWidget {
  final String? activeKey;

  const GlobalBottomNav({super.key, this.activeKey});

  static const _pink = Color(0xFFFF4FA3);
  static const _pinkBackground = Color(0xFFFFE4F2);
  static const _grey = Color(0xFF9AA3B2);
  static const _labelGrey = Color(0xFF8791A2);

  @override
  State<GlobalBottomNav> createState() => _GlobalBottomNavState();
}

class _GlobalBottomNavState extends State<GlobalBottomNav> {
  final AuthSessionRepository _repository = AuthSessionRepositoryImpl();
  late Future<List<String>> _modulosFuture;

  @override
  void initState() {
    super.initState();
    // Se apoya en la caché en memoria de getModulosPermitidos(): como este
    // widget vive en casi todas las pantallas, no vuelve a pedir el rol a
    // la API en cada una, solo la primera vez tras el login.
    _modulosFuture = _repository.getModulosPermitidos();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F1F3))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 76,
          child: FutureBuilder<List<String>>(
            future: _modulosFuture,
            builder: (context, snapshot) {
              final modulos = snapshot.data ?? const <String>[];
              final tiene = (String m) => modulos.contains(m);

              final items = <_NavItemData>[
                if (tiene(moduloDashboard))
                  _NavItemData(
                    key: 'dashboard',
                    icon: Icons.trending_up_rounded,
                    label: 'Dash',
                    onTap: () => _goToDashboard(context),
                  ),
                if (tiene(moduloProductos))
                  _NavItemData(
                    key: 'productos',
                    icon: Icons.inventory_2_outlined,
                    label: 'Productos',
                    onTap: () => _goToProductos(context),
                  ),
                _NavItemData(
                  key: 'explorar',
                  icon: Icons.grid_view_rounded,
                  label: 'Explorar',
                  onTap: () => _goToMenu(context),
                ),
                if (tiene(moduloCompras))
                  _NavItemData(
                    key: 'compras',
                    icon: Icons.shopping_cart_outlined,
                    label: 'Compras',
                    onTap: () => _goToCompras(context),
                  ),
                if (tiene(moduloProduccion))
                  _NavItemData(
                    key: 'produccion',
                    icon: Icons.work_outline_rounded,
                    label: 'Producción',
                    onTap: () => _goToProduccion(context),
                  ),
              ];

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final item in items)
                    _Btn(
                      icon: item.icon,
                      label: item.label,
                      active: widget.activeKey == item.key,
                      onTap: item.onTap,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static void _goToDashboard(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/dashboard', (route) => route.isFirst);
  }

  static void _goToProductos(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/productos', (route) => route.isFirst);
  }

  static void _goToCompras(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/compras', (route) => route.isFirst);
  }

  static void _goToProduccion(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/produccion', (route) => route.isFirst);
  }

  static void _goToMenu(BuildContext context) {
    Navigator.of(context).pushNamed('/menu');
  }
}

class _NavItemData {
  final String key;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItemData({
    required this.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _Btn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  static const _pink = GlobalBottomNav._pink;
  static const _pinkBackground = GlobalBottomNav._pinkBackground;
  static const _grey = GlobalBottomNav._grey;
  static const _labelGrey = GlobalBottomNav._labelGrey;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: active ? _pinkBackground : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 24, color: active ? _pink : _grey),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? _pink : _labelGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
