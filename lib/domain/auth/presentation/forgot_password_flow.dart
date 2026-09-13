import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../data/auth_service.dart';
import 'auth_presentation_widgets.dart';
import 'forgot_password_steps.dart';

class ForgotPasswordFlow extends StatefulWidget {
  const ForgotPasswordFlow({super.key, this.asBottomSheet = false});

  final bool asBottomSheet;

  @override
  State<ForgotPasswordFlow> createState() => _ForgotPasswordFlowState();
}

class _ForgotPasswordFlowState extends State<ForgotPasswordFlow> {
  final _authService = AuthService();
  int _step = 0;
  String _correo = '';
  String _resetToken = '';
  bool _isLoading = false;
  String? _errorMessage;

  void _goTo(int step) => setState(() {
    _step = step;
    _errorMessage = null;
  });

  Future<void> _handleSendCode(String correo) async {
    if (correo.isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu correo electrónico');
      return;
    }
    await _run(() async {
      await _authService.forgotPassword(correo);
      _correo = correo;
      _goTo(1);
    });
  }

  Future<void> _handleVerifyCode(String codigo) async {
    if (codigo.length != 6) {
      setState(() => _errorMessage = 'El código debe tener 6 dígitos');
      return;
    }
    await _run(() async {
      _resetToken = await _authService.verifyCode(_correo, codigo);
      _goTo(2);
    });
  }

  Future<void> _handleResendCode() async {
    await _run(() async {
      await _authService.forgotPassword(_correo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Te enviamos un nuevo código')),
        );
      }
    });
  }

  Future<void> _handleResetPassword(String password, String confirm) async {
    if (password.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = 'Completa ambos campos');
      return;
    }
    await _run(() async {
      final message = await _authService.resetPassword(
        resetToken: _resetToken,
        password: password,
        confirmarPassword: confirm,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => SuccessDialog(message: message),
      );
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await action();
    } on ApiException catch (exception) {
      if (mounted)
        setState(() => _errorMessage = friendlyErrorMessage(exception.message));
    } catch (_) {
      if (mounted)
        setState(() => _errorMessage = 'No se pudo conectar con el servidor');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    final content = SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + inset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 360,
          maxHeight: MediaQuery.of(context).size.height - inset - 48,
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2E000000),
                blurRadius: 36,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 18),
              StepDots(activeStep: _step),
              const SizedBox(height: 4),
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: switch (_step) {
                      0 => EmailStep(
                        isLoading: _isLoading,
                        errorMessage: _errorMessage,
                        onSubmit: _handleSendCode,
                      ),
                      1 => CodeStep(
                        correo: _correo,
                        isLoading: _isLoading,
                        errorMessage: _errorMessage,
                        onSubmit: _handleVerifyCode,
                        onResend: _handleResendCode,
                      ),
                      _ => NewPasswordStep(
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

    if (widget.asBottomSheet) return SafeArea(child: Center(child: content));
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(color: const Color(0x38000000)),
            ),
          ),
          SafeArea(child: Center(child: content)),
        ],
      ),
    );
  }
}
