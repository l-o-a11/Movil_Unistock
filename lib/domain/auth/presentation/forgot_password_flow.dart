// lib/domain/auth/presentation/forgot_password_flow.dart
//
// Flujo de "Olvidé mi contraseña" en 3 pasos, cada uno contra un endpoint
// real del backend:
//   1) POST /auth/forgot-password  → envía un código de 6 dígitos al correo
//   2) POST /auth/verify-code      → valida el código, devuelve resetToken
//   3) POST /auth/reset-password   → establece la nueva contraseña
//
// Se modela como un solo Scaffold con un PageView de 3 páginas para que la
// transición se sienta como un único flujo (igual estética que LoginPage:
// fondo blanco, campos rosa/gris redondeados, botón con gradiente).

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/api_client.dart';
import '../data/auth_service.dart';

const _pink = Color(0xFFFF4FA3);
const _pinkLight = Color(0xFFFF79BB);
const _textDark = Color(0xFF1C1C1C);
const _muted = Color(0xFFAAAAAA);
const _fieldBg = Color(0xFFF5F5F5);

class ForgotPasswordFlow extends StatefulWidget {
  /// If [asBottomSheet] is true, the widget renders only the inner
  /// content so it can be used inside a `showModalBottomSheet` without
  /// drawing its own backdrop or Scaffold. Default: false (dialog mode).
  const ForgotPasswordFlow({super.key, this.asBottomSheet = false});

  final bool asBottomSheet;

  @override
  State<ForgotPasswordFlow> createState() => _ForgotPasswordFlowState();
}

class _ForgotPasswordFlowState extends State<ForgotPasswordFlow> {
  final _authService = AuthService();

  int _step = 0; // 0: correo, 1: código, 2: nueva contraseña

  // Datos que se acumulan a través de los pasos
  String _correo = '';
  String _resetToken = '';

  bool _isLoading = false;
  String? _errorMessage;

  void _goTo(int step) {
    setState(() {
      _step = step;
      _errorMessage = null;
    });
  }

  // ── Paso 1: pedir el código ────────────────────────────────────────────
  Future<void> _handleSendCode(String correo) async {
    if (correo.isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu correo electrónico');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _authService.forgotPassword(correo);
      _correo = correo;
      if (!mounted) return;
      _goTo(1);
    } on ApiException catch (e) {
      setState(() => _errorMessage = _friendlyErrorMessage(e.message));
    } catch (_) {
      setState(() => _errorMessage = 'No se pudo conectar con el servidor');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Paso 2: validar el código ──────────────────────────────────────────
  Future<void> _handleVerifyCode(String codigo) async {
    if (codigo.length != 6) {
      setState(() => _errorMessage = 'El código debe tener 6 dígitos');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final token = await _authService.verifyCode(_correo, codigo);
      _resetToken = token;
      if (!mounted) return;
      _goTo(2);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = 'No se pudo conectar con el servidor');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Reenviar código desde el paso 2 ────────────────────────────────────
  Future<void> _handleResendCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _authService.forgotPassword(_correo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te enviamos un nuevo código')),
      );
    } on ApiException catch (e) {
      setState(() => _errorMessage = _friendlyErrorMessage(e.message));
    } catch (_) {
      setState(() => _errorMessage = 'No se pudo conectar con el servidor');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Paso 3: establecer la nueva contraseña ─────────────────────────────
  Future<void> _handleResetPassword(String password, String confirmar) async {
    if (password.isEmpty || confirmar.isEmpty) {
      setState(() => _errorMessage = 'Completa ambos campos');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final message = await _authService.resetPassword(
        resetToken: _resetToken,
        password: password,
        confirmarPassword: confirmar,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _SuccessDialog(message: message),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      setState(() => _errorMessage = _friendlyErrorMessage(e.message));
    } catch (_) {
      setState(() => _errorMessage = 'No se pudo conectar con el servidor');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    Widget content() => SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + viewInsets),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 360,
          maxHeight:
              MediaQuery.of(context).size.height -
              viewInsets -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom -
              48,
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.18),
                blurRadius: 36,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 18),
              _StepDots(activeStep: _step),
              const SizedBox(height: 4),
              // FIX: antes el AnimatedSwitcher era hijo directo de este
              // Column con mainAxisSize.min. Un Column así le da a sus
              // hijos altura NO acotada (crece a su tamaño natural), así
              // que el SingleChildScrollView de cada paso (_NewPasswordStep,
              // etc.) nunca tenía un límite real dentro del cual
              // desplazarse — cuando el contenido + teclado no cabían,
              // se desbordaba en vez de scrollear ("BOTTOM OVERFLOWED").
              // Flexible sí le da un límite de altura genuino (el espacio
              // restante dentro del maxHeight del ConstrainedBox de
              // afuera), habilitando el scroll interno quando hace falta,
              // y dejando que el modal se achique cuando el paso es corto
              // (p. ej. el primer paso, solo el campo de correo).
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: switch (_step) {
                      0 => _EmailStep(
                        isLoading: _isLoading,
                        errorMessage: _errorMessage,
                        onSubmit: _handleSendCode,
                      ),
                      1 => _CodeStep(
                        correo: _correo,
                        isLoading: _isLoading,
                        errorMessage: _errorMessage,
                        onSubmit: _handleVerifyCode,
                        onResend: _handleResendCode,
                      ),
                      _ => _NewPasswordStep(
                        isLoading: _isLoading,
                        errorMessage: _errorMessage,
                        onSubmit: _handleResetPassword,
                      ),
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.asBottomSheet) {
      // El inset del teclado ya se compensa una sola vez dentro de
      // content() (padding del SingleChildScrollView + maxHeight del
      // ConstrainedBox). No lo volvemos a restar acá para no duplicarlo.
      return SafeArea(child: content());
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(color: const Color.fromRGBO(0, 0, 0, 0.22)),
              ),
            ),
          ),
          SafeArea(child: Center(child: content())),
        ],
      ),
    );
  }
}

