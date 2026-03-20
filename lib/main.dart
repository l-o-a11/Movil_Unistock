import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'produccion/app_dependencies.dart';
import 'produccion/core/theme/app_theme.dart';
import 'produccion/features/presentation/pages/produccion_page.dart';

void main() {
  runApp(const ProduccionApp());
}

class ProduccionApp extends StatelessWidget {
  const ProduccionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppDependencies.createProduccionProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Producción',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const ProduccionPage(),
      ),
    );
  }
}