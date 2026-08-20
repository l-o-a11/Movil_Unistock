import 'package:flutter/material.dart';
import '../../domain/auth/data/auth_session_repository_impl.dart';
import '../../domain/auth/domain/auth_session_repository.dart';
import '../../domain/auth/domain/modulo_constants.dart';

/// Bottom nav global presente en TODAS las pantallas.
/// [activeIndex] indica qué ícono se resalta en rosado:
///   0 = dashboard, 1 = productos, 2 = explorar, 3 = compras, 4 = producción
/// Pasa -1 (o no pases nada) para ninguno activo.
///
/// Cada ícono se muestra solo si el rol del usuario tiene permiso sobre el
/// módulo correspondiente (mismo criterio que MenuPage). "Explorar" siempre
/// se muestra: solo exige sesión iniciada, no un módulo puntual.
class GlobalBottomNav extends StatefulWidget {
  final int activeIndex;

  const GlobalBottomNav({super.key, this.activeIndex = -1});

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

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (tiene(moduloDashboard))
                    _Btn(
                      icon: Icons.trending_up_rounded,
                      label: 'Dash',
                      active: widget.activeIndex == 0,
                      onTap: () => _goToDashboard(context),
                    )
                  else
                    const SizedBox(width: 64),
                  if (tiene(moduloProductos))
                    _Btn(
                      icon: Icons.inventory_2_outlined,
                      label: 'Productos',
                      active: widget.activeIndex == 1,
                      onTap: () => _goToProductos(context),
                    )
                  else
                    const SizedBox(width: 64),
                  _Btn(
                    icon: Icons.grid_view_rounded,
                    label: 'Explorar',
                    active: widget.activeIndex == 2,
                    onTap: () => _goToMenu(context),
                  ),
                  if (tiene(moduloCompras))
                    _Btn(
                      icon: Icons.shopping_cart_outlined,
                      label: 'Compras',
                      active: widget.activeIndex == 3,
                      onTap: () => _goToCompras(context),
                    )
                  else
                    const SizedBox(width: 64),
                  if (tiene(moduloProduccion))
                    _Btn(
                      icon: Icons.work_outline_rounded,
                      label: 'Producción',
                      active: widget.activeIndex == 4,
                      onTap: () => _goToProduccion(context),
                    )
                  else
                    const SizedBox(width: 64),
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
