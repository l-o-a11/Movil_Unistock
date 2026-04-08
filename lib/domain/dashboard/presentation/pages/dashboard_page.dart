import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/global_bottom_nav.dart';
import '../../data/dashboard_data_source.dart';
import '../../domain/dashboard_metric_entity.dart';
import '../../domain/dashboard_chart_point_entity.dart';
import '../providers/dashboard_provider.dart';

// ─── Design tokens ────────────────────────────────────────────────
const _pink = Color(0xFFFF4FA3);
const _pinkLight = Color(0xFFFFF0F7);
const _green = Color(0xFF1ECB6F);
const _greenLight = Color(0xFFEBFBF3);
const _purple = Color(0xFF7C4DFF);
const _purpleLight = Color(0xFFF2EEFF);
const _amber = Color(0xFFFFAB00);
const _amberLight = Color(0xFFFFF8E7);
const _bg = Color(0xFFF4F5FA);
const _card = Colors.white;
const _ink = Color(0xFF1A1A2E);
const _muted = Color(0xFFAAABB8);
const _gridLine = Color(0xFFEEEFF5);

// ═════════════════════════════════════════════════════════════════════════════
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => DashboardProvider(dataSource: DashboardDataSource()),
    child: const _DashboardView(),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: const GlobalBottomNav(activeIndex: 0),
      body: SafeArea(
        child: Consumer<DashboardProvider>(
          builder: (_, prov, __) => Column(
            children: [
              // ── Header ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _HeaderIcon(
                      icon: Icons.show_chart_rounded,
                      color: _pink,
                      bg: _pinkLight,
                    ),
                    _HeaderIcon(
                      icon: Icons.person_outline_rounded,
                      color: _pink,
                      bg: _pinkLight,
                    ),
                  ],
                ),
              ),

              // ── Scroll area ─────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ActionTilesCard(),
                      const SizedBox(height: 24),
                      _ChartCard(provider: prov),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // ── Botón Acceder ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pink,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/menu'),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Acceder',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header icon ──────────────────────────────────────────────────
class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  const _HeaderIcon({
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 46,
    height: 46,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Icon(icon, color: color, size: 22),
  );
}

// ─── Quick-action tiles ───────────────────────────────────────────
class _ActionTilesCard extends StatelessWidget {
  const _ActionTilesCard();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(28),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 24,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: const _QuickActions(),
  );
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  static const _tiles = [
    (Icons.trending_up_rounded, 'Producción', _purple, _purpleLight),
    (Icons.insights_rounded, 'Resumen', _pink, _pinkLight),
    (Icons.inventory_2_outlined, 'Insumos', _green, _greenLight),
    (Icons.article_outlined, 'Reportes', _amber, _amberLight),
  ];

  @override
  Widget build(BuildContext context) => Row(
    children: _tiles
        .map(
          (t) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _ActionTile(
                icon: t.$1,
                label: t.$2,
                color: t.$3,
                bg: t.$4,
              ),
            ),
          ),
        )
        .toList(),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 20,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _ink,
            height: 1.1,
          ),
        ),
      ],
    ),
  );
}

// ─── Metrics row ──────────────────────────────────────────────────

// ─── Chart card ───────────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final DashboardProvider provider;
  const _ChartCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator(color: _pink)),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 30,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado general de los procesos de producción',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _ink,
              height: 1.3,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 22),
          _BarChart(points: provider.chartPoints),
        ],
      ),
    );
  }
}

// ─── Bar chart ────────────────────────────────────────────────────
class _BarChart extends StatefulWidget {
  final List<DashboardChartPointEntity> points;
  const _BarChart({required this.points});

  @override
  State<_BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<_BarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) return const SizedBox.shrink();

    final maxRaw = widget.points
        .map((p) => p.value)
        .reduce(math.max)
        .toDouble();

    // Techo del eje Y: múltiplo de 12 por encima del máximo
    const int yDivisions = 4;
    final double step = ((maxRaw / yDivisions) / 12.0).ceilToDouble() * 12.0;
    final double yMax = step * yDivisions;

    const double chartH = 170.0;
    const double labelH = 64.0;
    const double yAxisW = 28.0;

    return SizedBox(
      height: chartH + labelH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Eje Y ──
          SizedBox(
            width: yAxisW,
            height: chartH,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(yDivisions + 1, (i) {
                final val = (yMax - i * step).toInt();
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    '$val',
                    style: const TextStyle(
                      fontSize: 9,
                      color: _muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }),
            ),
          ),

          // ── Área de barras ──
          Expanded(
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => CustomPaint(
                painter: _GridLinesPainter(steps: yDivisions, chartH: chartH),
                child: SizedBox(
                  height: chartH + labelH,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
children: widget.points.asMap().entries.map((entry) {
                        final index = entry.key;
                        final p = entry.value;
                        final ratio = yMax > 0 ? p.value / yMax : 0.0;
                        final barH = math.max(ratio * chartH * _anim.value, 3.0);
                        final barColor = index == 0 ? _pink : _green;

                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Barra
                            SizedBox(
                              height: chartH,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: 12,
                                  height: barH,
                                  decoration: BoxDecoration(
                                    color: barColor,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: labelH - 8,
                              child: Text(
                                p.label,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: _muted,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pintor de líneas de guía ─────────────────────────────────────
class _GridLinesPainter extends CustomPainter {
  final int steps;
  final double chartH;
  const _GridLinesPainter({required this.steps, required this.chartH});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _gridLine
      ..strokeWidth = 0.8;
    for (int i = 0; i <= steps; i++) {
      final y = (i / steps) * chartH;
      const double dashWidth = 6.0;
      const double dashSpace = 4.0;
      var startX = 0.0;
      while (startX < size.width) {
        final endX = (startX + dashWidth).clamp(0.0, size.width);
        canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
        startX += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridLinesPainter old) =>
      old.steps != steps || old.chartH != chartH;
}

// ─── Legend dot ───────────────────────────────────────────────────
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: _muted,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}