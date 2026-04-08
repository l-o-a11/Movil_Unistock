import 'package:flutter/material.dart';

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
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1C1C1E),
                size: 16,
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFFFF8ACD), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF4DA6).withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.person_2_sharp, color: Color(0xFFFF4DA6), size: 20),
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