// ── Indicador de pasos ───────────────────────────────────────────────────
class _StepDots extends StatelessWidget {
  final int activeStep;
  const _StepDots({required this.activeStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isActive = i == activeStep;
        final isDone = i < activeStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? _pink
                : (isDone ? const Color(0xFFF7B5DA) : const Color(0xFFE7E7EF)),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ── Paso 1: correo ────────────────────────────────────────────────────────
class _EmailStep extends StatefulWidget {
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<String> onSubmit;
  const _EmailStep({
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
  });

  @override
  State<_EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends State<_EmailStep> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F3FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: _textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE8F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.mail_outline_rounded,
                color: _pink,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Recuperar contraseña',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ingresa tu correo y te enviaremos un código para restablecer tu contraseña.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: _muted, height: 1.4),
          ),
          const SizedBox(height: 20),
          _AuthTextField(
            controller: _controller,
            hintText: 'Correo electrónico',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (v) => widget.onSubmit(v.trim()),
          ),
          if (widget.errorMessage != null) ...[
            const SizedBox(height: 10),
            _ErrorText(widget.errorMessage!),
          ],
          const SizedBox(height: 18),
          _GradientButton(
            label: widget.isLoading ? 'Enviando...' : 'Enviar código',
            isLoading: widget.isLoading,
            onPressed: widget.isLoading
                ? null
                : () => widget.onSubmit(_controller.text.trim()),
          ),
        ],
      ),
    );
  }
}

// ── Paso 2: código (6 casillas individuales con auto-avance) ─────────────
class _CodeStep extends StatefulWidget {
  final String correo;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<String> onSubmit;
  final VoidCallback onResend;
  const _CodeStep({
    required this.correo,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
    required this.onResend,
  });

  @override
  State<_CodeStep> createState() => _CodeStepState();
}

