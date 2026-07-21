import 'package:flutter/material.dart';

class ProductsPage extends StatelessWidget {
  final String? category;

  const ProductsPage({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    // 🔥 PRODUCTOS ORIGINALES con su propia ficha técnica
    final allProducts = [
      {
        "ref": "REF 772",
        "name": "Crop Top Negro",
        "price": "\$ 33.000",
        "stock": "STOCK: 0",
        "category": "Crop Top",
        "technicalSheet": {
          "Detalles del producto": {
            "Cliente": "María López",
            "Fecha": "2026-03-15",
            "Observaciones": "Ajuste de consumos y mejora en acabados.",
            "Elaboró": "Paula Andrea Builes"
          }
        }
      },
      {
        "ref": "REF 578",
        "name": "Crop Top Rojo",
        "price": "\$ 33.000",
        "stock": "STOCK: 0",
        "category": "Crop Top",
        "technicalSheet": {
          "Detalles del producto": {
            "Cliente": "Ana Rodríguez",
            "Fecha": "2026-03-20",
            "Observaciones": "Revisar tallas y acabados.",
            "Elaboró": "Carlos Méndez"
          }
        }
      },
      {
        "ref": "REF 678",
        "name": "Crop Top Rosa",
        "price": "\$ 33.000",
        "stock": "STOCK: 0",
        "category": "Crop Top",
        "technicalSheet": {
          "Detalles del producto": {
            "Cliente": "Sofía Martínez",
            "Fecha": "2026-03-25",
            "Observaciones": "Mejora en costuras laterales.",
            "Elaboró": "Paula Andrea Builes"
          }
        }
      },
      {
        "ref": "REF 111",
        "name": "Buzo Negro",
        "price": "\$ 50.000",
        "stock": "STOCK: 3",
        "category": "Buzos",
        "technicalSheet": {
          "Detalles del producto": {
            "Cliente": "Carlos Ruiz",
            "Fecha": "2026-02-20",
            "Observaciones": "Ajustar capucha y bolsillos.",
            "Elaboró": "Ana Martínez"
          }
        }
      },
      {
        "ref": "REF 222",
        "name": "Body Blanco",
        "price": "\$ 28.000",
        "stock": "STOCK: 5",
        "category": "Bodys",
        "technicalSheet": {
          "Detalles del producto": {
            "Cliente": "Diego Perez",
            "Fecha": "2026-02-10",
            "Observaciones": "Ajuste de consumos y mejora en acabados.",
            "Elaboró": "Paula Andrea Builes"
          }
        }
      },
    ];

    final products = category == null
        ? allProducts
        : allProducts.where((p) => p["category"] == category).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                        ),
                      ),
                      Container(
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
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
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
                        prefixIcon: Icon(Icons.search, color: Color(0xFFAEAEB2)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // LISTA DE PRODUCTOS
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

  Widget _productCard(BuildContext context, Map item) {
    return _AnimatedCard(
      onTap: () => _showTechnicalSheet(context, item),
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
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item["ref"], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(item["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(item["price"]),
                  Text(item["stock"], style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Row(
              children: [
                Row(children: const [
                  Icon(Icons.circle, size: 8, color: Colors.green),
                  SizedBox(width: 5),
                  Text("ACTIVO", style: TextStyle(color: Colors.green, fontSize: 11)),
                ]),
                const SizedBox(width: 10),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE4F1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_ios, size: 13, color: Color(0xFFE91E8C)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 FICHA TÉCNICA SIN SCROLL - Tamaño fijo
  void _showTechnicalSheet(BuildContext context, Map product) {
    final technicalSheet = product["technicalSheet"] as Map<String, dynamic>? ?? {
      "Detalles del producto": {
        "Cliente": "Sin información",
        "Fecha": "Sin fecha",
        "Observaciones": "Sin observaciones",
        "Elaboró": "Sin elaborador"
      }
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // 🔥 IMPORTANTE: Para que no haya scroll
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Título
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Ficha Técnica - ${product["name"]}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE4F1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.close, size: 18, color: Color(0xFFE91E8C)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Contenido sin scroll (todo junto)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: _buildTechnicalSheet(technicalSheet),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Construye las secciones
  List<Widget> _buildTechnicalSheet(Map<String, dynamic> technicalSheet) {
    List<Widget> sections = [];

    technicalSheet.forEach((sectionTitle, sectionContent) {
      if (sectionContent is Map<String, dynamic>) {
        sections.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sectionTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: _buildDetailRows(sectionContent),
                ),
              ),
            ],
          ),
        );
      }
    });

    return sections;
  }

  // Filas lado a lado
  List<Widget> _buildDetailRows(Map<String, dynamic> details) {
    List<Widget> rows = [];
    int index = 0;
    final entries = details.entries.toList();

    for (var entry in entries) {
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recuadro gris para el título
              Container(
                width: 110,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Recuadro blanco para la información
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      if (index < entries.length - 1) {
        rows.add(Divider(height: 1, thickness: 1, color: Colors.grey[200]));
      }
      index++;
    }

    return rows;
  }
}

class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedCard({required this.child, required this.onTap});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> {
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => scale = 0.96),
      onTapUp: (_) => setState(() => scale = 1),
      onTapCancel: () => setState(() => scale = 1),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}