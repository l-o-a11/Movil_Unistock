import 'package:flutter/material.dart';

import '../../data/dashboard_data_source.dart';
import '../../theme/app_theme.dart';

class DashboardPeriodFilter extends StatelessWidget {
  const DashboardPeriodFilter({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final DashboardPeriod current;
  final ValueChanged<DashboardPeriod> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    child: Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: DashboardPeriod.values.map((period) {
          final selected = period == current;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.pink : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Text(
                  period.label,
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

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({super.key});

  @override
  Widget build(BuildContext context) => Padding(
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
              ),
            ),
            Text(
              'Panel administrativo',
              style: TextStyle(
                fontSize: AppTheme.fs(context, 12),
                color: AppTheme.mutedColor,
              ),
            ),
          ],
        ),
        const _ProfileIcon(),
      ],
    ),
  );
}

class DashboardSectionLabel extends StatelessWidget {
  const DashboardSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: AppTheme.fs(context, 15),
      fontWeight: FontWeight.w700,
      color: AppTheme.titleColor,
    ),
  );
}

class DashboardCardData {
  const DashboardCardData({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String value;
}

class DashboardProcessData {
  const DashboardProcessData(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}

class _ProfileIcon extends StatelessWidget {
  const _ProfileIcon();

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
      ),
      child: Icon(
        Icons.person_2_sharp,
        color: const Color(0xFFFF4DA6),
        size: AppTheme.sp(context, 18),
      ),
    );
  }
}
