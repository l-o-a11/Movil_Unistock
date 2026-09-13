import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/global_bottom_nav.dart';
import '../../../shared/widgets/profile_menu_button.dart';
import '../domain/usuario_model.dart';
import 'providers/usuarios_provider.dart';
import 'widgets/usuario_detail_sheet.dart';

const _pink = Color(0xFFFF4FA3);
const _background = Color(0xFFF5F5F7);
const _text = Color(0xFF1C1C1E);
const _grey = Color(0xFF8E8E93);
const _green = Color(0xFF00C853);
const _red = Color(0xFFE53935);

class UsuariosPage extends StatelessWidget {
  const UsuariosPage({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => UsuariosProvider(),
    child: const _UsuariosView(),
  );
}

class _UsuariosView extends StatefulWidget {
  const _UsuariosView();

  @override
  State<_UsuariosView> createState() => _UsuariosViewState();
}

class _UsuariosViewState extends State<_UsuariosView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _changeStatus(
    UsuariosProvider provider,
    UsuarioModel user,
  ) async {
    final action = user.estado ? 'inactivar' : 'activar';
    final confirmed = await _confirm(
      '¿Deseas $action a "${user.nombreCompleto}"?',
      action,
    );
    if (confirmed != true) return;
    final error = await provider.toggleStatus(user.id);
    if (mounted)
      _notify(error ?? 'Usuario actualizado correctamente', error != null);
  }

  Future<void> _delete(UsuariosProvider provider, UsuarioModel user) async {
    final confirmed = await _confirm(
      '¿Deseas eliminar a "${user.nombreCompleto}"?',
      'eliminar',
    );
    if (confirmed != true) return;
    final error = await provider.deleteUsuario(user.id);
    if (mounted)
      _notify(error ?? 'Usuario eliminado correctamente', error != null);
  }

  Future<bool?> _confirm(String message, String action) => showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('${action[0].toUpperCase()}${action.substring(1)} usuario'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(action),
        ),
      ],
    ),
  );

  void _notify(String message, bool isError) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? _red : _green,
        ),
      );

  void _showDetail(UsuarioModel user) => showGeneralDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    barrierLabel: 'close',
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (_, animation, __) =>
        UsuarioDetailSheet(usuario: user, animation: animation),
    transitionBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _background,
    bottomNavigationBar: const GlobalBottomNav(),
    body: SafeArea(
      child: Consumer<UsuariosProvider>(
        builder: (context, provider, _) => Column(
          children: [
            _Header(),
            _SearchField(
              controller: _searchController,
              onChanged: provider.search,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _Body(
                provider: provider,
                onTap: _showDetail,
                onToggle: _changeStatus,
                onDelete: _delete,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ResponsiveCenter(
    maxWidth: 900,
    child: Padding(
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
            ),
          ),
          const Spacer(),
          ProfileMenuButton(size: 42, iconSize: 20),
        ],
      ),
    ),
  );
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => ResponsiveCenter(
    maxWidth: 900,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Buscar usuario...',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFFAEAEB2),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ),
  );
}

class _Body extends StatelessWidget {
  const _Body({
    required this.provider,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  final UsuariosProvider provider;
  final ValueChanged<UsuarioModel> onTap;
  final Future<void> Function(UsuariosProvider, UsuarioModel) onToggle;
  final Future<void> Function(UsuariosProvider, UsuarioModel) onDelete;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading)
      return const Center(child: CircularProgressIndicator(color: _pink));
    if (provider.error != null)
      return Center(
        child: TextButton(
          onPressed: provider.load,
          child: Text(provider.error!),
        ),
      );
    if (provider.items.isEmpty)
      return const Center(
        child: Text(
          'No se encontraron usuarios',
          style: TextStyle(color: _grey),
        ),
      );

    return RefreshIndicator(
      color: _pink,
      onRefresh: provider.load,
      child: ResponsiveCenter(
        maxWidth: 900,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: provider.visibleItems.length + (provider.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == provider.visibleItems.length)
              return Center(
                child: OutlinedButton(
                  onPressed: provider.showMore,
                  child: const Text('Ver más'),
                ),
              );
            final user = provider.visibleItems[index];
            return _UserCard(
              user: user,
              onTap: () => onTap(user),
              onToggle: () => onToggle(provider, user),
              onDelete: () => onDelete(provider, user),
            );
          },
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  final UsuarioModel user;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = user.estado ? _green : _red;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        title: Text(
          user.nombreCompleto,
          style: const TextStyle(color: _text, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          'DOC: ${user.numeroDocumento}\n${user.estadoLabel}',
          style: TextStyle(color: color, fontSize: 12),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => value == 'status' ? onToggle() : onDelete(),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'status',
              child: Text(user.estado ? 'Inactivar' : 'Activar'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }
}
