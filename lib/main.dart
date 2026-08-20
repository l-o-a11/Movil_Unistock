import 'package:flutter/material.dart';
import 'package:movil_unistock/domain/dashboard/presentation/pages/dashboard_page.dart';
import 'package:movil_unistock/domain/menu/menu_page.dart';
import 'package:movil_unistock/domain/usuarios/presentation/usuarios_page.dart';
import 'package:movil_unistock/domain/terceros/features/presentation/pages/terceros_page.dart';
import 'domain/Login_page.dart';
import 'domain/produccion/produccion.dart';
import 'domain/compras/compras_page.dart';
import 'domain/products/products_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Unistock',
      home: const LoginPage(),

      routes: {
        '/dashboard': (_) => const DashboardPage(),
        '/menu': (_) => const MenuPage(),
        '/produccion': (_) => const ProduccionApp(),
        '/usuarios': (_) => const UsuariosPage(),
        '/compras': (_) => const ComprasPage(),
        '/terceros': (_) => const TercerosPage(),
        '/productos': (_) => const ProductsPage(),
      },
    );
  }
}