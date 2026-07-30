import 'package:flutter/material.dart';
import '../../shared/widgets/global_bottom_nav.dart';
import '../../shared/widgets/profile_menu_button.dart';
import '../products/products_page.dart';
import 'product_category.dart';
import 'product_category_service.dart';

class ProductCategoriesPage extends StatefulWidget {
  const ProductCategoriesPage({super.key});

  @override
  State<ProductCategoriesPage> createState() => _ProductCategoriesPageState();
}

class _ProductCategoriesPageState extends State<ProductCategoriesPage> {
  final ProductCategoryService _service = ProductCategoryService();
  final TextEditingController _searchController = TextEditingController();
  List<ProductCategory> _categories = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final categories = await _service.getCategories();
      setState(() {
        _categories = categories;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<ProductCategory> get _filteredCategories {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) return _categories;
    return _categories.where((c) {
      final matchesName = c.nombre.toLowerCase().contains(query);
      final matchesEstado = query == 'activo'
          ? c.estadoLabel.toLowerCase() == 'activo'
          : query == 'inactivo'
              ? c.estadoLabel.toLowerCase() == 'inactivo'
              : c.estadoLabel.toLowerCase().contains(query);
      return matchesName || matchesEstado;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const GlobalBottomNav(),
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
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
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFFF8ACD), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF4DA6).withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_2_sharp, color: Color(0xFFFF4DA6), size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Categorías', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Buscar categoría...',
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
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFE91E8C)))
                  : _error != null
                      ? Center(child: Text(_error!))
                      : RefreshIndicator(
                          color: const Color(0xFFE91E8C),
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredCategories.length,
                            itemBuilder: (context, index) {
                              final item = _filteredCategories[index];
                              return card(context, item);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget card(BuildContext context, ProductCategory item) {
    return AnimatedCard(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (context, animation, secondaryAnimation) => ProductsPage(categoryId: item.id, categoryName: item.nombre),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.ease)),
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
            BoxShadow(color: const Color(0xFFFF4DA6).withValues(alpha: 0.10), blurRadius: 18, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(item.descripcion.isEmpty ? 'Sin descripción' : item.descripcion, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: item.isActivo ? Colors.green : Colors.red),
                    const SizedBox(width: 5),
                    Text(item.estadoLabel, style: TextStyle(color: item.isActivo ? Colors.green : Colors.red, fontWeight: FontWeight.w600, fontSize: 11)),
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
                  child: const Icon(Icons.arrow_forward_ios, size: 13, color: Color(0xFFE91E8C)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const AnimatedCard({super.key, required this.child, required this.onTap});

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
      child: AnimatedScale(scale: scale, duration: const Duration(milliseconds: 120), child: widget.child),
    );
  }
}