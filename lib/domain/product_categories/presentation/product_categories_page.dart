import 'package:flutter/material.dart';
import '../../../shared/utils/paginated_list.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/global_bottom_nav.dart';
import '../../../shared/widgets/profile_menu_button.dart';
import '../../products/presentation/products_page.dart';
import '../domain/product_category.dart';
import '../data/product_category_service.dart';

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
  int _visibleCount = 5;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      if (!mounted) return;
      setState(() {
        _loading = true;
        _error = null;
      });
      final categories = await _service.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<ProductCategory> get _allFilteredCategories {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      return _categories;
    }

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

  List<ProductCategory> get _filteredCategories {
    return paginateItems(
      _allFilteredCategories,
      visibleCount: _visibleCount,
      pageSize: 5,
    );
  }

  bool get _hasMoreCategories {
    return hasMoreItems(
      _allFilteredCategories,
      visibleCount: _visibleCount,
      pageSize: 5,
    );
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
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 14),
                  const Text(
                    'Categorías',
                    style: TextStyle(
                      color: Color(0xFF1C1C1E),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Spacer(),
                  ProfileMenuButton(size: 42, iconSize: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.search_rounded,
                      color: Color(0xFFAEAEB2),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) {
                          setState(() {
                            _visibleCount = 5;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Buscar por nombre...',
                          hintStyle: TextStyle(
                            color: Color(0xFFAEAEB2),
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE91E8C),
                      ),
                    )
                  : _error != null
                  ? Center(child: Text(_error!))
                  : RefreshIndicator(
                      color: const Color(0xFFE91E8C),
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredCategories.length + (_hasMoreCategories ? 1 : 0),
                        itemBuilder: (context, index) {
                           if (index == _filteredCategories.length) {
                             return Padding(
                               padding: const EdgeInsets.only(top: 8, bottom: 16),
                               child: Center(
                                 child: OutlinedButton(
                                   onPressed: () {
                                     setState(() {
                                       _visibleCount = nextVisibleCount(
                                         _allFilteredCategories,
                                         visibleCount: _visibleCount,
                                         pageSize: 5,
                                       );
                                     });
                                   },
                                   style: OutlinedButton.styleFrom(
                                     foregroundColor: const Color(0xFFFF4FA3),
                                     side: const BorderSide(
                                       color: Color(0xFFFF4FA3),
                                       width: 1.2,
                                     ),
                                     shape: RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(10),
                                     ),
                                   ),
                                   child: const Text('Ver más'),
                                 ),
                               ),
                             );
                           }

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
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProductsPage(categoryId: item.id, categoryName: item.nombre),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                        .animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.ease,
                          ),
                        ),
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
              color: const Color(0xFFFF4DA6).withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.descripcion.isEmpty
                        ? 'Sin descripción'
                        : item.descripcion,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: item.isActivo ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      item.estadoLabel,
                      style: TextStyle(
                        color: item.isActivo ? Colors.green : Colors.red,
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
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}
