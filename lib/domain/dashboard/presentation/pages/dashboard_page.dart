import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/global_bottom_nav.dart';
import '../../theme/app_theme.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/process_item.dart';
import '../../widgets/progress_section.dart';
import '../../widgets/summary_card.dart';
import '../providers/dashboard_provider.dart';
import '../../data/dashboard_data_source.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const int _processMax = 50;
  static const _processLabels = [
    'En espera', 'Tráfico entre sedes', 'Ficha técnica', 'Corte', 'Diseño',
    'En producción', 'Bodega', 'Mercadeo', 'Cancelado', 'Compras', 'Recepción',
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<DashboardProvider>();
    final stats     = provider.stats;
    final hPad      = AppTheme.sp(context, 16);
    final s         = AppTheme.scale(context);
    final cardRatio = 0.95 + 0.20 * (s - 0.78) / 0.22;

    final cards = [
      _CardData(icon: Icons.bolt_rounded, iconColor: AppTheme.purple, iconBg: AppTheme.purpleLight,
        title: 'ACTUALES', value: provider.isLoading ? '…' : '${stats.activas}', subtitle: 'prod.'),
      _CardData(icon: Icons.check_rounded, iconColor: AppTheme.green, iconBg: AppTheme.greenLight,
        title: 'COMPLETADAS', value: provider.isLoading ? '…' : '${stats.completadasMes}', subtitle: provider.period.label.toLowerCase()),
      _CardData(icon: Icons.schedule_rounded, iconColor: AppTheme.pink, iconBg: AppTheme.pinkLight,
        title: 'POR INICIAR', value: provider.isLoading ? '…' : '${stats.porIniciar}', subtitle: 'pendientes'),
      _CardData(icon: Icons.access_time_rounded, iconColor: AppTheme.purple, iconBg: AppTheme.purpleLight,
        title: 'PROMEDIO', value: provider.isLoading ? '…' : stats.avgTime, subtitle: 'días (mes ant.)'),
    ];

    final processes = DashboardPage._processLabels.map((label) {
      final count = stats.procesoCounts[label] ?? 0;
      return _ProcessData(label, count, count > 0 ? AppTheme.purple : AppTheme.green);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      bottomNavigationBar: const GlobalBottomNav(activeIndex: 0),
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            // ── Filtro Semana / Mes / Año ──────────────────────────────────
            _PeriodFilter(current: provider.period,
              onChanged: (p) => provider.setPeriod(p)),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('Resumen operativo'),
                    SizedBox(height: AppTheme.sp(context, 10)),

                    // 2×2 grid de KPIs
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AppTheme.sp(context, 10),
                      mainAxisSpacing:  AppTheme.sp(context, 10),
                      childAspectRatio: cardRatio,
                      children: cards.map((c) => DashboardCard(
                        icon: c.icon, iconColor: c.iconColor, iconBg: c.iconBg,
                        title: c.title, value: c.value, subtitle: c.subtitle,
                      )).toList(),
                    ),

                    SizedBox(height: AppTheme.sp(context, 24)),
                    const _SectionLabel('Procesos en Curso'),
                    SizedBox(height: AppTheme.sp(context, 10)),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.sp(context, 16),
                        vertical:   AppTheme.sp(context, 14),
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: provider.isLoading
                          ? const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                          : Column(children: processes.map((p) => ProcessItem(
                              label: p.label, value: p.value,
                              maxValue: DashboardPage._processMax, barColor: p.color,
                            )).toList()),
                    ),

                    SizedBox(height: AppTheme.sp(context, 14)),

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

// ── Filtro de período ─────────────────────────────────────────────────────────
class _PeriodFilter extends StatelessWidget {
  final DashboardPeriod current;
  final ValueChanged<DashboardPeriod> onChanged;
  const _PeriodFilter({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: DashboardPeriod.values.map((p) {
            final selected = p == current;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.pink : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: selected ? [BoxShadow(color: AppTheme.pink.withOpacity(0.35), blurRadius: 6, offset: const Offset(0, 2))] : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(p.label,
                    style: TextStyle(
                      color: selected ? Colors.white : AppTheme.mutedColor,
                      fontSize: 12, fontWeight: FontWeight.w600,
                    )),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppTheme.sp(context, 20), AppTheme.sp(context, 14), AppTheme.sp(context, 20), 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Dashboard', style: TextStyle(fontSize: AppTheme.fs(context, 22), fontWeight: FontWeight.w800, color: AppTheme.titleColor, letterSpacing: -0.8)),
          const SizedBox(height: 2),
          Text('Panel administrativo', style: TextStyle(fontSize: AppTheme.fs(context, 12), color: AppTheme.mutedColor, fontWeight: FontWeight.w400)),
        ]),
        const _ProfileIconBtn(),
      ]),
    );
  }
}

class _ProfileIconBtn extends StatelessWidget {
  const _ProfileIconBtn();
  @override
  Widget build(BuildContext context) {
    final size = AppTheme.sp(context, 40);
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle, color: Colors.white,
        border: Border.all(color: const Color(0xFFFF8ACD), width: 2),
        boxShadow: [BoxShadow(color: const Color(0xFFFF4DA6).withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Icon(Icons.person_2_sharp, color: const Color(0xFFFF4DA6), size: AppTheme.sp(context, 18)),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: TextStyle(fontSize: AppTheme.fs(context, 15), fontWeight: FontWeight.w700, color: AppTheme.titleColor, letterSpacing: -0.3));
}

class _AccessButton extends StatelessWidget {
  const _AccessButton();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, height: AppTheme.sp(context, 52),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppTheme.pink.withOpacity(0.45), blurRadius: 20, spreadRadius: 1, offset: const Offset(0, 6))],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pink, elevation: 0, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        onPressed: () => Navigator.of(context).pushNamed('/menu'),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Acceder al sistema', style: TextStyle(fontSize: AppTheme.fs(context, 15), fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.2)),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: AppTheme.sp(context, 18)),
        ]),
      ),
    );
  }
}

class _CardData {
  final IconData icon;
  final Color iconColor, iconBg;
  final String title, value, subtitle;
  const _CardData({required this.icon, required this.iconColor, required this.iconBg, required this.title, required this.value, required this.subtitle});
}

class _ProcessData {
  final String label; final int value; final Color color;
  const _ProcessData(this.label, this.value, this.color);
}