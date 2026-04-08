import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_dependencies.dart';
import 'app_shell.dart';
import 'core/theme/app_theme.dart';
import 'features/presentation/providers/produccion_provider.dart';
import '../terceros/features/presentation/providers/terceros_provider.dart';
import '../terceros/terceros_dependencies.dart';

/// Punto de entrada del módulo Producción.
/// NO crea un MaterialApp propio — usa el del menú principal.
/// [openTerceros]: si true, inicia en el tab Terceros.
class ProduccionApp extends StatelessWidget {
  final bool openTerceros;
  const ProduccionApp({super.key, this.openTerceros = false});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProduccionProvider>(
          create: (_) => AppDependencies.createProduccionProvider(),
        ),
        ChangeNotifierProvider<TercerosProvider>(
          create: (_) => TercerosDependencies.createTercerosProvider(),
        ),
      ],
      child: Theme(
        data: AppTheme.light,
        child: AppShell(openTerceros: openTerceros),
      ),
    );
  }
}
