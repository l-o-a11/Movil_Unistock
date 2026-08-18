import 'package:flutter/material.dart';

/// Barra de navegación fija mostrada en la parte inferior de la aplicación.
///
/// Índices: 0 = Dash, 1 = Productos, 2 = Explorar, 3 = Compras,
/// 4 = Producción. Usa -1 para no resaltar ningún acceso.
class GlobalBottomNav extends StatelessWidget {
  const GlobalBottomNav({super.key, this.activeIndex = -1});

  final int activeIndex;

  static const _pink = Color(0xFFFF4FA3);
  static const _pinkBackground = Color(0xFFFFE4F2);
  static const _grey = Color(0xFF9AA3B2);
  static const _labelGrey = Color(0xFF8791A2);

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.trending_up_rounded,
                label: 'Dash',
                active: activeIndex == 0,
                onTap: () => _replaceWith(context, '/dashboard'),
              ),
              _NavItem(
                icon: Icons.inventory_2_outlined,
                label: 'Productos',
                active: activeIndex == 1,
                onTap: () => _replaceWith(context, '/productos'),
              ),
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Explorar',
                active: activeIndex == 2,
                onTap: () => Navigator.of(context).pushNamed('/menu'),
              ),
              _NavItem(
                icon: Icons.shopping_cart_outlined,
                label: 'Compras',
                active: activeIndex == 3,
                onTap: () => _replaceWith(context, '/compras'),
              ),
              _NavItem(
                icon: Icons.work_outline_rounded,
                label: 'Producción',
                active: activeIndex == 4,
                onTap: () => _replaceWith(context, '/produccion'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _replaceWith(BuildContext context, String routeName) {
    Navigator.of(context).pushNamedAndRemoveUntil(routeName, (route) => route.isFirst);
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const pink = GlobalBottomNav._pink;
    const grey = GlobalBottomNav._grey;
    const labelGrey = GlobalBottomNav._labelGrey;

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
                color: active ? GlobalBottomNav._pinkBackground : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 24, color: active ? pink : grey),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: active ? pink : labelGrey,
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
