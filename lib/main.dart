import 'package:flutter/material.dart';
import 'package:movil_unistock/domain/dashboard/presentation/pages/dashboard_page.dart';
import 'package:movil_unistock/domain/menu/menu_page.dart';
import 'package:movil_unistock/domain/usuarios/presentation/usuarios_page.dart';
import 'package:movil_unistock/domain/terceros/features/presentation/pages/terceros_page.dart';
import 'domain/Login_page.dart';
import 'domain/produccion/produccion.dart';
import 'domain/compras/presentation/compras_page.dart';
import 'domain/products/presentation/products_page.dart';
import 'domain/auth/presentation/route_guard.dart';
import 'domain/auth/domain/modulo_constants.dart';

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

      // Cada ruta (salvo Login) pasa por RouteGuard: si no hay sesión activa
      // redirige a Login. `requiredModule` es una segunda barrera basada en
      // los permisos reales del rol (los íconos ya se ocultan en MenuPage
      // según esos mismos permisos).
      routes: {
        '/dashboard': (_) =>
            const RouteGuard(requiredModule: moduloDashboard, child: DashboardPage()),
        '/menu': (_) => const RouteGuard(child: MenuPage()),
        '/produccion': (_) =>
            const RouteGuard(requiredModule: moduloProduccion, child: ProduccionApp()),
        '/usuarios': (_) =>
            const RouteGuard(requiredModule: moduloUsuarios, child: UsuariosPage()),
        '/compras': (_) =>
            const RouteGuard(requiredModule: moduloCompras, child: ComprasPage()),
        '/terceros': (_) =>
            const RouteGuard(requiredModule: moduloTerceros, child: TercerosPage()),
        '/productos': (_) =>
            const RouteGuard(requiredModule: moduloProductos, child: ProductsPage()),
      },
    );
  }
}