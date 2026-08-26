import 'package:flutter/material.dart';

/// Breakpoints en dp usados para adaptar layouts de una sola columna
/// (pensados originalmente para celular) a tablet/escritorio/web.
class AppBreakpoints {
  static const double tablet = 700;
  static const double desktop = 1100;

  static bool isMobile(double width) => width < tablet;
  static bool isTablet(double width) => width >= tablet && width < desktop;
  static bool isDesktop(double width) => width >= desktop;
}

/// Centra el contenido y limita su ancho máximo cuando la pantalla es más
/// ancha que un celular (tablet, escritorio, web). En celular ocupa todo el
/// ancho disponible como antes, así que no cambia nada en ese caso.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({super.key, required this.child, this.maxWidth = 720});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Calcula cuántas columnas debe tener una grilla de tarjetas según el
/// ancho disponible: 1 en celular, 2 en tablet, 3 en escritorio/web.
int responsiveColumns(
  double width, {
  int mobile = 1,
  int tablet = 2,
  int desktop = 3,
}) {
  if (AppBreakpoints.isDesktop(width)) return desktop;
  if (AppBreakpoints.isTablet(width)) return tablet;
  return mobile;
}

/// Envuelve un listado de tarjetas de ancho completo (pensado para celular)
/// y lo convierte en una grilla de 2-3 columnas en pantallas anchas,
/// conservando la lista vertical original en celular.
class ResponsiveCardGrid extends StatelessWidget {
  const ResponsiveCardGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.spacing = 12,
    this.childAspectRatio = 2.6,
    this.padding = EdgeInsets.zero,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final double spacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = responsiveColumns(constraints.maxWidth);
        if (columns == 1) {
          return ListView.separated(
            padding: padding,
            itemCount: itemCount,
            separatorBuilder: (_, __) => SizedBox(height: spacing),
            itemBuilder: itemBuilder,
          );
        }
        return GridView.builder(
          padding: padding,
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}

/// Limita el ancho de los modales/hojas tipo "bottom sheet" en pantallas
/// anchas para que no se estiren de borde a borde; en celular no cambia
/// nada porque el ancho de la pantalla ya es menor al máximo.
class ResponsiveSheet extends StatelessWidget {
  const ResponsiveSheet({super.key, required this.child, this.maxWidth = 480});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
