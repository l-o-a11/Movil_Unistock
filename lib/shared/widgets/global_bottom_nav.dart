import 'package:flutter/material.dart';

/// Bottom nav global presente en TODAS las pantallas.
/// [activeIndex] indica qué ícono se resalta en rosado:
///   0 = chart, 1 = people/usuarios, 2 = cart, 3 = work/producción
/// Pasa -1 (o no pases nada) para ninguno activo.
class GlobalBottomNav extends StatelessWidget {
  final int activeIndex;

  const GlobalBottomNav({super.key, this.activeIndex = -1});

  static const _pink = Color(0xFFFF4FA3);
  static const _grey = Color(0xFFAAAAAA);

  Color _color(int index) => activeIndex == index ? _pink : _grey;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Btn(
                icon: Icons.show_chart_rounded,
                color: _color(0),
                onTap: null,
              ),
              _Btn(
                icon: Icons.people_outline_rounded,
                color: _color(1),
                onTap: () => _goToUsuarios(context),
              ),
              _Btn(
                icon: Icons.shopping_cart_outlined,
                color: _color(2),
                onTap: () => _goToCompras(context),
              ),
              _Btn(
                icon: Icons.work_outline_rounded,
                color: _color(3),
                onTap: () => _goToProduccion(context),
              ),
            ],
          ),
        ),
      ),
    );
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
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _Btn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        height: 64,
        child: Center(child: Icon(icon, size: 26, color: color)),
      ),
    );
  }
}
