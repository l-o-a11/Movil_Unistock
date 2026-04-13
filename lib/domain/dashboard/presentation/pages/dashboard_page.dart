import 'package:flutter/material.dart';
import '../../../../shared/widgets/global_bottom_nav.dart';
import '../../theme/app_theme.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/process_item.dart';
import '../../widgets/progress_section.dart';
import '../../widgets/summary_card.dart';

// ═══════════════════════════════════════════════════════════════════
/// Página principal del dashboard administrativo.
// ═══════════════════════════════════════════════════════════════════
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const _cards = [
    _CardData(
      icon: Icons.bolt_rounded,
      iconColor: AppTheme.purple,
      iconBg: AppTheme.purpleLight,
      title: 'ACTUALES',
      value: '10',
      subtitle: 'prod.',
    ),
    _CardData(
      icon: Icons.check_rounded,
      iconColor: AppTheme.green,
      iconBg: AppTheme.greenLight,
      title: 'COMPLETADAS',
      value: '08',
      subtitle: 'este mes',
    ),
    _CardData(
      icon: Icons.schedule_rounded,
      iconColor: AppTheme.pink,
      iconBg: AppTheme.pinkLight,
      title: 'POR INICIAR',
      value: '02',
      subtitle: 'pendientes',
    ),
    _CardData(
      icon: Icons.access_time_rounded,
      iconColor: AppTheme.purple,
      iconBg: AppTheme.purpleLight,
      title: 'PROMEDIO',
      value: '4',
      subtitle: 'días',
    ),
  ];

  static const _processes = [
    _ProcessData('En espera',           50, AppTheme.purple),
    _ProcessData('Tráfico entre sedes', 25, AppTheme.green),
    _ProcessData('Ficha técnica',       15, AppTheme.purple),
    _ProcessData('Corte',                5, AppTheme.green),
    _ProcessData('Diseño',              13, AppTheme.purple),
    _ProcessData('En producción',       10, AppTheme.green),
    _ProcessData('Bodega',              20, AppTheme.purple),
    _ProcessData('Mercadeo',             8, AppTheme.green),
    _ProcessData('Cancelado',            3, AppTheme.purple),
    _ProcessData('Compras',             10, AppTheme.green),
    _ProcessData('Recepción',            2, AppTheme.purple),
  ];

  static const int _processMax = 50;

  @override
  Widget build(BuildContext context) {
    final hPad = AppTheme.sp(context, 16);
    final s    = AppTheme.scale(context);

    // Pixel 4 width ≈ 360 dp → childAspectRatio needs to be a bit taller
    // S20 Ultra  width ≈ 412 dp → original 1.15 looks great
    // We interpolate: smaller screen → smaller ratio (taller card).
    final cardRatio = 0.95 + 0.20 * (s - 0.78) / 0.22; // 0.95 … 1.15

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      bottomNavigationBar: const GlobalBottomNav(activeIndex: 0),
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('Resumen operativo'),
                    SizedBox(height: AppTheme.sp(context, 10)),

                    // ── 2×2 Metric grid ───────────────────────────
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AppTheme.sp(context, 10),
                      mainAxisSpacing: AppTheme.sp(context, 10),
                      childAspectRatio: cardRatio,
                      children: _cards
                          .map((c) => DashboardCard(
                                icon: c.icon,
                                iconColor: c.iconColor,
                                iconBg: c.iconBg,
                                title: c.title,
                                value: c.value,
                                subtitle: c.subtitle,
                              ))
                          .toList(),
                    ),

                    SizedBox(height: AppTheme.sp(context, 24)),
                    const _SectionLabel('Procesos en Curso'),
                    SizedBox(height: AppTheme.sp(context, 10)),

                    // ── Processes card ────────────────────────────
                    _ProcessesCard(
                      processes: _processes,
                      maxValue: _processMax,
                    ),

                    SizedBox(height: AppTheme.sp(context, 14)),

                    // ── Summary + Insumos ─────────────────────────
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Expanded(child: SummaryCard()),
                          SizedBox(width: AppTheme.sp(context, 10)),
                          const Expanded(child: ProgressSection()),
                        ],
                      ),
                    ),

                    SizedBox(height: AppTheme.sp(context, 20)),
                    const _AccessButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTheme.sp(context, 20),
        AppTheme.sp(context, 14),
        AppTheme.sp(context, 20),
        8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: AppTheme.fs(context, 22),
                  fontWeight: FontWeight.w800,
                  color: AppTheme.titleColor,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Panel administrativo',
                style: TextStyle(
                  fontSize: AppTheme.fs(context, 12),
                  color: AppTheme.mutedColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const _ProfileIconBtn(),
        ],
      ),
    );
  }
}

class _ProfileIconBtn extends StatelessWidget {
  const _ProfileIconBtn();

  @override
  Widget build(BuildContext context) {
    final size = AppTheme.sp(context, 40);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFF8ACD), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4DA6).withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.person_2_sharp,
        color: const Color(0xFFFF4DA6),
        size: AppTheme.sp(context, 18),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: AppTheme.fs(context, 15),
        fontWeight: FontWeight.w700,
        color: AppTheme.titleColor,
        letterSpacing: -0.3,
      ),
    );
  }
}

// ─── Processes card container ─────────────────────────────────────
class _ProcessesCard extends StatelessWidget {
  final List<_ProcessData> processes;
  final int maxValue;
  const _ProcessesCard({required this.processes, required this.maxValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.sp(context, 16),
        vertical: AppTheme.sp(context, 14),
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: processes
            .map((p) => ProcessItem(
                  label: p.label,
                  value: p.value,
                  maxValue: maxValue,
                  barColor: p.color,
                ))
            .toList(),
      ),
    );
  }
}

// ─── CTA button ───────────────────────────────────────────────────
class _AccessButton extends StatelessWidget {
  const _AccessButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppTheme.sp(context, 52),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.pink.withOpacity(0.45),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.pink,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => Navigator.of(context).pushNamed('/menu'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Acceder al sistema',
              style: TextStyle(
                fontSize: AppTheme.fs(context, 15),
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: Colors.white,
                size: AppTheme.sp(context, 18)),
          ],
        ),
      ),
    );
  }
}

// ─── Local data models ────────────────────────────────────────────
class _CardData {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String value;
  final String subtitle;
  const _CardData({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.value,
    required this.subtitle,
  });
}

class _ProcessData {
  final String label;
  final int value;
  final Color color;
  const _ProcessData(this.label, this.value, this.color);
}
