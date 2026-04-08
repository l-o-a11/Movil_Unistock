import 'package:flutter/material.dart';

import '../../shared/widgets/global_bottom_nav.dart';
import '../categories/categories_page.dart';
import '../compras/compras.dart';
import '../insumos/insumos_page.dart';
import '../proveedores/features/presentation/pages/proveedores_page.dart';
import '../produccion/produccion.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});
  static const _pink = Color(0xFFFF4FA3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const GlobalBottomNav(),
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(width: 42, height: 42,
              decoration: BoxDecoration(color: _pink, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 22)),
            Container(width: 42, height: 42,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _pink, width: 1.5)),
              child: const Icon(Icons.person_outline_rounded, color: _pink, size: 22)),
          ])),
        const Padding(padding: EdgeInsets.only(bottom: 16),
          child: Text('Sede 1', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1C)))),
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          // Usuarios
          const _SH('Usuarios'), const SizedBox(height: 12),
          Row(children: [_MI(icon: Icons.group_outlined, label: 'Empleados', onTap: () {})]),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFF0F0F0), thickness: 1),
          const SizedBox(height: 8),

          // Compras
          const _SH('Compras'), const SizedBox(height: 12),
          Wrap(spacing: 16, runSpacing: 16, children: [
            _MI(icon: Icons.grid_view_rounded,       label: 'Categorías\nde insumo', onTap: () {}),
            _MI(icon: Icons.inventory_2_outlined,    label: 'Insumo',      
             onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InsumosPage()))),
            _MI(icon: Icons.local_shipping_outlined, label: 'Proveedores',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProveedoresPage()))),
            _MI(icon: Icons.shopping_cart_outlined,  label: 'Compras',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComprasPage()))),
          ]),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFF0F0F0), thickness: 1),
          const SizedBox(height: 8),

          // Producción — sin "Órdenes"
          const _SH('Producción'), const SizedBox(height: 12),
          Wrap(spacing: 16, runSpacing: 16, children: [
            _MI(icon: Icons.grid_view_rounded,    label: 'Categoría\nde producto',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesPage()))),
            _MI(icon: Icons.inventory_2_outlined, label: 'Producto',  onTap: () {}),
            // Terceros → abre Producción en tab Terceros
            _MI(icon: Icons.group_outlined, label: 'Terceros',
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProduccionApp(openTerceros: true)))),
            // Producción → abre Producción en tab Producciones
            _MI(icon: Icons.work_outline_rounded, label: 'Producción',
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProduccionApp()))),
          ]),
          const SizedBox(height: 24),
        ])),
      ])),
    );
  }
}

class _SH extends StatelessWidget {
  const _SH(this.title);
  final String title;
  @override Widget build(BuildContext context) =>
    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1C)));
}

class _MI extends StatelessWidget {
  const _MI({required this.icon, required this.label, required this.onTap});
  final IconData icon; final String label; final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap,
      child: SizedBox(width: 72, child: Column(children: [
        Container(width: 60, height: 60,
          decoration: const BoxDecoration(color: Color(0xFFFF4FA3), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 26)),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF444444), height: 1.3)),
      ])));
  }
}
