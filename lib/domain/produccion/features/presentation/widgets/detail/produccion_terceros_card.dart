import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../domain/entities/tercero_asignacion_entity.dart';

/// Tarjeta de terceros asignados a la orden — usa datos REALES del API.
/// Muestra lista expandible de cada tercero con nombre, proceso y cantidad.
class ProduccionTercerosCard extends StatefulWidget {
  final bool esTerceros;
  final List<TerceroAsignacion> terceros;
  const ProduccionTercerosCard({
    super.key,
    required this.esTerceros,
    this.terceros = const [],
  });

  @override
  State<ProduccionTercerosCard> createState() => _ProduccionTercerosCardState();
}

class _ProduccionTercerosCardState extends State<ProduccionTercerosCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasTerceros = widget.esTerceros && widget.terceros.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header tap
          InkWell(
            onTap: hasTerceros
                ? () => setState(() => _expanded = !_expanded)
                : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.esTerceros
                          ? AppColors.primaryLight
                          : AppColors.chipBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.esTerceros
                          ? Icons.people_alt_rounded
                          : Icons.factory_rounded,
                      color: widget.esTerceros
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.esTerceros
                              ? 'Producción con Tercero'
                              : 'Producción interna',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          hasTerceros
                              ? widget.terceros.length == 1
                                    ? 'En tercero: ${widget.terceros.first.nombre}'
                                    : 'En terceros: ${widget.terceros.map((t) => t.nombre).join(', ')}'
                              : widget.esTerceros
                              ? 'Sin tercero asignado'
                              : '',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasTerceros)
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Lista de terceros expandible
          if (hasTerceros && _expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  ...widget.terceros.map((t) => _TerceroItem(tercero: t)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TerceroItem extends StatelessWidget {
  final TerceroAsignacion tercero;
  const _TerceroItem({required this.tercero});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre + estado badge
          Row(
            children: [
              Expanded(
                child: Text(
                  tercero.nombre,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _EstadoBadge(estado: tercero.estado),
            ],
          ),
          if (tercero.contacto != null) ...[
            const SizedBox(height: 4),
            Text(
              tercero.contacto!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              if (tercero.proceso != null)
                _Chip(icon: Icons.build_rounded, label: tercero.proceso!),
              _Chip(
                icon: Icons.inventory_2_rounded,
                label: '${tercero.cantidad} uds',
              ),
              if (tercero.telefono != null)
                _Chip(icon: Icons.phone_rounded, label: tercero.telefono!),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: AppColors.textSecondary),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
      ),
    ],
  );
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});
  @override
  Widget build(BuildContext context) {
    final isPending =
        estado.toLowerCase().contains('pendiente') ||
        estado.toLowerCase().contains('pending');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPending ? const Color(0xFFFFF3E0) : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: isPending ? const Color(0xFFFF9500) : AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