class _CodeStepState extends State<_CodeStep> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    // Pegar código completo de una sola vez
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 1) {
      for (int i = 0; i < 6 && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      setState(() {});
      _focusNodes[5].unfocus();
      if (_code.length == 6) widget.onSubmit(_code);
      return;
    }
    setState(() {});
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isNotEmpty && index == 5) {
      _focusNodes[5].unfocus();
      if (_code.length == 6) widget.onSubmit(_code);
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey.keyLabel == 'Backspace' &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCode = _code.length == 6;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F3FB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: _textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE8F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                color: _pink,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Verifica tu código',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hemos enviado un código de 6 dígitos a\n${widget.correo}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color.fromARGB(255, 0, 0, 0),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          // 6 casillas individuales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) {
              final isFilled = _controllers[i].text.isNotEmpty;
              return SizedBox(
                width: 44,
                height: 52,
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (e) => _onKeyEvent(i, e),
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    onChanged: (v) => _onDigitChanged(i, v),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isFilled ? _pink : _textDark,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: isFilled
                          ? const Color(0xFFFEEDF7)
                          : const Color(0xFFF5F5F8),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isFilled ? _pink : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isFilled
                              ? const Color.fromRGBO(255, 79, 163, 0.4)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _pink, width: 2),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          if (widget.errorMessage != null) ...[
            const SizedBox(height: 12),
            _ErrorText(widget.errorMessage!),
          ],
          const SizedBox(height: 20),
          _GradientButton(
            label: widget.isLoading ? 'Validando...' : 'Verificar código',
            isLoading: widget.isLoading,
            onPressed: widget.isLoading || !hasCode
                ? null
                : () => widget.onSubmit(_code),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: widget.isLoading ? null : widget.onResend,
              child: const Text(
                '¿No recibiste el código? Reenviar',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _pink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Paso 3: nueva contraseña con validaciones en tiempo real ──────────────
class _NewPasswordStep extends StatefulWidget {
  final bool isLoading;
  final String? errorMessage;
  final void Function(String password, String confirmar) onSubmit;
  const _NewPasswordStep({
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
  });

  @override
  State<_NewPasswordStep> createState() => _NewPasswordStepState();
}

class _NewPasswordStepState extends State<_NewPasswordStep> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  // Reglas de validación — mismas del backend (validationMiddleware.js)
  bool get _hasLength => _passwordController.text.length >= 8;
  bool get _hasUpper => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasLower => _passwordController.text.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial =>
      _passwordController.text.contains(RegExp(r'[*\-_#~$]'));
  bool get _passwordsMatch =>
      _confirmController.text.isNotEmpty &&
      _passwordController.text == _confirmController.text;
  bool get _allValid =>
      _hasLength && _hasUpper && _hasLower && _hasNumber && _hasSpecial;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
    _confirmController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _allValid && _passwordsMatch && !widget.isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Botón cerrar
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F3FB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: _textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Ícono
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE8F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: _pink,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Cambiar contraseña',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 20),
          // Campo nueva contraseña
          _AuthTextField(
            controller: _passwordController,
            hintText: 'Nueva contraseña',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscure1,
            textInputAction: TextInputAction.next,
            suffixIcon: _VisibilityToggle(
              obscure: _obscure1,
              onTap: () => setState(() => _obscure1 = !_obscure1),
            ),
          ),
          const SizedBox(height: 12),
          // Reglas en tiempo real
          _PasswordRules(
            hasLength: _hasLength,
            hasUpper: _hasUpper,
            hasLower: _hasLower,
            hasNumber: _hasNumber,
            hasSpecial: _hasSpecial,
            showRules: _passwordController.text.isNotEmpty,
          ),
          const SizedBox(height: 12),
          // Campo confirmar contraseña
          _AuthTextField(
            controller: _confirmController,
            hintText: 'Confirma tu nueva contraseña',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscure2,
            textInputAction: TextInputAction.done,
            suffixIcon: _VisibilityToggle(
              obscure: _obscure2,
              onTap: () => setState(() => _obscure2 = !_obscure2),
            ),
            onSubmitted: (_) {
              if (canSubmit) {
                widget.onSubmit(
                  _passwordController.text,
                  _confirmController.text,
                );
              }
            },
          ),
          // Indicador de coincidencia
          if (_confirmController.text.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  _passwordsMatch
                      ? Icons.check_circle_outline_rounded
                      : Icons.cancel_outlined,
                  size: 14,
                  color: _passwordsMatch
                      ? const Color(0xFF22A05C)
                      : const Color(0xFFE53935),
                ),
                const SizedBox(width: 6),
                Text(
                  _passwordsMatch
                      ? 'Las contraseñas coinciden'
                      : 'Las contraseñas no coinciden',
                  style: TextStyle(
                    fontSize: 12,
                    color: _passwordsMatch
                        ? const Color(0xFF22A05C)
                        : const Color(0xFFE53935),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          if (widget.errorMessage != null) ...[
            const SizedBox(height: 10),
            _ErrorText(widget.errorMessage!),
          ],
          const SizedBox(height: 20),
          _GradientButton(
            label: widget.isLoading ? 'Guardando...' : 'Cambiar contraseña',
            isLoading: widget.isLoading,
            onPressed: canSubmit
                ? () => widget.onSubmit(
                    _passwordController.text,
                    _confirmController.text,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

// ── Widget de reglas de contraseña ────────────────────────────────────────
class _PasswordRules extends StatelessWidget {
  final bool hasLength;
  final bool hasUpper;
  final bool hasLower;
  final bool hasNumber;
  final bool hasSpecial;
  final bool showRules;

  const _PasswordRules({
    required this.hasLength,
    required this.hasUpper,
    required this.hasLower,
    required this.hasNumber,
    required this.hasSpecial,
    required this.showRules,
  });

  @override
  Widget build(BuildContext context) {
    if (!showRules) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: showRules ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEF5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'La contraseña debe tener:',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF888899),
              ),
            ),
            const SizedBox(height: 6),
            _RuleRow(met: hasLength, label: 'Mínimo 8 caracteres'),
            _RuleRow(met: hasUpper, label: 'Al menos una mayúscula (A-Z)'),
            _RuleRow(met: hasLower, label: 'Al menos una minúscula (a-z)'),
            _RuleRow(met: hasNumber, label: 'Al menos un número (0-9)'),
            _RuleRow(
              met: hasSpecial,
              label: 'Un carácter especial (* - _ # ~ \$)',
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final bool met;
  final String label;
  const _RuleRow({required this.met, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: met ? const Color(0xFF22A05C) : const Color(0xFFE0E0E8),
            ),
            child: met
                ? const Icon(Icons.check_rounded, size: 10, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: met ? const Color(0xFF22A05C) : const Color(0xFF999AAB),
              fontWeight: met ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Diálogo de éxito ──────────────────────────────────────────────────────
String _friendlyErrorMessage(String message) {
  final lower = message.toLowerCase();
  if (lower.contains('invalid login') ||
      lower.contains('username and password not accepted') ||
      lower.contains('badcredentials') ||
      lower.contains('smtp')) {
    return 'No se pudo enviar el correo de recuperación. Por favor revisa la configuración del servidor o contacta soporte.';
  }
  return message;
}

class _SuccessDialog extends StatelessWidget {
  final String message;
  const _SuccessDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF4ADE80),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: _textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ya puedes iniciar sesión con tu nueva contraseña.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _muted),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Entendido',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets compartidos de estilo (mismo look que LoginPage) ─────────────

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.onSubmitted,
    this.onChanged,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.letterSpacing,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final int? maxLength;
  final TextAlign textAlign;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      maxLength: maxLength,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 14,
        color: _textDark,
        letterSpacing: letterSpacing,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9999AB), fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(prefixIcon, color: const Color(0xFFACAFC5), size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 14),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
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
        size: 21,
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String message;
  const _ErrorText(this.message);

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFFE53935),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _GradientButton extends StatefulWidget {
  const _GradientButton({
    required this.onPressed,
    required this.label,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: widget.onPressed == null
          ? null
          : () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 52,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: widget.onPressed == null
                  ? [const Color(0xFFFFB8D9), const Color(0xFFFFCCE3)]
                  : [_pink, _pinkLight],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(255, 79, 163, 0.38),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                )
              : Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}
