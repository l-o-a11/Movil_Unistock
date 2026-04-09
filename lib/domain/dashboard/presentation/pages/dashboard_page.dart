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

  // ── Top metric cards ──────────────────────────────────────────
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

  // ── Process rows (solo morado y verde, alternando) ────────────
  static const _processes = [
    _ProcessData('En espera', 50, AppTheme.purple),
    _ProcessData('Tráfico entre sedes', 25, AppTheme.green),
    _ProcessData('Ficha técnica', 15, AppTheme.purple),
    _ProcessData('Corte', 5, AppTheme.green),
    _ProcessData('Diseño', 13, AppTheme.purple),
    _ProcessData('En producción', 10, AppTheme.green),
    _ProcessData('Bodega', 20, AppTheme.purple),
    _ProcessData('Mercadeo', 8, AppTheme.green),
    _ProcessData('Cancelado', 3, AppTheme.purple),
    _ProcessData('Compras', 10, AppTheme.green),
    _ProcessData('Recepción', 2, AppTheme.purple),
  ];

  static const int _processMax = 50;

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('Resumen operativo'),
                    const SizedBox(height: 12),

                    // ── 2×2 Metric grid ───────────────────────
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      children: _cards
                          .map(
                            (c) => DashboardCard(
                              icon: c.icon,
                              iconColor: c.iconColor,
                              iconBg: c.iconBg,
                              title: c.title,
                              value: c.value,
                              subtitle: c.subtitle,
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 28),
                    const _SectionLabel('Procesos en Curso'),
                    const SizedBox(height: 12),

                    // ── Processes card ────────────────────────
                    _ProcessesCard(
                      processes: _processes,
                      maxValue: _processMax,
                    ),

                    const SizedBox(height: 16),

                    // ── Summary + Insumos ─────────────────────
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: SummaryCard()),
                        SizedBox(width: 12),
                        Expanded(child: ProgressSection()),
                      ],
                    ),

                    const SizedBox(height: 24),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.titleColor,
                  letterSpacing: -0.8,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Panel administrativo',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.mutedColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 8),
              const _ProfileIconBtn(),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileIconBtn extends StatelessWidget {
  const _ProfileIconBtn();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
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
      child: const Icon(
        Icons.person_2_sharp,
        color: Color(0xFFFF4DA6),
        size: 20,
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
      style: const TextStyle(
        fontSize: 16,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: processes
            .map(
              (p) => ProcessItem(
                label: p.label,
                value: p.value,
                maxValue: maxValue,
                barColor: p.color,
              ),
            )
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
      height: 56,
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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Acceder al sistema',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Local data models (private to this file) ─────────────────────
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
