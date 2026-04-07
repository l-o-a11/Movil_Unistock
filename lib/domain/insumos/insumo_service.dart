import 'insumo.dart';

class InsumoService {
  Future<List<Insumo>> getInsumos() async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Reemplaza con tu llamada HTTP real:
    // final res = await http.get(Uri.parse('https://tu-api.com/insumos'));
    // final List data = jsonDecode(res.body);
    // return data.map((e) => Insumo.fromJson(e)).toList();

    return const [
      Insumo(id: 1, numero: 1045, nombre: 'Flete entrega escarapela', categoria: 'Tela',      stock: 100, unidad: 'm', activo: true),
      Insumo(id: 2, numero: 1046, nombre: 'Hilo poliéster HP120',     categoria: 'Hilo',      stock: 72,  unidad: 'm', activo: true),
      Insumo(id: 3, numero: 1204, nombre: 'Cierre metálico',          categoria: 'Accesorio', stock: 0,   unidad: 'u', activo: false),
    ];
  }
}