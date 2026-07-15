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
  final String id;
  final String nombre;
  final String categoriaId;
  // Nombre de la categoría si la API ya lo envía (populate / join). Si es
  // null, se usa el mapa local [_categorias] como respaldo (solo válido
  // para los datos de ejemplo).
  final String? categoriaNombre;
  final int stock;
  final double valorMedida;
  final String medidaId;
  final String? medidaNombre;
  final bool estado;
  final String? image;
  final List<PropiedadInsumo> propiedades;

  const Insumo({
    required this.id,
    required this.nombre,
    required this.categoriaId,
    this.categoriaNombre,
    required this.stock,
    required this.valorMedida,
    required this.medidaId,
    this.medidaNombre,
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

  String get categoria =>
      categoriaNombre ??
      _categorias[int.tryParse(categoriaId)] ??
      'Categoría $categoriaId';

  String get medida =>
      medidaNombre ?? _medidas[int.tryParse(medidaId)] ?? 'Medida $medidaId';

  bool get isActivo => estado;
  String get estadoLabel => estado ? 'Activo' : 'Inactivo';

  String propiedadNombre(int propiedadId) =>
      _propiedadesNombres[propiedadId] ?? 'Propiedad $propiedadId';

  /// Construye un [Insumo] a partir del JSON devuelto por el backend real
  /// (`GET /api/supplies`) o por los datos mock.
  ///
  /// Es tolerante a distintas formas de respuesta porque el backend puede
  /// enviar la categoría/medida como sub-documento poblado
  /// (`{ "_id": "...", "nombre": "..." }`) o como un id plano.
  factory Insumo.fromJson(Map<String, dynamic> json) {
    // ── Categoría: puede venir como objeto poblado o como id plano ──────
    final rawCategoria = json['categoria'] ?? json['categoriaId'];
    String categoriaId = '';
    String? categoriaNombre;
    if (rawCategoria is Map) {
      categoriaId = (rawCategoria['_id'] ?? rawCategoria['id'] ?? '').toString();
      categoriaNombre = rawCategoria['nombre']?.toString();
    } else if (rawCategoria != null) {
      categoriaId = rawCategoria.toString();
    }

    // ── Medida/unidad: idem ───────────────────────────────────────────────
    final rawMedida =
        json['unidadMedida'] ?? json['medida'] ?? json['medidaId'];
    String medidaId = '';
    String? medidaNombre;
    if (rawMedida is Map) {
      medidaId = (rawMedida['_id'] ?? rawMedida['id'] ?? '').toString();
      medidaNombre =
          (rawMedida['nombre'] ?? rawMedida['abreviatura'])?.toString();
    } else if (rawMedida != null) {
      medidaId = rawMedida.toString();
    }

    // ── Estado: puede venir como 'estado' (bool) o 'activo' ───────────────
    final rawEstado = json['estado'] ?? json['activo'];
    final estado = rawEstado is bool
        ? rawEstado
        : (rawEstado?.toString().toLowerCase() == 'true' ||
            rawEstado?.toString().toLowerCase() == 'activo' ||
            rawEstado == null); // si no viene el campo, se asume activo

    // ── Imagen: soporta string plano o { url } (p.ej. Cloudinary) ─────────
    final rawImage = json['image'] ?? json['imagen'] ?? json['imageUrl'];
    final image = rawImage is Map
        ? (rawImage['url'] ?? rawImage['secure_url'])?.toString()
        : rawImage?.toString();

    return Insumo(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      nombre: json['nombre']?.toString() ?? '',
      categoriaId: categoriaId,
      categoriaNombre: categoriaNombre,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      valorMedida: (json['valorMedida'] as num?)?.toDouble() ?? 0,
      medidaId: medidaId,
      medidaNombre: medidaNombre,
      estado: estado,
      image: (image != null && image.isNotEmpty) ? image : null,
      propiedades: (json['propiedades'] as List<dynamic>? ?? [])
          .map((e) => PropiedadInsumo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}