import 'package:flutter/material.dart';

const _pink = Color(0xFFFF4FA3);
const _pinkLight = Color(0xFFFF79BB);
const _textDark = Color(0xFF1C1C1C);
const _muted = Color(0xFFAAAAAA);
const _fieldBg = Color(0xFFF5F5F5);

class StepShell extends StatelessWidget {
  const StepShell({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ),
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE8F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: _pink, size: 28),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, color: _muted, height: 1.4),
          ),
        ],
        const SizedBox(height: 20),
        ...children.map(
          (child) =>
              Padding(padding: const EdgeInsets.only(bottom: 12), child: child),
        ),
      ],
    ),
  );
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    onSubmitted: onSubmitted,
    style: const TextStyle(fontSize: 14, color: _textDark),
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF9999AB), fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFFACAFC5), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _fieldBg,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _pink, width: 1.8),
      ),
    ),
  );
}

class VisibilityToggle extends StatelessWidget {
  const VisibilityToggle({
    super.key,
    required this.obscure,
    required this.onTap,
  });

  final bool obscure;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap,
    icon: Icon(
      obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      color: const Color(0xFFBBBBBB),
      size: 21,
    ),
  );
}

class ErrorText extends StatelessWidget {
  const ErrorText(
    this.message, {
    super.key,
    this.color = const Color(0xFFE53935),
  });

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    message,
    style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500),
  );
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _pink,
        disabledBackgroundColor: const Color(0xFFFFB8D9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: isLoading
          ? const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.4,
            )
          : Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    ),
  );
}

class PasswordRules extends StatelessWidget {
  const PasswordRules({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    final rules = <MapEntry<bool, String>>[
      MapEntry(password.length >= 8, 'Mínimo 8 caracteres'),
      MapEntry(RegExp(r'[A-Z]').hasMatch(password), 'Al menos una mayúscula'),
      MapEntry(RegExp(r'[a-z]').hasMatch(password), 'Al menos una minúscula'),
      MapEntry(RegExp(r'[0-9]').hasMatch(password), 'Al menos un número'),
      MapEntry(RegExp(r'[*\-_#~$]').hasMatch(password), 'Un carácter especial'),
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rules
            .map((rule) => _RuleRow(met: rule.key, label: rule.value))
            .toList(),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.met, required this.label});

  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(
        met ? Icons.check_circle : Icons.circle_outlined,
        size: 14,
        color: met ? const Color(0xFF22A05C) : const Color(0xFF999AAB),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: met ? const Color(0xFF22A05C) : const Color(0xFF999AAB),
        ),
      ),
    ],
  );
}

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 54),
    content: Text(
      '$message\n\nYa puedes iniciar sesión con tu nueva contraseña.',
      textAlign: TextAlign.center,
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Entendido'),
      ),
    ],
  );
}

String friendlyErrorMessage(String message) {
  final lower = message.toLowerCase();
  if (lower.contains('invalid login') ||
      lower.contains('username and password not accepted') ||
      lower.contains('badcredentials') ||
      lower.contains('smtp')) {
    return 'No se pudo enviar el correo de recuperación. Por favor revisa la configuración del servidor o contacta soporte.';
  }
  return message;
}
