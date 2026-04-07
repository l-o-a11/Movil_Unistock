import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../produccion/core/constants/app_colors.dart';
import '../../../../../../shared/widgets/app_back_button.dart';
import '../../domain/entities/tercero_entity.dart';
import '../../domain/entities/tercero_detail_entity.dart';
import '../providers/tercero_detail_provider.dart';
import '../state/tercero_detail_state.dart';
import '../widgets/tercero_detail/tercero_info_tab.dart';
import '../widgets/tercero_detail/tercero_producciones_tab.dart';

/// Pantalla de detalle de un tercero con tabs: Info general / Producciones.
class TerceroDetailPage extends StatefulWidget {
  final TerceroEntity tercero;
  const TerceroDetailPage({super.key, required this.tercero});

  @override
  State<TerceroDetailPage> createState() => _TerceroDetailPageState();
}

class _TerceroDetailPageState extends State<TerceroDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TerceroDetailProvider>().loadDetail(widget.tercero.id);
    });
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Consumer<TerceroDetailProvider>(
        builder: (_, provider, __) {
          final state = provider.state;
          if (state.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5));
          if (state.hasError) return _ErrorView(message: state.error ?? 'Error', onRetry: () => provider.loadDetail(widget.tercero.id));
          if (!state.isLoaded || state.detail == null) return const SizedBox.shrink();
          return _DetailContent(detail: state.detail!, tabController: _tabController);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background, elevation: 0, scrolledUnderElevation: 0, leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: AppBackButton(),
      ),
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('CÓDIGO: ${widget.tercero.codigo}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.4)),
        Text(widget.tercero.nombre,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
        Text(widget.tercero.contacto,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ]),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(width: 42, height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFFF8ACD), width: 2),
              boxShadow: [BoxShadow(color: const Color(0xFFFF4DA6).withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.person_2_sharp, size: 20, color: Color(0xFFFF4DA6))),
        ),
      ],
    );
  }
}

class _DetailContent extends StatefulWidget {
  final TerceroDetailEntity detail;
  final TabController tabController;
  const _DetailContent({required this.detail, required this.tabController});

  @override
  State<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends State<_DetailContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeAc = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  late final Animation<double> _fadeAnim = CurvedAnimation(parent: _fadeAc, curve: Curves.easeOutCubic);

  @override
  void initState() { super.initState(); _fadeAc.forward(); }
  @override
  void dispose() { _fadeAc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(children: [
        // Tab bar
        Container(
          color: AppColors.background,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: widget.tabController,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(color: AppColors.primary, width: 2.5),
              insets: EdgeInsets.symmetric(horizontal: 0),
            ),
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: AppColors.divider,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            tabs: const [Tab(text: 'Información general'), Tab(text: 'Producciones')],
          ),
        ),
        Expanded(child: TabBarView(
          controller: widget.tabController,
          children: [
            TerceroInfoTab(detail: widget.detail),
            TerceroProduccionesTab(producciones: widget.detail.producciones),
          ],
        )),
      ]),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message; final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 68, height: 68,
          decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
          child: const Icon(Icons.error_outline_rounded, color: AppColors.primary, size: 32)),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Reintentar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
        ),
      ]),
    ));
  }
}
