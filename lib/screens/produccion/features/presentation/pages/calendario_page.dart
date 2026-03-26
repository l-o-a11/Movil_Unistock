import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/global_bottom_nav.dart';

class _CalEvent { final String title; final DateTime date; final Color color;
  const _CalEvent({required this.title, required this.date, required this.color}); }

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});
  @override State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  bool _isMensual = true;
  DateTime _month = DateTime(2025, 12);
  DateTime _weekStart = _mon(DateTime(2025, 12, 15));
  DateTime? _selected;
  final _sc = TextEditingController();

  static const _mn = ['','Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
  static const _ma = ['','Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
  static const _wd = ['Lun','Mar','Mié','Jue','Vie','Sáb','Dom'];

  final _events = [
    _CalEvent(title:'Inicio de producción',date:DateTime(2025,12,18),color:AppColors.primary),
    _CalEvent(title:'Control de calidad',  date:DateTime(2025,12,23),color:Color(0xFF6B7280)),
    _CalEvent(title:'Fecha de entrega',    date:DateTime(2025,12,30),color:Color(0xFF34C759)),
    _CalEvent(title:'Revisión diseño',     date:DateTime(2025,12,5), color:Color(0xFF34C759)),
    _CalEvent(title:'Corte materiales',    date:DateTime(2025,12,10),color:Color(0xFF34C759)),
    _CalEvent(title:'Entrega parcial',     date:DateTime(2025,12,12),color:AppColors.primary),
  ];

  static DateTime _mon(DateTime d) => d.subtract(Duration(days: d.weekday-1));
  List<_CalEvent> _ev(DateTime d) => _events.where((e) =>
      e.date.year==d.year && e.date.month==d.month && e.date.day==d.day).toList();
  bool _same(DateTime a, DateTime b) => a.year==b.year&&a.month==b.month&&a.day==b.day;

  @override void dispose() { _sc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const GlobalBottomNav(),
      body: SafeArea(child: Column(children: [
        // Header
        Padding(padding: const EdgeInsets.fromLTRB(16,14,16,10),
          child: Row(children: [
            GestureDetector(onTap: ()=>Navigator.of(context).pop(),
              child: Container(width:34,height:34,
                decoration:BoxDecoration(color:AppColors.chipBackground,borderRadius:BorderRadius.circular(10)),
                child:const Icon(Icons.arrow_back_ios_new_rounded,size:15,color:AppColors.textPrimary))),
            const SizedBox(width:12),
            Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              const Text('Calendario de Producción',style:TextStyle(color:AppColors.textPrimary,fontSize:16,fontWeight:FontWeight.w700)),
              const Text('Gestión de eventos y fechas',style:TextStyle(color:AppColors.textSecondary,fontSize:11)),
            ])),
            Container(width:34,height:34,
              decoration:BoxDecoration(color:AppColors.primarySoft,shape:BoxShape.circle,border:Border.all(color:AppColors.primary,width:1.5)),
              child:const Icon(Icons.person_outline_rounded,size:18,color:AppColors.primary)),
          ])),
        Expanded(child: ListView(padding:const EdgeInsets.symmetric(horizontal:16,vertical:6),children:[
          // Toggle
          Row(children:[
            Expanded(child:_Btn(label:'Vista mensual',active:_isMensual,onTap:()=>setState(()=>_isMensual=true))),
            const SizedBox(width:8),
            Expanded(child:_Btn(label:'Vista semanal',active:!_isMensual,onTap:()=>setState(()=>_isMensual=false))),
          ]),
          const SizedBox(height:12),
          // Search
          Container(decoration:BoxDecoration(color:AppColors.surface,borderRadius:BorderRadius.circular(12),border:Border.all(color:AppColors.cardBorder)),
            child:TextField(controller:_sc,style:const TextStyle(fontSize:13,color:AppColors.textPrimary),
              decoration:const InputDecoration(hintText:'Buscar...',hintStyle:TextStyle(color:AppColors.textHint,fontSize:13),
                prefixIcon:Icon(Icons.search_rounded,size:17,color:AppColors.iconInactive),
                border:InputBorder.none,isDense:true,contentPadding:EdgeInsets.symmetric(vertical:12)))),
          const SizedBox(height:8),
          const Text('Tipo de proceso',style:TextStyle(color:AppColors.textSecondary,fontSize:13,fontWeight:FontWeight.w500)),
          const SizedBox(height:6),
          Container(height:40,decoration:BoxDecoration(color:AppColors.surface,borderRadius:BorderRadius.circular(10),border:Border.all(color:AppColors.cardBorder))),
          const SizedBox(height:12),
          _isMensual ? _buildMonth() : _buildWeek(),
          const SizedBox(height:18),
          _buildVencimientos(),
          const SizedBox(height:24),
        ])),
      ])),
    );
  }

  Widget _buildMonth() {
    final first=DateTime(_month.year,_month.month,1);
    final last=DateTime(_month.year,_month.month+1,0);
    final off=(first.weekday-1)%7;
    final rows=((off+last.day)/7).ceil();
    final today=DateTime.now();
    return _Card(child:Column(children:[
      Padding(padding:const EdgeInsets.fromLTRB(16,16,16,8),
        child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
          GestureDetector(onTap:()=>setState(()=>_month=DateTime(_month.year,_month.month-1)),
            child:const Icon(Icons.chevron_left_rounded,color:AppColors.textSecondary,size:22)),
          Column(children:[
            Text(_mn[_month.month],style:const TextStyle(color:AppColors.textPrimary,fontSize:16,fontWeight:FontWeight.w700)),
            Text('${_month.year}',style:const TextStyle(color:AppColors.textSecondary,fontSize:11)),
          ]),
          GestureDetector(onTap:()=>setState(()=>_month=DateTime(_month.year,_month.month+1)),
            child:const Icon(Icons.chevron_right_rounded,color:AppColors.textSecondary,size:22)),
        ])),
      Padding(padding:const EdgeInsets.symmetric(horizontal:8),
        child:Row(mainAxisAlignment:MainAxisAlignment.spaceAround,
          children:['LU','MA','MI','JU','VI','SA','DO'].map((d)=>SizedBox(width:36,
            child:Text(d,textAlign:TextAlign.center,style:const TextStyle(color:AppColors.textSecondary,fontSize:10,fontWeight:FontWeight.w700)))).toList())),
      const SizedBox(height:6),
      Padding(padding:const EdgeInsets.fromLTRB(8,0,8,14),
        child:Column(children:List.generate(rows,(row)=>Row(
          mainAxisAlignment:MainAxisAlignment.spaceAround,
          children:List.generate(7,(col){
            final day=row*7+col-off+1;
            if(day<1||day>last.day) return const SizedBox(width:36,height:42);
            final date=DateTime(_month.year,_month.month,day);
            final isT=_same(date,today); final isS=_selected!=null&&_same(date,_selected!);
            final isW=col>=5; final evs=_ev(date);
            return GestureDetector(onTap:()=>setState(()=>_selected=date),
              child:SizedBox(width:36,height:42,child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
                AnimatedContainer(duration:const Duration(milliseconds:150),width:30,height:30,
                  decoration:BoxDecoration(
                    color:isS?AppColors.primary:isT?AppColors.primarySoft:Colors.transparent,
                    shape:BoxShape.circle),
                  child:Center(child:Text('$day',style:TextStyle(
                    color:isS?Colors.white:isT?AppColors.primary:isW?AppColors.primary.withAlpha(140):AppColors.textPrimary,
                    fontSize:13,fontWeight:isT||isS?FontWeight.w700:FontWeight.w500)))),
                if(evs.isNotEmpty)
                  Row(mainAxisAlignment:MainAxisAlignment.center,children:evs.take(3).map((e)=>Container(
                    width:5,height:5,margin:const EdgeInsets.only(top:1,left:1),
                    decoration:BoxDecoration(color:e.color,shape:BoxShape.circle))).toList())
                else const SizedBox(height:6),
              ])));
          }))))),
    ]));
  }

  Widget _buildWeek() {
    final today=DateTime.now();
    final days=List.generate(7,(i)=>_weekStart.add(Duration(days:i)));
    return _Card(child:Column(children:[
      Padding(padding:const EdgeInsets.fromLTRB(16,16,16,8),
        child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
          GestureDetector(onTap:()=>setState(()=>_weekStart=_weekStart.subtract(const Duration(days:7))),
            child:const Icon(Icons.chevron_left_rounded,color:AppColors.textSecondary,size:22)),
          Column(children:[
            Text('${_wd[_weekStart.weekday-1]} ${_weekStart.day} — ${_wd[days.last.weekday-1]} ${days.last.day} ${_mn[_weekStart.month]}',
              style:const TextStyle(color:AppColors.textPrimary,fontSize:13,fontWeight:FontWeight.w700)),
            Text('${_weekStart.year}',style:const TextStyle(color:AppColors.textSecondary,fontSize:11)),
          ]),
          GestureDetector(onTap:()=>setState(()=>_weekStart=_weekStart.add(const Duration(days:7))),
            child:const Icon(Icons.chevron_right_rounded,color:AppColors.textSecondary,size:22)),
        ])),
      Padding(padding:const EdgeInsets.fromLTRB(8,0,8,16),
        child:Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:days.map((date){
          final isT=_same(date,today); final isS=_selected!=null&&_same(date,_selected!);
          final evs=_ev(date);
          return GestureDetector(onTap:()=>setState(()=>_selected=date),
            child:SizedBox(width:42,child:Column(children:[
              Text(_wd[date.weekday-1],style:const TextStyle(color:AppColors.textSecondary,fontSize:10,fontWeight:FontWeight.w600)),
              const SizedBox(height:4),
              AnimatedContainer(duration:const Duration(milliseconds:150),width:34,height:34,
                decoration:BoxDecoration(color:isS?AppColors.primary:isT?AppColors.primarySoft:Colors.transparent,shape:BoxShape.circle),
                child:Center(child:Text('${date.day}',style:TextStyle(
                  color:isS?Colors.white:isT?AppColors.primary:AppColors.textPrimary,
                  fontSize:14,fontWeight:isT||isS?FontWeight.w700:FontWeight.w500)))),
              const SizedBox(height:4),
              ...evs.map((e)=>Container(margin:const EdgeInsets.only(bottom:2),
                padding:const EdgeInsets.symmetric(horizontal:2,vertical:2),
                decoration:BoxDecoration(color:e.color.withAlpha(30),borderRadius:BorderRadius.circular(4)),
                child:Text(e.title,style:TextStyle(color:e.color,fontSize:8,fontWeight:FontWeight.w600),maxLines:1,overflow:TextOverflow.ellipsis))),
            ])));
        }).toList())),
    ]));
  }

  Widget _buildVencimientos() {
    final list=[
      _CalEvent(title:'Inicio de producción',date:DateTime(2025,12,18),color:AppColors.primary),
      _CalEvent(title:'Control de calidad',  date:DateTime(2025,12,23),color:const Color(0xFF6B7280)),
      _CalEvent(title:'Fecha de entrega',    date:DateTime(2025,12,30),color:const Color(0xFF34C759)),
    ];
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('Próximos vencimientos',style:TextStyle(color:AppColors.textPrimary,fontSize:15,fontWeight:FontWeight.w700)),
      const SizedBox(height:10),
      ...list.asMap().entries.map((en){
        final ev=en.value;
        return TweenAnimationBuilder<double>(
          tween:Tween(begin:0,end:1), duration:Duration(milliseconds:300+en.key*90), curve:Curves.easeOutCubic,
          builder:(_,v,child)=>Opacity(opacity:v,child:Transform.translate(offset:Offset(0,(1-v)*10),child:child)),
          child:Container(margin:const EdgeInsets.only(bottom:8),
            padding:const EdgeInsets.symmetric(horizontal:16,vertical:14),
            decoration:BoxDecoration(color:ev.color.withAlpha(20),borderRadius:BorderRadius.circular(14),
              border:Border.all(color:ev.color.withAlpha(40),width:0.8)),
            child:Row(children:[
              Expanded(child:Text(ev.title,style:TextStyle(color:ev.color,fontSize:13,fontWeight:FontWeight.w600))),
              Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:5),
                decoration:BoxDecoration(color:ev.color.withAlpha(25),borderRadius:BorderRadius.circular(20)),
                child:Text('${ev.date.day} ${_ma[ev.date.month]}',
                  style:TextStyle(color:ev.color,fontSize:12,fontWeight:FontWeight.w700))),
            ])));
      }),
    ]);
  }
}

