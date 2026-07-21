import 'dart:ui';
import 'package:flutter/material.dart';
import 'sede.dart';

Future<void> showSedeDetail(BuildContext context, Sede sede) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      pageBuilder: (ctx, animation, _) =>
          _SedeDetailSheet(sede: sede, animation: animation),
    ),
  );
}

class _SedeDetailSheet extends StatelessWidget {
  final Sede sede;
  final Animation<double> animation;

  const _SedeDetailSheet({required this.sede, required this.animation});

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
                constraints: BoxConstraints(maxHeight: sh * 0.6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
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
                              Icons.location_on_outlined,
                              color: _pink,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              sede.nombre,
                              style: const TextStyle(
                                color: _text,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
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
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${sede.id}',
                              style: const TextStyle(
                                color: _grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Ubicación',
                              style: TextStyle(
                                color: Color(0xFF8E8E93),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${sede.ciudad} · ${sede.barrio}',
                              style: const TextStyle(
                                color: _grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              sede.direccion,
                              style: const TextStyle(
                                color: _grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Teléfono',
                              style: TextStyle(
                                color: Color(0xFF8E8E93),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              sede.telefono,
                              style: const TextStyle(
                                color: _grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Estado',
                              style: TextStyle(
                                color: Color(0xFF8E8E93),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: sede.isActivo ? _green : _red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  sede.estadoLabel,
                                  style: TextStyle(
                                    color: sede.isActivo ? _green : _red,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_pink, Color(0xFFFF6EC7)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
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
