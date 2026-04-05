import 'package:flutter/material.dart';
import '../shared/bottom_nav.dart';
import 'detalle_compras.dart';

class ComprasPage extends StatefulWidget {
  const ComprasPage({super.key});

  @override
  State<ComprasPage> createState() => _ComprasPageState();
}

class _ComprasPageState extends State<ComprasPage> {
  int _currentNavIndex = 2;

  final List<Map<String, dynamic>> _compras = [
    {
      'number': 'N°1',
      'date': '12/02/2025',
      'provider': 'Proveedor',
      'isActive': true,
    },
    {
      'number': 'N°2',
      'date': '20/03/2024',
      'provider': 'Proveedor',
      'isActive': true,
    },
    {
      'number': 'N°3',
      'date': '30/07/2024',
      'provider': 'Proveedor',
      'isActive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFE91E8C);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            'Compras',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon and user button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE91E8C), Color(0xFFFF6EB4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: pink.withOpacity(0.5),
                      width: 1.5,
                    ),
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: pink,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Compras',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 12),
                  Icon(
                    Icons.search_rounded,
                    color: Color(0xFFAAAAAA),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Buscar...',
                    style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 15),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Compra list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _compras.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final compra = _compras[index];
                return _CompraCard(
                  number: compra['number'],
                  date: compra['date'],
                  provider: compra['provider'],
                  isActive: compra['isActive'],
                  onDetailTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetalleCompras(
                          compraNumber: compra['number'],
                          date: compra['date'],
                          provider: compra['provider'],
                          isActive: compra['isActive'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
      ),
    );
  }
}

class _CompraCard extends StatelessWidget {
  final String number;
  final String date;
  final String provider;
  final bool isActive;
  final VoidCallback onDetailTap;

  const _CompraCard({
    required this.number,
    required this.date,
    required this.provider,
    required this.isActive,
    required this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFE91E8C);
    final statusColor = isActive
        ? const Color(0xFF4CAF50)
        : const Color(0xFF9E9E9E);
    final statusText = isActive ? 'ACTIVO' : 'INACTIVO';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF4DA6), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number and status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                number,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Date label
          const Text(
            'FECHA',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFFAAAAAA),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 10),

          // Provider label
          const Text(
            'PROVEEDOR',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFFAAAAAA),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            provider,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 14),

          // Bottom row: detail icon
          GestureDetector(
            onTap: onDetailTap,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5),
                color: Colors.white,
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: Color(0xFFAAAAAA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
