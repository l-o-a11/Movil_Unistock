import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/widgets/global_bottom_nav.dart';
import '../../../../../shared/widgets/app_back_button.dart';
import '../../../../../shared/widgets/profile_menu_button.dart';
import '../../domain/entities/proveedor_entity.dart';
import '../providers/proveedores_provider.dart';

/// Página de proveedores de materiales/servicios.
/// 
/// Muestra:
/// - Buscador de proveedores
/// - Lista animada de tarjetas
/// - Modal detalle con blur backdrop al presionar
/// - Diseño minimalista con colores personalizados (pink, grey, green)
class ProveedoresPage extends StatelessWidget {
  const ProveedoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProveedoresProvider(),
      child: const _ProveedoresView(),
    );
  }
}

/// Vista interna de proveedores con controlador de búsqueda.
class _ProveedoresView extends StatefulWidget {
  const _ProveedoresView();
  @override State<_ProveedoresView> createState() => _ProveedoresViewState();
}

class _ProveedoresViewState extends State<_ProveedoresView> {
  final _ctrl = TextEditingController();
  static const _pink = Color(0xFFFF4FA3);
  static const _bg = Color(0xFFF5F5F7);
  static const _text = Color(0xFF1C1C1E);
  static const _grey = Color(0xFF8E8E93);

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: const GlobalBottomNav(),
      body: SafeArea(child: Column(children: [
        // Header
        Padding(padding: const EdgeInsets.fromLTRB(16,14,16,10),
          child: Row(children: [
            AppBackButton(),
            const SizedBox(width:14),
            const Text('Proveedores', style:TextStyle(color:_text, fontSize:20, fontWeight:FontWeight.w800, letterSpacing:-0.4)),
            const Spacer(),
             ProfileMenuButton(
               size: 42,
               iconSize: 20,
             ),
          ])),
        // Search
        Padding(padding:const EdgeInsets.symmetric(horizontal:16),
          child:Container(
            height: 46,
            decoration:BoxDecoration(
              color:Colors.white,
              borderRadius:BorderRadius.circular(12),
              border:Border.all(color:const Color(0xFFEEEEEE))),
            child:Row(
              children: [
                const SizedBox(width: 12),
                const Icon(
                  Icons.search_rounded,
                  color: Color(0xFFAEAEB2),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    onChanged: (v) => context.read<ProveedoresProvider>().search(v),
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 15,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Buscar proveedores...',
                      hintStyle: TextStyle(
                        color: Color(0xFFAEAEB2),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height:16),
        // List
        Expanded(child:Consumer<ProveedoresProvider>(
          builder:(_,p,__)  {
            if (p.isLoading) return const Center(child:CircularProgressIndicator(color:_pink, strokeWidth:2.5));
            if (p.error != null) return Center(child:Column(children:[
              const Icon(Icons.error_outline_rounded, color: _pink, size: 40),
              const SizedBox(height: 8),
              Text(p.error!, style:const TextStyle(color: _grey), textAlign: TextAlign.center),
            ]));
            final filtrados = p.proveedoresFiltrados;
            if (filtrados.isEmpty) return const Center(child:Text('No se encontraron proveedores.', style:TextStyle(color: _grey, fontSize:14)));
            final visibles = p.visibleItems;
            return ListView.builder(
              padding:const EdgeInsets.fromLTRB(16,0,16,24),
              itemCount:visibles.length + (p.hasMore ? 1 : 0),
              itemBuilder:(ctx,i) {
                if (i == visibles.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 12),
                    child: Center(
                      child: OutlinedButton(
                        onPressed: p.showMore,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _pink,
                          side: BorderSide(color: _pink.withOpacity(0.4)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Ver más'),
                      ),
                    ),
                  );
                }
                return TweenAnimationBuilder<double>(
                tween:Tween(begin:0,end:1), duration:Duration(milliseconds:300+i*60), curve:Curves.easeOutCubic,
                builder:(_,v,child)=>Opacity(opacity:v, child:Transform.translate(offset:Offset(0,(1-v)*14), child:child)),
                child:_ProveedorCard(prov:visibles[i], onTap:()=>_showDetail(context, visibles[i])));
              });
          })),
      ])),
    );
  }

  void _showDetail(BuildContext context, ProveedorEntity prov) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: 'close',
      transitionDuration: const Duration(milliseconds:320),
      pageBuilder:(ctx, animation, _) => _ProvDetail(prov:prov, animation:animation),
      transitionBuilder:(_,animation,__,child) => FadeTransition(
        opacity:CurvedAnimation(parent:animation, curve:Curves.easeOut), child:child),
    );
  }
}

