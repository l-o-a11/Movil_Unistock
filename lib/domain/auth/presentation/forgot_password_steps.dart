import 'package:flutter/material.dart';

import 'auth_presentation_widgets.dart';

const _pink = Color(0xFFFF4FA3);
const _pinkLight = Color(0xFFFF79BB);
const _textDark = Color(0xFF1C1C1C);
const _muted = Color(0xFFAAAAAA);
const _fieldBg = Color(0xFFF5F5F5);

class StepDots extends StatelessWidget {
  const StepDots({super.key, required this.activeStep});

  final int activeStep;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(3, (index) {
      final active = index == activeStep;
      final done = index < activeStep;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: active ? 28 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: active
              ? _pink
              : done
              ? const Color(0xFFF7B5DA)
              : const Color(0xFFE7E7EF),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }),
  );
}

class EmailStep extends StatefulWidget {
  const EmailStep({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
  });

  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<String> onSubmit;

  @override
  State<EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends State<EmailStep> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StepShell(
    icon: Icons.mail_outline_rounded,
    title: 'Recuperar contraseña',
    subtitle:
        'Ingresa tu correo y te enviaremos un código para restablecer tu contraseña.',
    children: [
      AuthTextField(
        controller: _controller,
        hintText: 'Correo electrónico',
        prefixIcon: Icons.mail_outline_rounded,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        onSubmitted: (value) => widget.onSubmit(value.trim()),
      ),
      if (widget.errorMessage != null) ErrorText(widget.errorMessage!),
      GradientButton(
        label: widget.isLoading ? 'Enviando...' : 'Enviar código',
        isLoading: widget.isLoading,
        onPressed: widget.isLoading
            ? null
            : () => widget.onSubmit(_controller.text.trim()),
      ),
    ],
  );
}

class CodeStep extends StatefulWidget {
  const CodeStep({
    super.key,
    required this.correo,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
    required this.onResend,
  });

  final String correo;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<String> onSubmit;
  final VoidCallback onResend;

  @override
  State<CodeStep> createState() => _CodeStepState();
}

class _CodeStepState extends State<CodeStep> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  String get _code => _controllers.map((controller) => controller.text).join();

  @override
  void dispose() {
    for (final controller in _controllers) controller.dispose();
    for (final node in _focusNodes) node.dispose();
    super.dispose();
  }

  void _changed(int index, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 1) {
      for (var i = 0; i < 6 && i < digits.length; i++)
        _controllers[i].text = digits[i];
      _focusNodes.last.unfocus();
    } else if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
    if (_code.length == 6) widget.onSubmit(_code);
  }

  @override
  Widget build(BuildContext context) => StepShell(
    icon: Icons.mark_email_read_outlined,
    title: 'Verifica tu código',
    subtitle: 'Hemos enviado un código de 6 dígitos a\n${widget.correo}',
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (index) {
          final filled = _controllers[index].text.isNotEmpty;
          return SizedBox(
            width: 44,
            height: 52,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              onChanged: (value) => _changed(index, value),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: filled
                    ? const Color(0xFFFEEDF7)
                    : const Color(0xFFF5F5F8),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: filled ? _pink : Colors.transparent,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
      if (widget.errorMessage != null) ErrorText(widget.errorMessage!),
      GradientButton(
        label: widget.isLoading ? 'Validando...' : 'Verificar código',
        isLoading: widget.isLoading,
        onPressed: widget.isLoading || _code.length != 6
            ? null
            : () => widget.onSubmit(_code),
      ),
      TextButton(
        onPressed: widget.isLoading ? null : widget.onResend,
        child: const Text('¿No recibiste el código? Reenviar'),
      ),
    ],
  );
}

class NewPasswordStep extends StatefulWidget {
  const NewPasswordStep({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
  });

  final bool isLoading;
  final String? errorMessage;
  final void Function(String password, String confirm) onSubmit;

  @override
  State<NewPasswordStep> createState() => _NewPasswordStepState();
}

class _NewPasswordStepState extends State<NewPasswordStep> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  bool get _valid =>
      _password.text.length >= 8 &&
      RegExp(r'[A-Z]').hasMatch(_password.text) &&
      RegExp(r'[a-z]').hasMatch(_password.text) &&
      RegExp(r'[0-9]').hasMatch(_password.text) &&
      RegExp(r'[*\-_#~$]').hasMatch(_password.text);
  bool get _matches =>
      _confirm.text.isNotEmpty && _password.text == _confirm.text;

  @override
  void initState() {
    super.initState();
    _password.addListener(_refresh);
    _confirm.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _valid && _matches && !widget.isLoading;
    return StepShell(
      icon: Icons.lock_reset_rounded,
      title: 'Cambiar contraseña',
      children: [
        AuthTextField(
          controller: _password,
          hintText: 'Nueva contraseña',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: VisibilityToggle(
            obscure: _obscurePassword,
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        PasswordRules(password: _password.text),
        AuthTextField(
          controller: _confirm,
          hintText: 'Confirma tu nueva contraseña',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscureConfirm,
          suffixIcon: VisibilityToggle(
            obscure: _obscureConfirm,
            onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ),
        if (_confirm.text.isNotEmpty)
          ErrorText(
            _matches
                ? 'Las contraseñas coinciden'
                : 'Las contraseñas no coinciden',
            color: _matches ? const Color(0xFF22A05C) : const Color(0xFFE53935),
          ),
        if (widget.errorMessage != null) ErrorText(widget.errorMessage!),
        GradientButton(
          label: widget.isLoading ? 'Guardando...' : 'Cambiar contraseña',
          isLoading: widget.isLoading,
          onPressed: canSubmit
              ? () => widget.onSubmit(_password.text, _confirm.text)
              : null,
        ),
      ],
    );
  }
}
