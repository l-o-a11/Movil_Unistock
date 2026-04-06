import 'package:flutter/material.dart';
import '../../shared/widgets/global_bottom_nav.dart';
import '../products/products_page.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {"id": "CAT - 18", "title": "Crop Top", "desc": "Prenda moderna y ver..."},
      {"id": "CAT - 18", "title": "Crop Top", "desc": "Prenda moderna y ver..."},
      {"id": "CAT - 80", "title": "Buzos", "desc": "Perfecta para uso ca..."},
      {"id": "CAT - 80", "title": "Buzos", "desc": "Perfecta para uso ca..."},
      {"id": "CAT - 42", "title": "Bodys", "desc": "Proporciona una silu..."},
      {"id": "CAT - 42", "title": "Bodys", "desc": "Proporciona una silu..."},
      {"id": "CAT - 20", "title": "Enterizos", "desc": "Pieza completa que..."},
    ];

    return Scaffold(
      bottomNavigationBar: const GlobalBottomNav(),
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
                  // BOTONES SUPERIORES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón atrás
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
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
                      
                      // Botón perfil
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

                  // TÍTULO
                  const Text(
                    "Categorías",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // BUSCADOR
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Buscar categoría...",
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
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final item = categories[index];
                  return card(context, item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TARJETA CON ANIMACIÓN
  Widget card(BuildContext context, Map item) {
    return AnimatedCard(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (_, __, ___) => const ProductsPage(),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.ease,
                )),
                child: child,
              );
            },
          ),
        );
      },
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // TEXTOS
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["id"],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item["title"],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item["desc"],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
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
}

// ANIMACIÓN DE CLICK
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const AnimatedCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<AnimatedCard> createState() => AnimatedCardState();
}

class AnimatedCardState extends State<AnimatedCard> {
  double scale = 1.0;

  void onTapDown(_) => setState(() => scale = 0.96);
  void onTapUp(_) => setState(() => scale = 1.0);
  void onTapCancel() => setState(() => scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}