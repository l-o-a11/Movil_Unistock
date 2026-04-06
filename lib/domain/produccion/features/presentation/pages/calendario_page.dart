import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../../../../shared/widgets/global_bottom_nav.dart';
import '../../../../../../shared/widgets/app_back_button.dart';
import '../../domain/entities/orden_entity.dart';
import '../providers/orden_detail_provider.dart';
import '../../../app_dependencies.dart';
import 'orden_detail_page.dart';
import '../../data/datasources/orden_local_datasource.dart';

class _CalEvent {
  final String title;
  final DateTime date;
  final Color color;
  final OrdenEntity? orden;
  const _CalEvent({
    required this.title,
    required this.date,
    required this.color,
    this.orden,
  });
}

class CalendarioPage extends StatefulWidget {
  final List<OrdenEntity> ordenes;
  const CalendarioPage({super.key, required this.ordenes});
  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  bool _isMensual = true;
  late DateTime _month;
  late DateTime _weekStart;
  DateTime? _selected;
  final _sc = TextEditingController();
  String _searchQuery = '';
  List<_CalEvent> _events = [];
  bool _loading = true;

  static const _mn = ['','Enero','Febrero','Marzo','Abril','Mayo','Junio',
      'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
  static const _ma = ['','Ene','Feb','Mar','Abr','May','Jun',
      'Jul','Ago','Sep','Oct','Nov','Dic'];
  static const _wd = ['Lun','Mar','Mié','Jue','Vie','Sáb','Dom'];

  static Color _colorForEstado(OrdenEstado e) {
    switch (e) {
      case OrdenEstado.enProduccion: return AppColors.primary;
      case OrdenEstado.pendiente:    return const Color(0xFF6B7280);
      case OrdenEstado.completado:   return const Color(0xFF34C759);
      default:                       return AppColors.primary;
    }
  }

  @override
  void initState() {
    super.initState();
    _month = DateTime(DateTime.now().year, DateTime.now().month);
    _weekStart = _mon(DateTime.now());
    _sc.addListener(_onSearchChanged);
    _loadOrdenes();
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = _sc.text.trim().toLowerCase());
  }

  List<_CalEvent> get _filteredEvents {
    if (_searchQuery.isEmpty) return _events;
    return _events.where((e) {
      final numMatch = e.orden?.numero.toString().contains(_searchQuery) ?? false;
      final clienteMatch = (e.orden?.cliente?.toLowerCase().contains(_searchQuery)) ?? false;
      final refMatch = (e.orden?.ref?.toLowerCase().contains(_searchQuery)) ?? false;
      return numMatch || clienteMatch || refMatch;
    }).toList();
  }

  Future<void> _loadOrdenes() async {
    final ds = OrdenLocalDataSourceImpl();
    final all = await ds.getOrdenes();
    final events = <_CalEvent>[];
    for (final o in all) {
      if (o.fechaEntrega != null) {
        events.add(_CalEvent(
          title: 'Entrega O.#${o.numero}',
          date: o.fechaEntrega!,
          color: _colorForEstado(o.estado),
          orden: o,
        ));
      }
    }
    final upcoming = _upcomingThree(events);
    DateTime targetMonth = _month;
    if (upcoming.isNotEmpty) {
      final first = upcoming.first.date;
      if (first.year != _month.year || first.month != _month.month) {
        targetMonth = DateTime(first.year, first.month);
      }
    }
    setState(() {
      _events = events;
      _loading = false;
      _month = targetMonth;
    });
  }

  static DateTime _mon(DateTime d) => d.subtract(Duration(days: d.weekday - 1));

  List<_CalEvent> _ev(DateTime d) => _filteredEvents
      .where((e) => e.date.year == d.year && e.date.month == d.month && e.date.day == d.day)
      .toList();

  bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<_CalEvent> _upcomingThree(List<_CalEvent> src) {
    final today = DateTime.now();
    final future = src
        .where((e) => !e.date.isBefore(DateTime(today.year, today.month, today.day)))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return future.take(3).toList();
  }

