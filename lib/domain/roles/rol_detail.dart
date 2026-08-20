import 'dart:ui';
import 'package:flutter/material.dart';
import 'rol.dart';

Future<void> showRolDetail(BuildContext context, Rol rol) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      pageBuilder: (ctx, animation, _) =>
          _RolDetailSheet(rol: rol, animation: animation),
    ),
  );
}

class _RolDetailSheet extends StatelessWidget {
  final Rol rol;
  final Animation<double> animation;

  const _RolDetailSheet({required this.rol, required this.animation});

  static const _pink = Color(0xFFFF4FA3);
  static const _text = Color(0xFF1C1C1E);
  static const _grey = Color(0xFF8E8E93);
  static const _green = Color(0xFF34C759);
  static const _red = Color(0xFFFF3B30);

  // Colores por privilegio
  static const _privColors = {
    'leer': Color(0xFF007AFF), // azul
    'crear': Color(0xFF34C759), // verde
    'actualizar': Color(0xFFFF9500), // naranja
    'eliminar': Color(0xFFFF3B30), // rojo
  };

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
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                constraints: BoxConstraints(maxHeight: sh * 0.85),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
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
                            child: const Icon(Icons.shield_outlined,
                                color: _pink, size: 22),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Detalle del rol',
                            style: TextStyle(
                                color: _text,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
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
                              child: const Icon(Icons.close_rounded,
                                  size: 16, color: Color(0xFF555555)),
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
                            // Nombre + badge admin
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    rol.nombre,
                                    style: const TextStyle(
                                      color: _text,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (rol.isAdmin)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _pink.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Admin',
                                      style: TextStyle(
                                        color: _pink,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Descripción
                            Text(
                              rol.descripcion,
                              style: const TextStyle(
                                  color: _grey,
                                  fontSize: 13,
                                  height: 1.5),
                            ),
                            const SizedBox(height: 16),
                            // Estado
                            const _SectionLabel('Estado'),
                            const SizedBox(height: 4),
                            Row(children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: rol.isActivo ? _green : _red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                rol.estadoLabel,
                                style: TextStyle(
                                  color: rol.isActivo ? _green : _red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ]),
                            const SizedBox(height: 20),
                            // Módulos y privilegios
                            const _SectionLabel('Módulos y permisos'),
                            const SizedBox(height: 12),
                            ...rol.permisos.map((m) => _ModuloTile(
                                  modulo: m,
                                  moduloNombre: rol.moduloNombre(m),
                                  privilegioNombre: rol.privilegioNombre,
                                  privColors: _privColors,
                                )),
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
                                fontWeight: FontWeight.w700),
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

/// Fila de un módulo con sus chips de privilegios
class _ModuloTile extends StatelessWidget {
  final ModuloRol modulo;
  final String moduloNombre;
  final String Function(String) privilegioNombre;
  final Map<String, Color> privColors;

  const _ModuloTile({
    required this.modulo,
    required this.moduloNombre,
    required this.privilegioNombre,
    required this.privColors,
  });

  static const _text = Color(0xFF1C1C1E);
  static const _grey = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.widgets_outlined, size: 16, color: _grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              moduloNombre,
              style: const TextStyle(
                color: _text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Chips de privilegios
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: modulo.privilegios.map((privId) {
              final color = privColors[privId] ?? const Color(0xFF8E8E93);
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  privilegioNombre(privId),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
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
