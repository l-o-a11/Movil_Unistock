import 'package:flutter/material.dart';
import '../../shared/widgets/global_bottom_nav.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        "ref": "REF 772",
        "name": "Crop Top Negro",
        "price": "\$ 33.000",
        "stock": "STOCK: 0"
      },
      {
        "ref": "REF 772",
        "name": "Crop Top Negro",
        "price": "\$ 33.000",
        "stock": "STOCK: 0"
      },
      {
        "ref": "REF 578",
        "name": "Crop Top Rojo",
        "price": "\$ 33.000",
        "stock": "STOCK: 0"
      },
      {
        "ref": "REF 578",
        "name": "Crop Top Rojo",
        "price": "\$ 33.000",
        "stock": "STOCK: 0"
      },
      {
        "ref": "REF 678",
        "name": "Crop Top Rosa",
        "price": "\$ 33.000",
        "stock": "STOCK: 0"
      },
      {
        "ref": "REF 678",
        "name": "Crop Top Rosa",
        "price": "\$ 33.000",
        "stock": "STOCK: 0"
      },
    ];

    return Scaffold(
      bottomNavigationBar: const GlobalBottomNav(), // 👈 SOLO ESTO SE AGREGÓ
      backgroundColor: const Color(0xFFF6F6F6),

      body: SafeArea(
        child: Column(
          children: [

            // HEADER BLANCO
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // BOTONES SUPERIORES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF4DA6), Color(0xFFFF8ACD)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),

                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFFF8ACD),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF4DA6).withOpacity(0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_2_sharp,
                          color: Color(0xFFFF4DA6),
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    "Productos",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Buscar productos...",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // LISTA
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final item = products[index];
                  return _productCard(context, item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CARD PRODUCTO
  Widget _productCard(BuildContext context, Map item) {
    return _AnimatedCard(
      onTap: () => _showBottomSheet(context, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFD6E7)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF4DA6).withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [

            // IMAGEN
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            const SizedBox(width: 12),

            // TEXTO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["ref"],
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item["name"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item["price"],
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    item["stock"],
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

            // DERECHA
            Row(
              children: [
                Row(
                  children: const [
                    Icon(Icons.circle, size: 8, color: Colors.green),
                    SizedBox(width: 5),
                    Text(
                      "ACTIVO",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE4F1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 13,
                    color: Color(0xFFE91E8C),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // MODAL COMPLETO ORIGINAL
  void _showBottomSheet(BuildContext context, Map item) {
    String? selectedValue;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4F1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Ficha Técnica - ${item["name"]}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedValue,
                        hint: const Text("Seleccionar versión"),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: "v1", child: Text("Versión 1")),
                          DropdownMenuItem(value: "v2", child: Text("Versión 2")),
                          DropdownMenuItem(value: "v3", child: Text("Versión 3")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedValue = value;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "*Selecciona la versión de la ficha técnica que deseas descargar*",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selectedValue == null
                          ? Colors.grey[200]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        selectedValue == null
                            ? "Selecciona una versión"
                            : "Descargar excel para visualizar la ficha técnica ($selectedValue)",
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF4DA6), Color(0xFFFF8ACD)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "Cerrar",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ANIMACIÓN CARD
class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> {
  double scale = 1.0;

  void _onTapDown(_) => setState(() => scale = 0.96);
  void _onTapUp(_) => setState(() => scale = 1.0);
  void _onTapCancel() => setState(() => scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}