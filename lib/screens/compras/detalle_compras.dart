import 'package:flutter/material.dart';
import '../shared/bottom_nav.dart';

class DetalleCompras extends StatelessWidget {
  final String compraNumber;
  final String date;
  final String provider;
  final bool isActive;

  const DetalleCompras({
    super.key,
    required this.compraNumber,
    required this.date,
    required this.provider,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFE91E8C);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF4DA6), Color(0xFFFF8ACD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
        title: Text(
          'Detalle $compraNumber',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: pink.withOpacity(0.4), width: 1.5),
            ),
            child: IconButton(
              icon: const Icon(Icons.person_outline_rounded, color: pink),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Detalle de compra',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
