import 'package:flutter/material.dart';
import '../../domain/auth/data/auth_session_repository_impl.dart';
import '../../domain/auth/domain/auth_session_repository.dart';
import '../../domain/auth/domain/modulo_constants.dart';

/// Bottom nav global presente en TODAS las pantallas.
/// [activeIndex] indica qué ícono se resalta en rosado:
///   0 = dashboard, 1 = productos, 2 = cart, 3 = work/producción
/// Pasa -1 (o no pases nada) para ninguno activo.
///
/// Cada ícono se muestra solo si el rol del usuario tiene permiso sobre el
/// módulo correspondiente (mismo criterio que MenuPage). El botón flotante
/// central siempre se muestra: solo exige sesión iniciada, no un módulo
/// puntual.
class GlobalBottomNav extends StatefulWidget {
  final int activeIndex;

  const GlobalBottomNav({super.key, this.activeIndex = -1});

  static const _pink = Color(0xFFFF4FA3);
  static const _grey = Color(0xFFB0B0B8);

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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFFFFF2F8)],
        ),
        border: Border(top: BorderSide(color: Color(0xFFF5E4EE), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: FutureBuilder<List<String>>(
            future: _modulosFuture,
            builder: (context, snapshot) {
              final modulos = snapshot.data ?? const <String>[];
              final tiene = (String m) => modulos.contains(m);

              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (tiene(moduloDashboard))
                          _Btn(
                            icon: Icons.show_chart_rounded,
                            label: 'Inicio',
                            active: widget.activeIndex == 0,
                            onTap: () => _goToDashboard(context),
                          )
                        else
                          const SizedBox(width: 60),
                        if (tiene(moduloProductos))
                          _Btn(
                            icon: Icons.inventory_2_outlined,
                            label: 'Productos',
                            active: widget.activeIndex == 1,
                            onTap: () => _goToProductos(context),
                          )
                        else
                          const SizedBox(width: 60),
                        // Hueco reservado para que no se apiñen los ítems
                        // alrededor del botón flotante del centro.
                        const SizedBox(width: 58),
                        if (tiene(moduloCompras))
                          _Btn(
                            icon: Icons.shopping_cart_outlined,
                            label: 'Compras',
                            active: widget.activeIndex == 2,
                            onTap: () => _goToCompras(context),
                          )
                        else
                          const SizedBox(width: 60),
                        if (tiene(moduloProduccion))
                          _Btn(
                            icon: Icons.work_outline_rounded,
                            label: 'Producción',
                            active: widget.activeIndex == 3,
                            onTap: () => _goToProduccion(context),
                          )
                        else
                          const SizedBox(width: 60),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -26,
                    child: _FloatingMenuButton(onTap: () => _goToMenu(context)),
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
  static const _grey = GlobalBottomNav._grey;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: active
                    ? _pink.withOpacity(0.14)
                    : _pink.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 19, color: active ? _pink : _grey),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? _pink : _grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingMenuButton extends StatelessWidget {
  final VoidCallback onTap;
  const _FloatingMenuButton({required this.onTap});

  static const _pink = GlobalBottomNav._pink;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 112,
        height: 76,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // Halo suave detrás del botón, imita el resplandor difuminado.
            Container(
              width: 112,
              height: 76,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x59FF4FA3), Color(0x00FF4FA3)],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: _pink.withOpacity(0.5),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_pink, Color(0xFFFF8ACD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}