class _ProveedorCard extends StatelessWidget {
  final ProveedorEntity prov; final VoidCallback onTap;
  const _ProveedorCard({required this.prov, required this.onTap});
  static const _pink = Color(0xFFFF4FA3);
  static const _text = Color(0xFF1C1C1E);
  static const _grey = Color(0xFF8E8E93);
  static const _green = Color(0xFF34C759);

  @override
  Widget build(BuildContext context) {
    final active = prov.isActivo;
    return Container(
      margin:const EdgeInsets.only(bottom:12),
      decoration:BoxDecoration(color:Colors.white, borderRadius:BorderRadius.circular(16),
        border:Border.all(color:_pink.withOpacity(0.35), width:1.1),
        boxShadow:[BoxShadow(color:_pink.withOpacity(0.06), blurRadius:10, offset:const Offset(0,2))]),
      child:Padding(padding:const EdgeInsets.all(16),
        child:Row(crossAxisAlignment:CrossAxisAlignment.start, children:[
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
            Text('NIT: ${prov.nit}', style:const TextStyle(color:_grey, fontSize:11, fontWeight:FontWeight.w500, letterSpacing:0.3)),
            const SizedBox(height:4),
            Row(children:[
              Expanded(child:Text(prov.nombre, style:const TextStyle(color:_text, fontSize:17, fontWeight:FontWeight.w700))),
              Row(children:[
                Container(width:7, height:7, decoration:BoxDecoration(color:active?_green:_grey, shape:BoxShape.circle)),
                const SizedBox(width:4),
                Text(prov.estadoLabel, style:TextStyle(color:active?_green:_grey, fontSize:11, fontWeight:FontWeight.w700)),
              ]),
            ]),
            const SizedBox(height:8),
            Row(children:[
              const Icon(Icons.person_outline_rounded, size:13, color:_grey),
              const SizedBox(width:4),
              const Text('CONTACTO', style:TextStyle(color:_grey, fontSize:10, fontWeight:FontWeight.w600, letterSpacing:0.5)),
            ]),
            const SizedBox(height:2),
            Text(prov.contacto, style:const TextStyle(color:_text, fontSize:13, fontWeight:FontWeight.w500)),
          ])),
          const SizedBox(width:12),
          GestureDetector(onTap:onTap,
            child:Container(width:36, height:36,
              decoration:BoxDecoration(color:_pink.withOpacity(0.1), shape:BoxShape.circle, border:Border.all(color:_pink.withOpacity(0.4))),
              child:const Icon(Icons.arrow_forward_ios_rounded, size:14, color:_pink))),
        ])));
  }
}

