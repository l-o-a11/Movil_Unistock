import 'package:flutter/material.dart';
import 'domain/Login_page.dart';
import 'domain/produccion/produccion.dart';

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
      routes: {'/produccion': (_) => const ProduccionApp()},
    );
  }
}
