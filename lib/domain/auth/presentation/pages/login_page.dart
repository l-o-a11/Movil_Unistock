import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movil_unistock/domain/auth/presentation/access_controller.dart';
import 'package:movil_unistock/domain/auth/presentation/forgot_password_flow.dart';
import 'package:movil_unistock/domain/auth/presentation/widgets/login_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // FocusNodes: permiten controlar a qué campo salta el foco cuando el
  // usuario presiona "Siguiente" / "Listo" en el teclado.
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _accessController = AccessController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;
  // No basta con mirar MediaQuery.viewInsets: con el teclado flotante de
  // iPad el sistema no reporta el inset, así que el panel nunca subiría.
  // Por eso también nos fijamos si algún campo tiene el foco.
  bool _isAnyFieldFocused = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _emailFocusNode.addListener(_onFocusChanged);
    _passwordFocusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    final anyFocused = _emailFocusNode.hasFocus || _passwordFocusNode.hasFocus;
    if (anyFocused != _isAnyFieldFocused) {
      setState(() => _isAnyFieldFocused = anyFocused);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _passwordFocusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final success = await _accessController.login(
      username: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() {
      _isLoading = _accessController.isLoading;
      _error = _accessController.error;
    });
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    // Se considera "visible" tanto si el teclado anclado empuja la vista
    // (keyboardInset > 0) como si algún campo tiene foco aunque el teclado
    // sea flotante y no reporte inset.
    final isKeyboardVisible = keyboardInset > 0 || _isAnyFieldFocused;
    // En tablet/escritorio/web el panel de login ya no se estira de borde
    // a borde: se limita a un ancho fijo y se centra horizontalmente. En
    // celular (size.width <= _panelMaxWidth) se comporta como antes.
    const panelMaxWidth = 440.0;
    final panelSideInset = size.width > panelMaxWidth
        ? (size.width - panelMaxWidth) / 2
        : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            // ── Imagen de fondo ────────────────────────────────────
            Positioned.fill(
              child: Transform.translate(
                offset: const Offset(0, 0),
                child: Image.asset(
                  'assets/hero.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),

            // ── Formulario anclado abajo ───────────────────────────
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              bottom: keyboardInset,
              left: panelSideInset,
              right: panelSideInset,
              top: isKeyboardVisible ? 80 : size.height * 0.55,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: size.height - (isKeyboardVisible ? 100 : 60),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: panelSideInset > 0
                        ? BorderRadius.circular(32)
                        : const BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 30,
                        offset: Offset(0, -8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Bienvenido',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1C1C1C),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Accede a tu panel de administración.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email field
                        LoginTextField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          hintText: 'Nombre del usuario o correo electrónico',
                          prefixIcon: Icons.person_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          // Al presionar "Siguiente" en el teclado, salta al
                          // campo de contraseña.
                          onSubmitted: (_) => FocusScope.of(
                            context,
                          ).requestFocus(_passwordFocusNode),
                        ),
                        const SizedBox(height: 12),

                        // Password field
                        LoginTextField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          hintText: 'Contraseña',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          // Al presionar "Listo" en este campo, se envía el
                          // formulario directamente.
                          onSubmitted: (_) =>
                              _isLoading ? null : _handleLogin(),
                          suffixIcon: GestureDetector(
                            onTap: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFFBBBBBB),
                              size: 21,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Login button
                        LoginGradientButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          label: _isLoading ? 'Cargando...' : 'Iniciar sesión',
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),

                        // Forgot password
                        Center(
                          child: TextButton(
                            onPressed: () {
                              showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                barrierColor: Colors.black.withOpacity(0.22),
                                builder: (sheetContext) {
                                  // ForgotPasswordFlow (asBottomSheet: true) ya
                                  // compensa el teclado internamente — no
                                  // agregamos Padding acá para no duplicar el
                                  // inset y comprimir el panel.
                                  return SafeArea(
                                    child: FractionallySizedBox(
                                      heightFactor: 0.92,
                                      child: const ForgotPasswordFlow(
                                        asBottomSheet: true,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFF4FA3),
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
        ),
      ),
    );
  }
}
