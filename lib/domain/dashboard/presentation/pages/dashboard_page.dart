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

  static const _processLabels = [
    'Ficha técnica',
    'Corte',
    'Diseño',
    'En producción',
    'Bodega',
    'Cancelado',
    'Compras',
    'Recepción',
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
    final provider = context.watch<DashboardProvider>();
    final stats = provider.stats;
    final hPad = AppTheme.sp(context, 16);

    final currentYear = DateTime.now().year;
    final cards = [
      _CardData(
        icon: Icons.grid_view_rounded,
        iconColor: AppTheme.purple,
        iconBg: AppTheme.purpleLight,
        title: 'Producciones actuales',
        value: provider.isLoading ? '…' : '${stats.activas}',
      ),
      _CardData(
        icon: Icons.check_rounded,
        iconColor: AppTheme.pink,
        iconBg: AppTheme.pinkLight,
        title: 'Completadas en $currentYear',
        value: provider.isLoading ? '…' : '${stats.completadasMes}',
      ),
      _CardData(
        icon: Icons.access_time_rounded,
        iconColor: AppTheme.pink,
        iconBg: AppTheme.pinkLight,
        title: 'Por iniciar',
        value: provider.isLoading ? '…' : '${stats.porIniciar}',
      ),
      _CardData(
        icon: Icons.calendar_today_rounded,
        iconColor: AppTheme.pink,
        iconBg: AppTheme.pinkLight,
        title: 'Tiempo promedio (${currentYear - 1})',
        value: provider.isLoading ? '…' : stats.avgTime,
      ),
    ];

    final processes = <_ProcessData>[];
    final cycleColors = [AppTheme.purple, AppTheme.pink, AppTheme.green];
    for (var i = 0; i < DashboardPage._processLabels.length; i++) {
      final label = DashboardPage._processLabels[i];
      final count = stats.procesoCounts[label] ?? 0;
      processes.add(_ProcessData(label, count, cycleColors[i % 3]));
    }
    final maxProcValue = processes.isEmpty
        ? 1
        : processes.map((p) => p.value).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      bottomNavigationBar: const GlobalBottomNav(activeIndex: 0),
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            // ── Filtro Semana / Mes / Año ──────────────────────────────────
            _PeriodFilter(
              current: provider.period,
              onChanged: (p) => provider.setPeriod(p),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.load(),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Estado general de producción ───────────────────
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(AppTheme.sp(context, 16)),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(
                            AppTheme.cardRadius,
                          ),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionLabel('Estado general de producción'),
                            SizedBox(height: AppTheme.sp(context, 12)),
                            Row(
                              children: [
                                Expanded(
                                  child: DashboardCard(
                                    icon: cards[0].icon,
                                    iconColor: cards[0].iconColor,
                                    iconBg: cards[0].iconBg,
                                    title: cards[0].title,
                                    value: cards[0].value,
                                  ),
                                ),
                                SizedBox(width: AppTheme.sp(context, 8)),
                                Expanded(
                                  child: DashboardCard(
                                    icon: cards[1].icon,
                                    iconColor: cards[1].iconColor,
                                    iconBg: cards[1].iconBg,
                                    title: cards[1].title,
                                    value: cards[1].value,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppTheme.sp(context, 8)),
                            Row(
                              children: [
                                Expanded(
                                  child: DashboardCard(
                                    icon: cards[2].icon,
                                    iconColor: cards[2].iconColor,
                                    iconBg: cards[2].iconBg,
                                    title: cards[2].title,
                                    value: cards[2].value,
                                  ),
                                ),
                                SizedBox(width: AppTheme.sp(context, 8)),
                                Expanded(
                                  child: DashboardCard(
                                    icon: cards[3].icon,
                                    iconColor: cards[3].iconColor,
                                    iconBg: cards[3].iconBg,
                                    title: cards[3].title,
                                    value: cards[3].value,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppTheme.sp(context, 24)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const _SectionLabel('Procesos en Curso'),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.pinkLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.pink.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              '${processes.length} estados',
                              style: TextStyle(
                                fontSize: AppTheme.fs(context, 10),
                                fontWeight: FontWeight.w700,
                                color: AppTheme.pink,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.sp(context, 10)),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.sp(context, 16),
                          vertical: AppTheme.sp(context, 14),
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(
                            AppTheme.cardRadius,
                          ),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: provider.isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Column(
                                children: processes
                                    .map(
                                      (p) => ProcessItem(
                                        label: p.label,
                                        value: p.value,
                                        maxValue: maxProcValue,
                                        barColor: p.color,
                                      ),
                                    )
                                    .toList(),
                              ),
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
                    ],
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
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppTheme.pink.withOpacity(0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    p.label,
                    style: TextStyle(
                      color: selected ? Colors.white : AppTheme.mutedColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
      padding: EdgeInsets.fromLTRB(
        AppTheme.sp(context, 20),
        AppTheme.sp(context, 14),
        AppTheme.sp(context, 20),
        4,
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: AppTheme.fs(context, 15),
      fontWeight: FontWeight.w700,
      color: AppTheme.titleColor,
      letterSpacing: -0.3,
    ),
  );
}

class _CardData {
  final IconData icon;
  final Color iconColor, iconBg;
  final String title, value;
  const _CardData({
    required this.icon,

    required this.iconColor,

    required this.iconBg,

    required this.title,

    required this.value,
  });
}

class _ProcessData {
  final String label;

  final int value;

  final Color color;

  const _ProcessData(this.label, this.value, this.color);
}
