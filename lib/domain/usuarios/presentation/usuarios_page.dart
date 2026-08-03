import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/global_bottom_nav.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/profile_menu_button.dart';
import 'providers/usuarios_provider.dart';
import '../domain/usuario_model.dart'; // FIX: antes era usuarios_entity.dart (UsuarioEntity)

const Color _pink = Color(0xFFFF4FA3);
const Color _bg = Color(0xFFF5F5F7);
const Color _text = Color(0xFF1C1C1E);
const Color _grey = Color(0xFF8E8E93);
const Color _border = Color(0xFFE8E8E8);
const Color _green = Color(0xFF00C853);
const Color _red = Color(0xFFE53935);

class UsuariosPage extends StatelessWidget {
  const UsuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UsuariosProvider(),
      child: const _UsuariosView(),
    );
  }
}

class _UsuariosView extends StatefulWidget {
  const _UsuariosView();

  @override
  State<_UsuariosView> createState() => _UsuariosViewState();
}

class _UsuariosViewState extends State<_UsuariosView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Toggle activo/inactivo con confirmación ────────────────────────────
  Future<void> _handleToggle(
    BuildContext context,
    UsuariosProvider provider,
    UsuarioModel usuario,
  ) async {
    final isActive = usuario.estado;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isActive ? 'Inactivar usuario' : 'Activar usuario'),
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
                  ? 'Usuario inactivado correctamente'
                  : 'Usuario activado correctamente'),
        ),
        backgroundColor: error != null ? _red : _green,
      ),
    );
  }

  // ── Eliminar con confirmación ───────────────────────────────────────────
  Future<void> _handleDelete(
    BuildContext context,
    UsuariosProvider provider,
    UsuarioModel usuario,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar usuario'),
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

    final error = await provider.deleteUsuario(usuario.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Usuario eliminado correctamente'),
        backgroundColor: error != null ? _red : _green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: const GlobalBottomNav(activeIndex: 1),
      body: SafeArea(
        child: Consumer<UsuariosProvider>(
          builder: (context, provider, __) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Row(
                    children: [
                      const AppBackButton(),
                      const SizedBox(width: 14),
                      const Text(
                        'Usuarios',
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: provider.search,
                      decoration: InputDecoration(
                        hintText: 'Buscar usuario...',
                        hintStyle: const TextStyle(
                          color: Color(0xFFAEAEB2),
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: Color(0xFFAEAEB2),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  provider.search('');
                                },
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  size: 18,
                                  color: Color(0xFFAEAEB2),
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
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
                            'No se encontraron usuarios',
                            style: TextStyle(color: _grey, fontSize: 14),
                          ),
                        )
                      : RefreshIndicator(
                          color: _pink,
                          onRefresh: () => provider.load(),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: provider.items.length,
                            itemBuilder: (context, index) {
                              final usuario = provider.items[index];
                              return _buildUsuarioCard(
                                context,
                                provider,
                                usuario,
                              );
                            },
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

  Widget _buildUsuarioCard(
    BuildContext context,
    UsuariosProvider provider,
    UsuarioModel usuario, // FIX: antes UsuarioEntity
  ) {
    final isActive = usuario.estado;
    final statusColor = isActive ? _green : _red;

    return GestureDetector(
      onTap: () => _showUsuarioDetail(context, usuario),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                    // DOC
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
                    // Nombre
                    Text(
                      usuario.nombreCompleto,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Estado
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
              // Botón Ver Detalle
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

  void _showUsuarioDetail(BuildContext context, UsuarioModel usuario) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: 'close',
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, animation, __) =>
          _UsuarioDetail(usuario: usuario, animation: animation),
      transitionBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );
  }
}

class _UsuarioDetail extends StatelessWidget {
  final UsuarioModel usuario; // FIX: antes UsuarioEntity
  final Animation<double> animation;

  const _UsuarioDetail({required this.usuario, required this.animation});

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
                            'Usuario',
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