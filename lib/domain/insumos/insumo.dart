class PropiedadInsumo {
  final int id;
  final int propiedadId;
  final String valor;

  const PropiedadInsumo({
    required this.id,
    required this.propiedadId,
    required this.valor,
  });

  factory PropiedadInsumo.fromJson(Map<String, dynamic> json) =>
      PropiedadInsumo(
        id: json['id'] as int,
        propiedadId: json['propiedadId'] as int,
        valor: json['valor']?.toString() ?? '',
      );
}

class Insumo {
  final int id;
  final String nombre;
  final int categoriaId;
  final int stock;
  final double valorMedida;
  final int medidaId;
  final bool estado;
  final String? image;
  final List<PropiedadInsumo> propiedades;

  const Insumo({
    required this.id,
    required this.nombre,
    required this.categoriaId,
    required this.stock,
    required this.valorMedida,
    required this.medidaId,
    required this.estado,
    this.image,
    this.propiedades = const [],
  });

  // ─── Lookup helpers ────────────────────────────────────────────────────────

  static const _categorias = {
    1: 'Telas',
    2: 'Hilos',
    3: 'Cierres',
    4: 'Elásticos',
    5: 'Encajes y pasamanería',
    6: 'Entretelas',
    7: 'Botones',
    8: 'Velcros',
  };

  static const _medidas = {
    1: 'Unidad',
    2: 'Metro',
    3: 'Rollo',
    4: 'Paquete',
    5: 'Caja',
    6: 'Litro',
  };

  static const _propiedadesNombres = {
    1: 'Color',
    2: 'Tamaño',
    3: 'Elasticidad',
    4: 'Diseño',
    5: 'Material',
  };

  String get categoria => _categorias[categoriaId] ?? 'Categoría $categoriaId';
  String get medida => _medidas[medidaId] ?? 'Medida $medidaId';
  bool get isActivo => estado;
  String get estadoLabel => estado ? 'Activo' : 'Inactivo';

  String propiedadNombre(int propiedadId) =>
      _propiedadesNombres[propiedadId] ?? 'Propiedad $propiedadId';

  factory Insumo.fromJson(Map<String, dynamic> json) => Insumo(
        id: json['id'] as int,
        nombre: json['nombre']?.toString() ?? '',
        categoriaId: json['categoriaId'] as int,
        stock: json['stock'] as int,
        valorMedida: (json['valorMedida'] as num).toDouble(),
        medidaId: json['medidaId'] as int,
        estado: json['estado'] as bool,
        image: json['image']?.toString(),
        propiedades: (json['propiedades'] as List<dynamic>? ?? [])
            .map((e) => PropiedadInsumo.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}