import 'package:flutter/material.dart';

/// Bottom nav global presente en TODAS las pantallas.
/// [activeIndex] indica qué ícono se resalta en rosado:
///   0 = dashboard, 1 = people/usuarios, 2 = cart, 3 = work/producción
/// Pasa -1 (o no pases nada) para ninguno activo.
///
/// Incluye un botón circular flotante al centro (ícono de menú) que lleva
/// directamente a la pantalla de Menú, reemplazando el antiguo botón
/// "Acceder al sistema" que estaba en el Dashboard.
class GlobalBottomNav extends StatelessWidget {
  final int activeIndex;

  const GlobalBottomNav({super.key, this.activeIndex = -1});

  static const _pink = Color(0xFFFF4FA3);
  static const _grey = Color(0xFFB0B0B8);

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
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Btn(
                      icon: Icons.show_chart_rounded,
                      label: 'Inicio',
                      active: activeIndex == 0,
                      onTap: () => _goToDashboard(context),
                    ),
                    _Btn(
                      icon: Icons.people_outline_rounded,
                      label: 'Usuarios',
                      active: activeIndex == 1,
                      onTap: () => _goToUsuarios(context),
                    ),
                    // Hueco reservado para que no se apiñen los ítems
                    // alrededor del botón flotante del centro.
                    const SizedBox(width: 58),
                    _Btn(
                      icon: Icons.shopping_cart_outlined,
                      label: 'Compras',
                      active: activeIndex == 2,
                      onTap: () => _goToCompras(context),
                    ),
                    _Btn(
                      icon: Icons.work_outline_rounded,
                      label: 'Producción',
                      active: activeIndex == 3,
                      onTap: () => _goToProduccion(context),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -26,
                child: _FloatingMenuButton(onTap: () => _goToMenu(context)),
              ),
            ],
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

  static void _goToUsuarios(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/usuarios', (route) => route.isFirst);
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