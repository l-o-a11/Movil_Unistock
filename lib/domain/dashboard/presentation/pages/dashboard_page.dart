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
import '../widgets/dashboard_widgets.dart';

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
      DashboardCardData(
        icon: Icons.grid_view_rounded,
        iconColor: AppTheme.purple,
        iconBg: AppTheme.purpleLight,
        title: 'Producciones actuales',
        value: provider.isLoading ? '…' : '${stats.activas}',
      ),
      DashboardCardData(
        icon: Icons.check_rounded,
        iconColor: AppTheme.pink,
        iconBg: AppTheme.pinkLight,
        title: 'Completadas en $currentYear',
        value: provider.isLoading ? '…' : '${stats.completadasMes}',
      ),
      DashboardCardData(
        icon: Icons.access_time_rounded,
        iconColor: AppTheme.pink,
        iconBg: AppTheme.pinkLight,
        title: 'Por iniciar',
        value: provider.isLoading ? '…' : '${stats.porIniciar}',
      ),
      DashboardCardData(
        icon: Icons.calendar_today_rounded,
        iconColor: AppTheme.pink,
        iconBg: AppTheme.pinkLight,
        title: 'Tiempo promedio (${currentYear - 1})',
        value: provider.isLoading ? '…' : stats.avgTime,
      ),
    ];

    final processes = <DashboardProcessData>[];
    final cycleColors = [AppTheme.purple, AppTheme.pink, AppTheme.green];
    for (var i = 0; i < DashboardPage._processLabels.length; i++) {
      final label = DashboardPage._processLabels[i];
      final count = stats.procesoCounts[label] ?? 0;
      processes.add(DashboardProcessData(label, count, cycleColors[i % 3]));
    }
    final maxProcValue = processes.isEmpty
        ? 1
        : processes.map((p) => p.value).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      bottomNavigationBar: const GlobalBottomNav(activeKey: 'dashboard'),
      body: SafeArea(
        child: Column(
          children: [
            const DashboardTopBar(),
            // ── Filtro Semana / Mes / Año ──────────────────────────────────
            DashboardPeriodFilter(
              current: provider.period,
              onChanged: (p) => provider.setPeriod(p),
            ),
            if (provider.error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                            const DashboardSectionLabel(
                              'Estado general de producción',
                            ),
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
                          const DashboardSectionLabel('Procesos en Curso'),
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
