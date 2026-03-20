import 'package:flutter/material.dart';
import '../categories/categories_page.dart';
import '../produccion/produccion.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _BottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo icon
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
                  // Profile icon
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFF4FA3),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFFFF4FA3),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // ── Title ───────────────────────────────────────────────
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

            // ── Scrollable sections ─────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // ── Usuarios ──────────────────────────────────────
                  _SectionHeader(title: 'Usuarios'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _MenuItemTile(
                        icon: Icons.group_outlined,
                        label: 'Empleados',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFF0F0F0), thickness: 1),
                  const SizedBox(height: 8),

                  // ── Compras ───────────────────────────────────────
                  _SectionHeader(title: 'Compras'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _MenuItemTile(
                        icon: Icons.grid_view_rounded,
                        label: 'Categorías\nde insumo',
                        onTap: () {},
                      ),
                      _MenuItemTile(
                        icon: Icons.inventory_2_outlined,
                        label: 'Insumo',
                        onTap: () {},
                      ),
                      _MenuItemTile(
                        icon: Icons.local_shipping_outlined,
                        label: 'Proveedores',
                        onTap: () {},
                      ),
                      _MenuItemTile(
                        icon: Icons.shopping_cart_outlined,
                        label: 'Compras',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFF0F0F0), thickness: 1),
                  const SizedBox(height: 8),

                  // ── Producción ────────────────────────────────────
                  _SectionHeader(title: 'Producción'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _MenuItemTile(
                        icon: Icons.grid_view_rounded,
                        label: 'Categoría\nde producto',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CategoriesPage(),
                            ),
                          );
                        },
                      ),
                      _MenuItemTile(
                        icon: Icons.inventory_2_outlined,
                        label: 'Producto',
                        onTap: () {},
                      ),
                      _MenuItemTile(
                        icon: Icons.description_outlined,
                        label: 'Órdenes',
                        onTap: () {},
                      ),
                      _MenuItemTile(
                        icon: Icons.group_outlined,
                        label: 'Terceros',
                        onTap: () {},
                      ),
                      _MenuItemTile(
                        icon: Icons.work_outline_rounded,
                        label: 'Producción',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProduccionApp(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1C1C1C),
      ),
    );
  }
}

// ── Menu Item Tile ─────────────────────────────────────────────────────────────

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFFF4FA3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 8),
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

// ── Bottom Navigation ──────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.trending_up_rounded),
            color: const Color(0xFFFF4FA3),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.group_outlined),
            color: const Color(0xFFAAAAAA),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            color: const Color(0xFFAAAAAA),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.work_outline_rounded),
            color: const Color(0xFFAAAAAA),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
