import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/global_bottom_nav.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/profile_menu_button.dart';
import '../../../shared/utils/responsive.dart';
import 'providers/empleados_provider.dart';
import '../../usuarios/domain/usuario_model.dart'; // Reutiliza el mismo modelo que Usuarios

const Color _pink = Color(0xFFFF4FA3);
const Color _bg = Color(0xFFF5F5F7);
const Color _text = Color(0xFF1C1C1E);
const Color _grey = Color(0xFF8E8E93);
const Color _green = Color(0xFF00C853);
const Color _red = Color(0xFFE53935);

class EmpleadosPage extends StatelessWidget {
  const EmpleadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmpleadosProvider(),
      child: const _EmpleadosView(),
    );
  }
}

class _EmpleadosView extends StatefulWidget {
  const _EmpleadosView();

  @override
  State<_EmpleadosView> createState() => _EmpleadosViewState();
}

class _EmpleadosViewState extends State<_EmpleadosView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Toggle activo/inactivo con confirmación ────────────────────────────
  Future<void> _handleToggle(
    BuildContext context,
    EmpleadosProvider provider,
    UsuarioModel usuario,
  ) async {
    final isActive = usuario.estado;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isActive ? 'Inactivar empleado' : 'Activar empleado'),
        content: Text(
          isActive
              ? '¿Deseas inactivar a "${usuario.nombreCompleto}"? No podrá iniciar sesión.'
              : '¿Deseas activar a "${usuario.nombreCompleto}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isActive ? 'Inactivar' : 'Activar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final error = await provider.toggleStatus(usuario.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ??
              (isActive
                  ? 'Empleado inactivado correctamente'
                  : 'Empleado activado correctamente'),
        ),
        backgroundColor: error != null ? _red : _green,
      ),
    );
  }

  // ── Eliminar con confirmación ───────────────────────────────────────────
  Future<void> _handleDelete(
    BuildContext context,
    EmpleadosProvider provider,
    UsuarioModel usuario,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar empleado'),
        content: Text(
          '¿Deseas eliminar a "${usuario.nombreCompleto}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: _red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final error = await provider.deleteEmpleado(usuario.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Empleado eliminado correctamente'),
        backgroundColor: error != null ? _red : _green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: const GlobalBottomNav(),
      body: SafeArea(
        child: Consumer<EmpleadosProvider>(
          builder: (context, provider, __) {
            return Column(
              children: [
                ResponsiveCenter(
                  maxWidth: 900,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Row(
                      children: [
                        const AppBackButton(),
                        const SizedBox(width: 14),
                        const Text(
                          'Empleados',
                          style: TextStyle(
                            color: _text,
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
                ),
                ResponsiveCenter(
                  maxWidth: 900,
                  child: Padding(
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
                              onChanged: provider.search,
                              decoration: const InputDecoration(
                                hintText: 'Buscar empleado...',
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
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: _pink,
                            strokeWidth: 2.5,
                          ),
                        )
                      : provider.error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  provider.error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: _grey),
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: () => provider.load(),
                                  child: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : provider.items.isEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron empleados',
                            style: TextStyle(color: _grey, fontSize: 14),
                          ),
                        )
                      : RefreshIndicator(
                          color: _pink,
                          onRefresh: () => provider.load(),
                          child: ResponsiveCenter(
                            maxWidth: 1100,
                            child: ResponsiveCardGrid(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              itemCount: provider.items.length,
                              childAspectRatio: 2.8,
                              itemBuilder: (context, index) {
                                final usuario = provider.items[index];
                                return _buildEmpleadoCard(
                                  context,
                                  provider,
                                  usuario,
                                );
                              },
                            ),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmpleadoCard(
    BuildContext context,
    EmpleadosProvider provider,
    UsuarioModel usuario, // FIX: antes UsuarioEntity
  ) {
    final isActive = usuario.estado;
    final statusColor = isActive ? _green : _red;

    return GestureDetector(
      onTap: () => _showEmpleadoDetail(context, usuario),
      child: Container(
        // El espaciado entre tarjetas ya lo maneja ResponsiveCardGrid
        // (lista o grilla, según el ancho), así que ya no se necesita
        // este margen propio.
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _pink.withOpacity(0.22), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: _pink.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DOC: ${usuario.numeroDocumento}',
                      style: const TextStyle(
                        color: _grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      usuario.nombreCompleto,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          usuario.estadoLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _pink.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: _pink.withOpacity(0.4)),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: _pink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmpleadoDetail(BuildContext context, UsuarioModel usuario) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: 'close',
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, animation, __) =>
          _EmpleadoDetail(usuario: usuario, animation: animation),
      transitionBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );
  }
}

class _EmpleadoDetail extends StatelessWidget {
  final UsuarioModel usuario; // FIX: antes UsuarioEntity
  final Animation<double> animation;

  const _EmpleadoDetail({required this.usuario, required this.animation});

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
        ),
        ResponsiveSheet(
          maxWidth: 560,
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
                constraints: BoxConstraints(maxHeight: sh * 0.78),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4FA3).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.category_rounded,
                              color: Color(0xFFFF4FA3),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Empleado',
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
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Center(
                              child: Text(
                                usuario.nombreCompleto,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: _text,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Center(
                              child: Text(
                                'DOC: ${usuario.numeroDocumento}',
                                style: const TextStyle(
                                  color: _grey,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: (usuario.estado ? _green : _red)
                                      .withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: usuario.estado ? _green : _red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      usuario.estadoLabel,
                                      style: TextStyle(
                                        color: usuario.estado ? _green : _red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F7F9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  _DetailRow(
                                    icon: Icons.mail_outline_rounded,
                                    label: 'Correo electrónico',
                                    value: usuario.correo,
                                  ),
                                  _DetailRow(
                                    icon: Icons.badge_outlined,
                                    label: 'Rol',
                                    value: usuario.rolNombre ?? 'Sin rol',
                                  ),
                                  _DetailRow(
                                    icon: Icons.description_outlined,
                                    label: 'Tipo de documento',
                                    value: usuario.tipoDocumento,
                                  ),
                                  _DetailRow(
                                    icon: Icons.numbers_rounded,
                                    label: 'Documento',
                                    value: usuario.numeroDocumento,
                                    isLast: true,
                                  ),
                                ],
                              ),
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF4FA3), Color(0xFFFF6EC7)],
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFEDEDF0), width: 1),
              ),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: _pink),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _grey,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
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
