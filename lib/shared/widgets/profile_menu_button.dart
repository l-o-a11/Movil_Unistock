import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../../domain/auth/presentation/edit_profile_page.dart';
import '../../domain/Login_page.dart';

const _pink = Color(0xFFFF4FA3);
const _pinkSoft = Color(0xFFFFE3F2);
const _text = Color(0xFF171827);
const _muted = Color(0xFF98A1B2);
const _line = Color(0xFFF0F1F4);
const _green = Color(0xFF22C55E);

class ProfileMenuButton extends StatefulWidget {
  final double? size;
  final double? iconSize;
  final bool useTheme;

  const ProfileMenuButton({
    super.key,
    this.size,
    this.iconSize,
    this.useTheme = false,
  });

  @override
  State<ProfileMenuButton> createState() => _ProfileMenuButtonState();
}

class _ProfileMenuButtonState extends State<ProfileMenuButton> {
  final AuthService _authService = AuthService();
  late final Future<Map<String, dynamic>?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _authService.getUser();
  }

  Future<void> _showProfileMenu(BuildContext context) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Perfil',
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.08),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.transparent),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Material(
                    type: MaterialType.transparency,
                    child: _ProfilePanel(
                      userFuture: _userFuture,
                      onEditAccount: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfilePage(),
                          ),
                        );
                      },
                      onLogout: () async {
                        await _authService.clearSession();
                        if (!context.mounted) return;

                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final btnSize = widget.size ?? 40.0;
    final iSize = widget.iconSize ?? 18.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(btnSize / 2),
        onTap: () => _showProfileMenu(context),
        child: Container(
          width: btnSize,
          height: btnSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: const Color(0xFFFF8ACD), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(255, 77, 166, 0.35),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.person_2_sharp,
            color: const Color(0xFFFF4DA6),
            size: iSize,
          ),
        ),
      ),
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  final Future<Map<String, dynamic>?> userFuture;
  final VoidCallback onEditAccount;
  final VoidCallback onLogout;

  const _ProfilePanel({
    required this.userFuture,
    required this.onEditAccount,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: userFuture,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final nombre = user?['nombreCompleto']?.toString() ?? 'Usuario';
        final correo = user?['correo']?.toString() ?? 'Sin correo';
        final rol = user?['rolNombre']?.toString() ?? 'Sin rol';
        final sede = user?['sedeNombre']?.toString() ?? 'Sin sede';

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.16),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                  child: Row(
                    children: [
                      _ProfileAvatar(size: 58),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _text,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              rol,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF6D7482),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: _line),

                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 17, 22, 18),
                  child: Column(
                    children: [
                      _InfoBlock(label: 'CORREO', value: correo),
                      const SizedBox(height: 17),
                      _InfoBlock(label: 'ROL', value: rol),
                      const SizedBox(height: 17),
                      _InfoBlock(label: 'SEDE', value: sede),
                    ],
                  ),
                ),

                const Divider(height: 1, color: _line),

                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                  child: Column(
                    children: [
                      _ActionRow(
                        icon: Icons.settings_outlined,
                        iconBg: const Color(0xFFF5F6F8),
                        iconColor: const Color(0xFF69707D),
                        title: 'Editar Cuenta',
                        subtitle: 'Modificar información personal',
                        titleColor: _text,
                        onTap: onEditAccount,
                      ),
                      const SizedBox(height: 6),
                      _ActionRow(
                        icon: Icons.logout_rounded,
                        iconBg: _pinkSoft,
                        iconColor: _pink,
                        title: 'Cerrar Sesión',
                        titleColor: _pink,
                        onTap: onLogout,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final double size;

  const _ProfileAvatar({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: _pinkSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline_rounded,
              color: _pink,
              size: size * 0.48,
            ),
          ),
          Positioned(
            right: 1,
            bottom: 2,
            child: Container(
              width: size * 0.22,
              height: size * 0.22,
              decoration: BoxDecoration(
                color: _green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _text,
              fontSize: 15.5,
              height: 1.25,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color titleColor;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