class _ProvDetail extends StatelessWidget {
  final ProveedorEntity prov; final Animation<double> animation;
  const _ProvDetail({required this.prov, required this.animation});
  static const _pink = Color(0xFFFF4FA3);
  static const _text = Color(0xFF1C1C1E);
  static const _grey = Color(0xFF8E8E93);
  static const _green = Color(0xFF34C759);

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    return Stack(fit:StackFit.expand, children:[
      GestureDetector(onTap:()=>Navigator.of(context).pop(),
        child:BackdropFilter(filter:ImageFilter.blur(sigmaX:5,sigmaY:5),
          child:Container(color:Colors.black.withOpacity(0.35)))),
      Align(alignment:Alignment.bottomCenter,
        child:SlideTransition(
          position:Tween<Offset>(begin:const Offset(0,1), end:Offset.zero)
            .animate(CurvedAnimation(parent:animation, curve:Curves.easeOutCubic)),
          child:Material(type:MaterialType.transparency, child:Container(
            constraints:BoxConstraints(maxHeight:sh*0.78),
            decoration:const BoxDecoration(color:Colors.white, borderRadius:BorderRadius.vertical(top:Radius.circular(24))),
            child:Column(mainAxisSize:MainAxisSize.min, children:[
              Container(margin:const EdgeInsets.only(top:12), width:40, height:4,
                decoration:BoxDecoration(color:const Color(0xFFE0E0E0), borderRadius:BorderRadius.circular(2))),
              Padding(padding:const EdgeInsets.fromLTRB(16,14,16,4),
                child:Row(children:[
                  Container(width:40, height:40,
                    decoration:BoxDecoration(color:_pink.withOpacity(0.12), borderRadius:BorderRadius.circular(12)),
                    child:const Icon(Icons.local_shipping_outlined, color:_pink, size:22)),
                  const SizedBox(width:10),
                  const Text('Proveedores', style:TextStyle(color:_text, fontSize:16, fontWeight:FontWeight.w700)),
                  const Spacer(),
                  GestureDetector(onTap:()=>Navigator.of(context).pop(),
                    child:Container(width:30, height:30,
                      decoration:BoxDecoration(color:const Color(0xFFF0F0F0), borderRadius:BorderRadius.circular(8)),
                      child:const Icon(Icons.close_rounded, size:16, color:Color(0xFF555555)))),
                ])),
              const Divider(height:1, color:Color(0xFFF0F0F0)),
              Flexible(child:SingleChildScrollView(padding:const EdgeInsets.fromLTRB(20,16,20,8),
                child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
                  Text(prov.nombre, style:const TextStyle(color:_text, fontSize:20, fontWeight:FontWeight.w800)),
                  const SizedBox(height:2),
                  Text('NIT: ${prov.nit}', style:const TextStyle(color:_grey, fontSize:13)),
                  const SizedBox(height:16),
                  const Text('Estado', style:TextStyle(color:_grey, fontSize:11, fontWeight:FontWeight.w600, letterSpacing:0.5)),
                  const SizedBox(height:4),
                  Row(children:[
                    Container(width:8, height:8, decoration:BoxDecoration(
                      color:prov.isActivo?_green:_grey, shape:BoxShape.circle)),
                    const SizedBox(width:6),
                    Text(prov.estadoLabel, style:TextStyle(color:prov.isActivo?_green:_grey, fontSize:14, fontWeight:FontWeight.w700)),
                  ]),
                  const SizedBox(height:14),
                  _Row(icon:Icons.person_outline_rounded,    label:'CONTACTO',  value:prov.contacto),
                  _Row(icon:Icons.location_on_outlined,      label:'DIRECCIÓN', value:prov.direccion),
                  _Row(icon:Icons.phone_outlined,            label:'TELÉFONO',  value:prov.telefono),
                  _Row(icon:Icons.email_outlined,            label:'CORREO',    value:prov.correo),
                  _Row(icon:Icons.language_outlined,         label:'SITIO WEB', value:prov.sitioWeb, isLast:true),
                ]))),
              Padding(padding:const EdgeInsets.fromLTRB(20,8,20,24),
                child:GestureDetector(onTap:()=>Navigator.of(context).pop(),
                  child:Container(width:double.infinity, padding:const EdgeInsets.symmetric(vertical:16),
                    decoration:BoxDecoration(
                      gradient:const LinearGradient(colors:[_pink, Color(0xFFFF6EC7)],
                        begin:Alignment.centerLeft, end:Alignment.centerRight),
                      borderRadius:BorderRadius.circular(14)),
                    child:const Text('Cerrar', textAlign:TextAlign.center,
                      style:TextStyle(color:Colors.white, fontSize:16, fontWeight:FontWeight.w700))))),
            ])),
        ))),
    ]);
  }
}

class _Row extends StatelessWidget {
  final IconData icon; final String label, value; final bool isLast;
  const _Row({required this.icon, required this.label, required this.value, this.isLast=false});
  static const _grey = Color(0xFF8E8E93); static const _text = Color(0xFF1C1C1E);
  @override
  Widget build(BuildContext context) => Padding(padding:EdgeInsets.only(bottom:isLast?0:14),
    child:Row(crossAxisAlignment:CrossAxisAlignment.start, children:[
      Icon(icon, size:16, color:_grey), const SizedBox(width:8),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        Text(label, style:const TextStyle(color:_grey, fontSize:10, fontWeight:FontWeight.w600, letterSpacing:0.5)),
        const SizedBox(height:2),
        Text(value, style:const TextStyle(color:_text, fontSize:14, fontWeight:FontWeight.w500)),
      ])),
    ]));
}
