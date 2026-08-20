// lib/domain/auth/presentation/route_guard.dart
//
// Envuelve una página protegida y verifica, antes de mostrarla, que:
//   1. Exista una sesión activa (token guardado) → si no, redirige a Login.
//   2. (Opcional) El rol del usuario tenga permiso sobre `requiredModule`
//      (ver modulo_constants.dart) → si no, redirige de vuelta al menú en
//      silencio. El control principal de qué puede ver cada usuario es
//      ocultar el ícono en MenuPage; esto es solo una segunda barrera por
//      si alguien llega a la ruta de otra forma (deep link, back-stack).
//
// Uso:
//   '/dashboard': (_) => const RouteGuard(child: DashboardPage()),
//   '/usuarios': (_) => const RouteGuard(
//         requiredModule: moduloUsuarios,
//         child: UsuariosPage(),
//       ),

import 'package:flutter/material.dart';
import '../data/auth_session_repository_impl.dart';
import '../domain/auth_session_repository.dart';

enum _GuardResult { allowed, deniedNoSession, deniedModule }

class RouteGuard extends StatefulWidget {
  const RouteGuard({super.key, required this.child, this.requiredModule});

  /// Página real que se muestra si la sesión (y el permiso, si aplica) es
  /// válida.
  final Widget child;

  /// Nombre de módulo (ver modulo_constants.dart) que el rol del usuario
  /// debe tener permitido para entrar. Si es null, solo se exige sesión
  /// iniciada.
  final String? requiredModule;

  @override
  State<RouteGuard> createState() => _RouteGuardState();
}

class _RouteGuardState extends State<RouteGuard> {
  final AuthSessionRepository _repository = AuthSessionRepositoryImpl();
  late Future<_GuardResult> _future;

  @override
  void initState() {
    super.initState();
    _future = _check();
  }

  Future<_GuardResult> _check() async {
    final loggedIn = await _repository.isLoggedIn();
    if (!loggedIn) return _GuardResult.deniedNoSession;

    final requiredModule = widget.requiredModule;
    if (requiredModule == null || requiredModule.isEmpty) {
      return _GuardResult.allowed;
    }

    final modulos = await _repository.getModulosPermitidos();
    return modulos.contains(requiredModule.trim().toLowerCase())
        ? _GuardResult.allowed
        : _GuardResult.deniedModule;
  }

  void _redirect(String routeName) {
    // No se puede navegar durante build(), así que se agenda para después
    // del primer frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(routeName, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_GuardResult>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final result = snapshot.data ?? _GuardResult.deniedNoSession;

        switch (result) {
          case _GuardResult.deniedNoSession:
            _redirect('/');
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case _GuardResult.deniedModule:
            // Sin permiso sobre el módulo: se vuelve al menú sin mostrar
            // ningún mensaje de "acceso denegado" (el ícono ya no debería
            // haber estado visible ahí).
            _redirect('/menu');
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case _GuardResult.allowed:
            return widget.child;
        }
      },
    );
  }
}