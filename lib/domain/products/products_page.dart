import 'package:flutter/material.dart';
import '../../shared/utils/paginated_list.dart';
import '../../shared/widgets/app_back_button.dart';
import '../../shared/widgets/global_bottom_nav.dart';
import '../../shared/widgets/profile_menu_button.dart';
import 'product.dart';
import 'product_service.dart';

class ProductsPage extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const ProductsPage({super.key, this.categoryId, this.categoryName});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductService _service = ProductService();
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
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
      final products = await _service.getProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
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

  List<Product> get _allFilteredProducts {
    final query = _searchController.text.toLowerCase().trim();
    return _products.where((p) {
      final matchesCategory =
          widget.categoryId == null || p.categoryId == widget.categoryId;
      final matchesQuery =
          query.isEmpty ||
          p.nombre.toLowerCase().contains(query) ||
          p.referencia.toLowerCase().contains(query) ||
          (query == 'activo'
              ? p.estadoLabel.toLowerCase() == 'activo'
              : query == 'inactivo'
              ? p.estadoLabel.toLowerCase() == 'inactivo'
              : p.estadoLabel.toLowerCase().contains(query));
      return matchesCategory && matchesQuery;
    }).toList();
  }

  List<Product> get _filteredProducts {
    return paginateItems(
      _allFilteredProducts,
      visibleCount: _visibleCount,
      pageSize: 5,
    );
  }

  bool get _hasMoreProducts {
    return hasMoreItems(
      _allFilteredProducts,
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
                  Text(
                    widget.categoryName ?? 'Productos',
                    style: const TextStyle(
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
                        itemCount: _filteredProducts.length + (_hasMoreProducts ? 1 : 0),
                        itemBuilder: (context, index) {
                           if (index == _filteredProducts.length) {
                             return Padding(
                               padding: const EdgeInsets.only(top: 8, bottom: 16),
                               child: Center(
                                 child: OutlinedButton(
                                   onPressed: () {
                                     setState(() {
                                       _visibleCount = nextVisibleCount(
                                         _allFilteredProducts,
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

                          final item = _filteredProducts[index];
                          return _productCard(context, item);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(BuildContext context, Product item) {
    final imageUrl = item.imagenesUrl.isNotEmpty
        ? item.imagenesUrl.first
        : null;

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
              color: const Color(0xFFFF4DA6).withValues(alpha: 0.10),
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
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null
                  ? const Icon(Icons.image, color: Colors.white70)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.referencia,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('COP \$${item.precio.toStringAsFixed(0)}'),
                  Text(
                    'STOCK: ${item.stock}',
                    style: const TextStyle(color: Colors.grey),
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

  // 🔥 FICHA TÉCNICA SIN SCROLL - Tamaño fijo
  void _showTechnicalSheet(BuildContext context, Product product) {
    final technicalSheet = {
      'Detalles del producto': {
        'Referencia': product.referencia,
        'Nombre': product.nombre,
        'Precio': 'COP ${product.precio.toStringAsFixed(0)}',
        'Stock': product.stock.toString(),
        'Estado': product.estadoLabel,
      },
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
                mainAxisSize:
                    MainAxisSize.min, // 🔥 IMPORTANTE: Para que no haya scroll
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
                            'Ficha Técnica - ${product.nombre}',
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
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Color(0xFFE91E8C),
                            ),
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
                child: Column(children: _buildDetailRows(sectionContent)),
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
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 10,
                ),
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    entry.value.toString(),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
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