  void _goToDetail(BuildContext context, OrdenEntity orden) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, animation, __) => ChangeNotifierProvider<OrdenDetailProvider>(
        create: (_) => AppDependencies.createOrdenDetailProvider(),
        child: OrdenDetailPage(orden: orden),
      ),
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: animation.drive(
          Tween(begin: const Offset(1, 0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
        ),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 320),
    ));
  }

  @override
  void dispose() {
    _sc.removeListener(_onSearchChanged);
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const GlobalBottomNav(activeIndex: 3),
      body: SafeArea(child: Column(children: [
        // Header
        Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(children: [
            AppBackButton(),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('Calendario de Producción',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
              Text('Gestión de eventos y fechas',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ])),
            Container(width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 1.5)),
              child: const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.primary)),
          ])),

        if (_loading)
          const Expanded(child: Center(
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5)))
        else
          Expanded(child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            children: [
              // Toggle
              Row(children: [
                Expanded(child: _Btn(label: 'Vista mensual', active: _isMensual,
                    onTap: () => setState(() => _isMensual = true))),
                const SizedBox(width: 8),
                Expanded(child: _Btn(label: 'Vista semanal', active: !_isMensual,
                    onTap: () => setState(() => _isMensual = false))),
              ]),
              const SizedBox(height: 12),

              // ── Buscador funcional ─────────────────────────────────────
              Container(
                decoration: BoxDecoration(color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder)),
                child: TextField(
                  controller: _sc,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Buscar por orden, cliente o referencia...',
                    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, size: 17, color: AppColors.iconInactive),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () => _sc.clear(),
                            child: const Icon(Icons.close_rounded, size: 16, color: AppColors.iconInactive))
                        : null,
                    border: InputBorder.none, isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12)))),
              const SizedBox(height: 8),

              // Resultados del buscador
              if (_searchQuery.isNotEmpty) ...[
                _buildSearchResults(),
                const SizedBox(height: 12),
              ],

              // Calendario
              _isMensual ? _buildMonth() : _buildWeek(),
              const SizedBox(height: 12),

              // ── Panel de procesos del día seleccionado ─────────────────
              if (_selected != null) ...[
                _buildSelectedDayPanel(context),
                const SizedBox(height: 12),
              ],

              // Próximos vencimientos
              _buildVencimientos(context),
              const SizedBox(height: 24),
            ],
          )),
      ])),
    );
  }

  // ── Resultados de búsqueda ──────────────────────────────────────────────────

  Widget _buildSearchResults() {
    final results = _filteredEvents;
    if (results.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder)),
        child: Row(children: const [
          Icon(Icons.search_off_rounded, size: 16, color: AppColors.textHint),
          SizedBox(width: 8),
          Text('Sin resultados para esta búsqueda',
              style: TextStyle(color: AppColors.textHint, fontSize: 12)),
        ]),
      );
    }
    return Container(
      decoration: BoxDecoration(color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
          child: Text('${results.length} resultado(s)',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
        ...results.map((ev) => _buildEventTile(context, ev, showDivider: results.last != ev)),
      ]),
    );
  }

  // ── Panel del día seleccionado ──────────────────────────────────────────────

  Widget _buildSelectedDayPanel(BuildContext context) {
    final evs = _ev(_selected!);
    final dayLabel = '${_selected!.day} de ${_mn[_selected!.month]} ${_selected!.year}';

    return _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Encabezado
      Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(dayLabel,
                style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
            Text(evs.isEmpty ? 'Sin procesos asignados' : '${evs.length} proceso(s) asignado(s)',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ])),
          GestureDetector(
            onTap: () => setState(() => _selected = null),
            child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
          ),
        ]),
      ),

      if (evs.isEmpty)
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
            Icon(Icons.inbox_outlined, size: 18, color: AppColors.textHint),
            SizedBox(width: 8),
            Text('No hay órdenes para este día',
                style: TextStyle(color: AppColors.textHint, fontSize: 13)),
          ]),
        )
      else
        Column(children: evs
            .map((ev) => _buildEventTile(context, ev, showDivider: evs.last != ev))
            .toList()),
    ]));
  }

  // ── Tile de evento reutilizable ─────────────────────────────────────────────

  Widget _buildEventTile(BuildContext context, _CalEvent ev, {bool showDivider = false}) {
    final orden = ev.orden;
    return Column(children: [
      InkWell(
        onTap: orden != null ? () => _goToDetail(context, orden) : null,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Container(
              width: 4, height: 40,
              decoration: BoxDecoration(color: ev.color, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ev.title,
                  style: TextStyle(color: ev.color, fontSize: 13, fontWeight: FontWeight.w600)),
              if (orden?.cliente != null)
                Text(orden!.cliente!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              if (orden?.ref != null)
                Text('Ref: ${orden!.ref}',
                    style: const TextStyle(color: AppColors.textHint, fontSize: 10)),
            ])),
            if (orden != null) ...[
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: ev.color.withAlpha(25), borderRadius: BorderRadius.circular(20)),
                  child: Text(orden.estadoLabel,
                      style: TextStyle(color: ev.color, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 4),
                Text('${orden.unidades} uds',
                    style: const TextStyle(color: AppColors.textHint, fontSize: 10)),
              ]),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward_ios_rounded, size: 11, color: ev.color.withAlpha(160)),
            ],
          ]),
        ),
      ),
      if (showDivider)
        Divider(height: 1, indent: 32, endIndent: 16, color: AppColors.cardBorder),
    ]);
  }

  // ── Vista mensual ──────────────────────────────────────────────────────────

  Widget _buildMonth() {
    final first = DateTime(_month.year, _month.month, 1);
    final last  = DateTime(_month.year, _month.month + 1, 0);
    final off   = (first.weekday - 1) % 7;
    final rows  = ((off + last.day) / 7).ceil();
    final today = DateTime.now();

    return _Card(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(
            onTap: () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
            child: const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary, size: 22)),
          Column(children: [
            Text(_mn[_month.month],
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            Text('${_month.year}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ]),
          GestureDetector(
            onTap: () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
            child: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 22)),
        ])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['LU','MA','MI','JU','VI','SA','DO'].map((d) => SizedBox(width: 36,
            child: Text(d, textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w700)))).toList())),
      const SizedBox(height: 6),
      Padding(padding: const EdgeInsets.fromLTRB(8, 0, 8, 14),
        child: Column(children: List.generate(rows, (row) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (col) {
            final day = row * 7 + col - off + 1;
            if (day < 1 || day > last.day) return const SizedBox(width: 36, height: 44);
            final date = DateTime(_month.year, _month.month, day);
            final isT = _same(date, today);
            final isS = _selected != null && _same(date, _selected!);
            final isW = col >= 5;
            final evs = _ev(date);
            return GestureDetector(
              onTap: () => setState(() {
                _selected = (isS) ? null : date;
              }),
              child: SizedBox(width: 36, height: 44, child: Column(
                mainAxisAlignment: MainAxisAlignment.center, children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: isS ? AppColors.primary : isT ? AppColors.primarySoft : Colors.transparent,
                      shape: BoxShape.circle),
                    child: Center(child: Text('$day', style: TextStyle(
                      color: isS ? Colors.white
                           : isT ? AppColors.primary
                           : isW ? AppColors.primary.withAlpha(140)
                           : AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: isT || isS ? FontWeight.w700 : FontWeight.w500)))),
                  if (evs.isNotEmpty)
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: evs.take(3).map((e) => Container(
                        width: 5, height: 5,
                        margin: const EdgeInsets.only(top: 2, left: 1),
                        decoration: BoxDecoration(color: e.color, shape: BoxShape.circle))).toList())
                  else
                    const SizedBox(height: 7),
                ])));
          }))))),
    ]));
  }

  // ── Vista semanal ──────────────────────────────────────────────────────────

  Widget _buildWeek() {
    final today = DateTime.now();
    final days  = List.generate(7, (i) => _weekStart.add(Duration(days: i)));

    return _Card(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(
            onTap: () => setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7))),
            child: const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary, size: 22)),
          Column(children: [
            Text('${_wd[_weekStart.weekday-1]} ${_weekStart.day} — '
                '${_wd[days.last.weekday-1]} ${days.last.day} ${_mn[_weekStart.month]}',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
            Text('${_weekStart.year}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ]),
          GestureDetector(
            onTap: () => setState(() => _weekStart = _weekStart.add(const Duration(days: 7))),
            child: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 22)),
        ])),
      Padding(padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days.map((date) {
            final isT = _same(date, today);
            final isS = _selected != null && _same(date, _selected!);
            final evs = _ev(date);
            return GestureDetector(
              onTap: () => setState(() {
                _selected = (isS) ? null : date;
              }),
              child: SizedBox(width: 42, child: Column(children: [
                Text(_wd[date.weekday - 1],
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: isS ? AppColors.primary : isT ? AppColors.primarySoft : Colors.transparent,
                    shape: BoxShape.circle),
                  child: Center(child: Text('${date.day}', style: TextStyle(
                    color: isS ? Colors.white : isT ? AppColors.primary : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: isT || isS ? FontWeight.w700 : FontWeight.w500)))),
                const SizedBox(height: 4),
                ...evs.map((e) => Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  decoration: BoxDecoration(
                    color: e.color.withAlpha(30), borderRadius: BorderRadius.circular(4)),
                  child: Text(e.title,
                    style: TextStyle(color: e.color, fontSize: 7, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis))),
              ])));
          }).toList())),
    ]));
  }

  // ── Próximos vencimientos ──────────────────────────────────────────────────

  Widget _buildVencimientos(BuildContext context) {
    final list = _upcomingThree(_filteredEvents);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Próximos vencimientos',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      if (list.isEmpty)
        Center(child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
              _searchQuery.isNotEmpty
                  ? 'Sin vencimientos para esta búsqueda'
                  : 'No hay vencimientos próximos',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))))
      else
        ...list.asMap().entries.map((en) {
          final ev = en.value;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + en.key * 90),
            curve: Curves.easeOutCubic,
            builder: (_, v, child) =>
                Opacity(opacity: v, child: Transform.translate(offset: Offset(0, (1-v)*10), child: child)),
            child: GestureDetector(
              onTap: ev.orden != null ? () => _goToDetail(context, ev.orden!) : null,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: ev.color.withAlpha(20),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ev.color.withAlpha(40), width: 0.8)),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(ev.title,
                        style: TextStyle(color: ev.color, fontSize: 13, fontWeight: FontWeight.w600)),
                    if (ev.orden?.cliente != null)
                      Text(ev.orden!.cliente!,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ])),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: ev.color.withAlpha(25), borderRadius: BorderRadius.circular(20)),
                      child: Text('${ev.date.day} ${_ma[ev.date.month]}',
                          style: TextStyle(color: ev.color, fontSize: 12, fontWeight: FontWeight.w700))),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: ev.color.withAlpha(160)),
                  ]),
                ])),
            ));
        }),
    ]);
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child; const _Card({required this.child});
  @override Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: AppColors.surface,
      borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder),
      boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 3))]),
    child: child);
}

class _Btn extends StatelessWidget {
  final String label; final bool active; final VoidCallback onTap;
  const _Btn({required this.label, required this.active, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: AnimatedContainer(duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? AppColors.primary : AppColors.cardBorder),
        boxShadow: active
            ? [BoxShadow(color: AppColors.primary.withAlpha(70), blurRadius: 8, offset: const Offset(0, 3))]
            : null),
      child: Text(label, textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? Colors.white : AppColors.textSecondary,
            fontSize: 13, fontWeight: FontWeight.w600))));
}