class _Card extends StatelessWidget {
  final Widget child; const _Card({required this.child});
  @override Widget build(BuildContext context) => Container(
    decoration:BoxDecoration(color:AppColors.surface,borderRadius:BorderRadius.circular(16),
      border:Border.all(color:AppColors.cardBorder),
      boxShadow:[BoxShadow(color:Colors.black.withAlpha(8),blurRadius:12,offset:const Offset(0,3))]),
    child:child);
}

class _Btn extends StatelessWidget {
  final String label; final bool active; final VoidCallback onTap;
  const _Btn({required this.label, required this.active, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(onTap:onTap,
    child:AnimatedContainer(duration:const Duration(milliseconds:220),
      padding:const EdgeInsets.symmetric(vertical:11),
      decoration:BoxDecoration(color:active?AppColors.primary:AppColors.surface,
        borderRadius:BorderRadius.circular(12),
        border:Border.all(color:active?AppColors.primary:AppColors.cardBorder),
        boxShadow:active?[BoxShadow(color:AppColors.primary.withAlpha(70),blurRadius:8,offset:const Offset(0,3))]:null),
      child:Text(label,textAlign:TextAlign.center,
        style:TextStyle(color:active?Colors.white:AppColors.textSecondary,fontSize:13,fontWeight:FontWeight.w600))));
}
