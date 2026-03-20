import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFE91E8C);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: pink,
        unselectedItemColor: const Color(0xFFAAAAAA),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        iconSize: 26,
        items: [
          BottomNavigationBarItem(
            icon: _NavIcon(
              icon: Icons.show_chart_rounded,
              isSelected: currentIndex == 0,
              selectedColor: pink,
            ),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(
              icon: Icons.group_outlined,
              isSelected: currentIndex == 1,
              selectedColor: pink,
            ),
            label: 'Clientes',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(
              icon: Icons.shopping_cart_outlined,
              isSelected: currentIndex == 2,
              selectedColor: pink,
            ),
            label: 'Compras',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(
              icon: Icons.work_outline_rounded,
              isSelected: currentIndex == 3,
              selectedColor: pink,
            ),
            label: 'Trabajo',
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final Color selectedColor;

  const _NavIcon({
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selectedColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: selectedColor),
      );
    }
    return Icon(icon);
  }
}