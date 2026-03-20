
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_dependencies.dart';
import 'core/theme/app_theme.dart';
import 'features/presentation/pages/produccion_page.dart';

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
