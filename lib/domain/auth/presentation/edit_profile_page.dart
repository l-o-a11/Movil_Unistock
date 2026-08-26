// lib/domain/auth/presentation/edit_profile_page.dart
//
// Pantalla de "Editar perfil" para el usuario autenticado.
// Dos secciones independientes, cada una contra su propio endpoint:
//   - Datos personales (nombreCompleto, correo) → PUT /auth/profile
//   - Cambiar contraseña (passwordActual/Nueva/Confirmar) → PUT /auth/change-password
//
// Se precarga con el usuario guardado en ApiClient (viene del login) para
// no depender de un GET /auth/me extra.

import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../../../shared/utils/responsive.dart';
import '../../dashboard/theme/app_theme.dart';
import '../data/auth_service.dart';
import '../domain/auth_user.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _authService = AuthService();

  AuthUser? _user;
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final raw = await ApiClient.instance.getUser();
    setState(() {
      _user = raw != null ? AuthUser.fromJson(raw) : null;
      _loadingUser = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        backgroundColor: AppTheme.bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Editar perfil',
          style: TextStyle(
            color: AppTheme.titleColor,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.titleColor),
      ),
      body: _loadingUser
          ? const Center(child: CircularProgressIndicator(color: AppTheme.pink))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: ResponsiveCenter(
                  maxWidth: 560,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileHeader(user: _user),
                      const SizedBox(height: 20),
                      _PersonalDataCard(
                        user: _user,
                        authService: _authService,
                        onUpdated: (updated) => setState(() => _user = updated),
                      ),
                      const SizedBox(height: 16),
                      _ChangePasswordCard(authService: _authService),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

// ── Header con avatar de iniciales ────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final AuthUser? user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.pink, Color(0xFFFF8ACD)],
              ),
              boxShadow: AppTheme.glowShadow(AppTheme.pink),
            ),
            alignment: Alignment.center,
            child: Text(
              user?.iniciales ?? '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user?.nombreCompleto ?? 'Usuario',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.titleColor,
            ),
          ),
          if (user?.rolNombre != null) ...[
            const SizedBox(height: 2),
            Text(
              user!.rolNombre!,
              style: const TextStyle(fontSize: 13, color: AppTheme.mutedColor),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Card: datos personales ────────────────────────────────────────────────
class _PersonalDataCard extends StatefulWidget {
  final AuthUser? user;
  final AuthService authService;
  final ValueChanged<AuthUser> onUpdated;
  const _PersonalDataCard({
    required this.user,
    required this.authService,
    required this.onUpdated,
  });

  @override
  State<_PersonalDataCard> createState() => _PersonalDataCardState();
}

class _PersonalDataCardState extends State<_PersonalDataCard> {
  late final _nombreController = TextEditingController(
    text: widget.user?.nombreCompleto ?? '',
  );
  late final _correoController = TextEditingController(
    text: widget.user?.correo ?? '',
  );

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final nombre = _nombreController.text.trim();
    final correo = _correoController.text.trim();

    if (nombre.isEmpty || correo.isEmpty) {
      setState(() {
        _errorMessage = 'Nombre y correo no pueden estar vacíos';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final updated = await widget.authService.updateProfile(
        nombreCompleto: nombre,
        correo: correo,
      );
      widget.onUpdated(updated);
      if (!mounted) return;
      setState(() => _successMessage = 'Perfil actualizado correctamente');
    } on ApiException catch (e) {
      // 409 → correo ya en uso por otro usuario
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = 'No se pudo conectar con el servidor');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.badge_outlined,
      title: 'Datos personales',
      children: [
        const _FieldLabel('Nombre completo'),
        _ProfileTextField(
          controller: _nombreController,
          hintText: 'Tu nombre completo',
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 14),
        const _FieldLabel('Correo electrónico'),
        _ProfileTextField(
          controller: _correoController,
          hintText: 'tucorreo@ejemplo.com',
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 10),
          _InlineMessage(text: _errorMessage!, isError: true),
        ],
        if (_successMessage != null) ...[
          const SizedBox(height: 10),
          _InlineMessage(text: _successMessage!, isError: false),
        ],
        const SizedBox(height: 16),
        _PrimaryButton(
          label: _isLoading ? 'Guardando...' : 'Guardar cambios',
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _handleSave,
        ),
      ],
    );
  }
}

// ── Card: cambiar contraseña ────────────────────────────────────────────
class _ChangePasswordCard extends StatefulWidget {
  final AuthService authService;
  const _ChangePasswordCard({required this.authService});

  @override
  State<_ChangePasswordCard> createState() => _ChangePasswordCardState();
}

class _ChangePasswordCardState extends State<_ChangePasswordCard> {
  final _actualController = TextEditingController();
  final _nuevaController = TextEditingController();
  final _confirmarController = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _obscure3 = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _actualController.dispose();
    _nuevaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    final actual = _actualController.text;
    final nueva = _nuevaController.text;
    final confirmar = _confirmarController.text;

    if (actual.isEmpty || nueva.isEmpty || confirmar.isEmpty) {
      setState(() {
        _errorMessage = 'Completa los tres campos';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final message = await widget.authService.changePassword(
        passwordActual: actual,
        passwordNueva: nueva,
        confirmarPassword: confirmar,
      );
      if (!mounted) return;
      setState(() => _successMessage = message);
      _actualController.clear();
      _nuevaController.clear();
      _confirmarController.clear();
    } on ApiException catch (e) {
      // 400 → contraseña actual incorrecta, no coinciden, o política de seguridad
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = 'No se pudo conectar con el servidor');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.lock_outline_rounded,
      title: 'Cambiar contraseña',
      children: [
        const Text(
          'Mínimo 8 caracteres, con mayúscula, minúscula, número y un carácter especial (* - _ # ~ \$).',
          style: TextStyle(
            fontSize: 12.5,
            color: AppTheme.mutedColor,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        const _FieldLabel('Contraseña actual'),
        _ProfileTextField(
          controller: _actualController,
          hintText: 'Tu contraseña actual',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscure1,
          suffixIcon: _VisibilityToggle(
            obscure: _obscure1,
            onTap: () => setState(() => _obscure1 = !_obscure1),
          ),
        ),
        const SizedBox(height: 14),
        const _FieldLabel('Nueva contraseña'),
        _ProfileTextField(
          controller: _nuevaController,
          hintText: 'Nueva contraseña',
          prefixIcon: Icons.lock_reset_rounded,
          obscureText: _obscure2,
          suffixIcon: _VisibilityToggle(
            obscure: _obscure2,
            onTap: () => setState(() => _obscure2 = !_obscure2),
          ),
        ),
        const SizedBox(height: 14),
        const _FieldLabel('Confirmar nueva contraseña'),
        _ProfileTextField(
          controller: _confirmarController,
          hintText: 'Repite la nueva contraseña',
          prefixIcon: Icons.lock_reset_rounded,
          obscureText: _obscure3,
          suffixIcon: _VisibilityToggle(
            obscure: _obscure3,
            onTap: () => setState(() => _obscure3 = !_obscure3),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 10),
          _InlineMessage(text: _errorMessage!, isError: true),
        ],
        if (_successMessage != null) ...[
          const SizedBox(height: 10),
          _InlineMessage(text: _successMessage!, isError: false),
        ],
        const SizedBox(height: 16),
        _PrimaryButton(
          label: _isLoading ? 'Actualizando...' : 'Actualizar contraseña',
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _handleChangePassword,
        ),
      ],
    );
  }
}

// ── Widgets de presentación compartidos ───────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.pinkLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.pink, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.titleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: AppTheme.titleColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppTheme.mutedColor, fontSize: 13.5),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 8),
          child: Icon(prefixIcon, color: AppTheme.mutedColor, size: 19),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.pink, width: 1.6),
        ),
      ),
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  final bool obscure;
  final VoidCallback onTap;
  const _VisibilityToggle({required this.obscure, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: const Color(0xFFBBBBBB),
        size: 20,
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  final String text;
  final bool isError;
  const _InlineMessage({required this.text, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color = isError ? const Color(0xFFE53935) : const Color(0xFF22A05C);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isError
              ? Icons.error_outline_rounded
              : Icons.check_circle_outline_rounded,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.pink,
          disabledBackgroundColor: const Color(0xFFFFB8D9),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.2,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
