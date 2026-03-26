import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/presentation/pages/produccion_page.dart';
import 'features/presentation/providers/produccion_provider.dart';
import 'features/presentation/state/produccion_state.dart';

/// Shell de Producción — sin Navigator interno (evita pantalla negra al volver).
/// Simplemente muestra ProduccionPage directamente.
class AppShell extends StatefulWidget {
  final bool openTerceros;
  const AppShell({super.key, this.openTerceros = false});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    if (widget.openTerceros) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          context.read<ProduccionProvider>().changeTab(ProduccionTab.terceros);
        } catch (_) {}
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sin Navigator interno — ProduccionPage usa el Navigator del menú principal.
    // Esto garantiza que el botón atrás funcione correctamente.
    return const ProduccionPage();
  }
}
