import 'dart:ui';
import 'package:flutter/material.dart';
import 'insumo.dart';

/// Muestra el detalle de un insumo como bottom sheet con backdrop blur.
/// Uso:
///   await showInsumoDetail(context, insumo);
Future<void> showInsumoDetail(BuildContext context, Insumo insumo) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      pageBuilder: (ctx, animation, _) =>
          _InsumoDetailSheet(insumo: insumo, animation: animation),
    ),
  );
}

class _InsumoDetailSheet extends StatelessWidget {
  final Insumo insumo;
  final Animation<double> animation;

  const _InsumoDetailSheet({required this.insumo, required this.animation});

  static const _pink = Color(0xFFFF4FA3);
  static const _text = Color(0xFF1C1C1E);
  static const _grey = Color(0xFF8E8E93);
  static const _green = Color(0xFF34C759);
  static const _red = Color(0xFFFF3B30);

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Backdrop
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
        ),
        // Sheet
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                constraints: BoxConstraints(maxHeight: sh * 0.82),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _pink.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: _pink,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Detalle del insumo',
                            style: TextStyle(
                              color: _text,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    // Body
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nombre
                            Text(
                              insumo.nombre,
                              style: const TextStyle(
                                color: _text,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: ${insumo.id}',
                              style: const TextStyle(
                                color: _grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Estado
                            const _SectionLabel('Estado'),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: insumo.isActivo ? _green : _red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  insumo.estadoLabel,
                                  style: TextStyle(
                                    color: insumo.isActivo ? _green : _red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // Campos principales
                            _InfoRow(
                              icon: Icons.category_outlined,
                              label: 'Categoría',
                              value: insumo.categoria,
                            ),
                            _InfoRow(
                              icon: Icons.straighten_outlined,
                              label: 'Unidad de medida',
                              value: insumo.medida,
                            ),
                            _InfoRow(
                              icon: Icons.inventory_outlined,
                              label: 'Stock disponible',
                              value: '${insumo.stock} ${insumo.medida}',
                            ),
                            _InfoRow(
                              icon: Icons.attach_money_rounded,
                              label: 'Valor por ${insumo.medida}',
                              value:
                                  '\$${insumo.valorMedida.toStringAsFixed(2)}',
                              isLast: insumo.propiedades.isEmpty,
                            ),
                            // Propiedades dinámicas
                            if (insumo.propiedades.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              const _SectionLabel('Propiedades'),
                              const SizedBox(height: 10),
                              ...insumo.propiedades.asMap().entries.map(
                                (e) => _InfoRow(
                                  icon: Icons.label_outline_rounded,
                                  label: insumo.propiedadNombre(e.value),
                                  value: e.value.valor,
                                  isLast:
                                      e.key == insumo.propiedades.length - 1,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    // Botón cerrar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_pink, Color(0xFFFF6EC7)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Cerrar',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      color: Color(0xFF8E8E93),
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  static const _grey = Color(0xFF8E8E93);
  static const _text = Color(0xFF1C1C1E);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: _grey,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
