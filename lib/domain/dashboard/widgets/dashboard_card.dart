import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String value;
  final String subtitle;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppTheme.scale(context);
    final pad = AppTheme.sp(context, 14);

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36 * s,
                height: 36 * s,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18 * s),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.sp(context, 6),
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: AppTheme.fs(context, 8),
                      fontWeight: FontWeight.w700,
                      color: iconColor,
                      letterSpacing: 0.6,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.sp(context, 8)),
          Text(
            value,
            style: TextStyle(
              fontSize: AppTheme.fs(context, 28),
              fontWeight: FontWeight.w800,
              color: AppTheme.titleColor,
              height: 1.0,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: AppTheme.fs(context, 11),
              color: AppTheme.mutedColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
