import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../domain/entities/historial_entry_entity.dart';

class HistorialCard extends StatelessWidget {
  final List<HistorialEntryEntity> historial;
  final VoidCallback onVerTodo;
  const HistorialCard({super.key, required this.historial, required this.onVerTodo});

  String _fmtDate(DateTime d) {
    const m = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${d.day} ${m[d.month]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8),
            blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.history_rounded,
                  color: AppColors.primary, size: 17)),
            const SizedBox(width: 10),
            const Expanded(child: Text('Historial',
                style: TextStyle(color: AppColors.textPrimary,
                    fontSize: 14, fontWeight: FontWeight.w700))),
            if (historial.length > 3)
              GestureDetector(
                onTap: onVerTodo,
                child: const Text('Ver todo',
                    style: TextStyle(color: AppColors.primary,
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ),
          ]),
          const SizedBox(height: 14),
          if (historial.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Sin historial disponible',
                  style: TextStyle(color: AppColors.textHint, fontSize: 13)),
            )
          else
            ...historial.take(4).toList().asMap().entries.map((e) {
              final isLast = e.key == historial.take(4).length - 1;
              return _HistorialItem(entry: e.value, isLast: isLast,
                  dateStr: _fmtDate(e.value.fecha));
            }),
        ],
      ),
    );
  }
}

class _HistorialItem extends StatelessWidget {
  final HistorialEntryEntity entry;
  final bool isLast;
  final String dateStr;
  const _HistorialItem({required this.entry, required this.isLast, required this.dateStr});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 32, child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(width: 10, height: 10,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle)),
              if (!isLast)
                Expanded(child: Container(width: 1.5,
                    color: AppColors.cardBorder)),
            ],
          )),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(entry.etapa,
                      style: const TextStyle(color: AppColors.textPrimary,
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(dateStr,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ]),
                const SizedBox(height: 2),
                Text(entry.responsable,
                    style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
