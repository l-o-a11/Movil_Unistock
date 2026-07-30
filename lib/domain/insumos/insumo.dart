/// Propiedad dinámica de un insumo.
///
/// Forma real del backend (`SupplyModel.propiedadSchema`):
/// `{ clave: "color", label: "Color", valor: "Rojo" }` — el nombre a
/// mostrar ya viene en `label`, no requiere ningún catálogo/lookup aparte.
class PropiedadInsumo {
  final String clave;
  final String label;
  final String valor;

  const PropiedadInsumo({
    required this.clave,
    required this.label,
    required this.valor,
  });

  factory PropiedadInsumo.fromJson(Map<String, dynamic> json) => PropiedadInsumo(
    clave: json['clave']?.toString() ?? '',
    label: json['label']?.toString() ?? '',
    valor: json['valor']?.toString() ?? '',
  );
}

class Insumo {
  final String id;
  final String nombre;
  final String categoriaId;
  // Nombre de la categoría: el backend NO popula `categoria` (llega como
  // ObjectId plano), así que esto se resuelve aparte en [InsumoService]
  // consultando `/insumos/catalogos/categorias` y se inyecta con [copyWith].
  final String? categoriaNombre;
  final int stock;
  final double valorMedida;
  // Abreviatura tal cual la manda el backend (ej. "kg", "und", "m").
  final String medidaAbrev;
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
    required this.medidaAbrev,
    required this.estado,
    this.image,
    this.propiedades = const [],
  });

  // Catálogo de medidas predeterminadas del backend
  // (supplyController.js → MEDIDAS_PREDETERMINADAS). Traduce la abreviatura
  // a un nombre legible; si no está en el catálogo, se muestra la
  // abreviatura tal cual.
  static const _medidasLabel = {
    'kg': 'Kilogramo',
    'g': 'Gramo',
    'mg': 'Miligramo',
    'l': 'Litro',
    'ml': 'Mililitro',
    'm': 'Metro',
    'cm': 'Centímetro',
    'mm': 'Milímetro',
    'm2': 'Metro cuadrado',
    'm3': 'Metro cúbico',
    'und': 'Unidad',
    'par': 'Par',
    'cja': 'Caja',
    'rl': 'Rollo',
    'blt': 'Bulto',
  };

  String get categoria => categoriaNombre ?? 'Sin categoría';

  String get medida => _medidasLabel[medidaAbrev] ?? medidaAbrev;

  bool get isActivo => estado;
  String get estadoLabel => estado ? 'Activo' : 'Inactivo';

  /// Nombre a mostrar para una propiedad dinámica del insumo.
  String propiedadNombre(PropiedadInsumo p) =>
      p.label.isNotEmpty ? p.label : p.clave;

  Insumo copyWith({String? categoriaNombre}) => Insumo(
    id: id,
    nombre: nombre,
    categoriaId: categoriaId,
    categoriaNombre: categoriaNombre ?? this.categoriaNombre,
    stock: stock,
    valorMedida: valorMedida,
    medidaAbrev: medidaAbrev,
    estado: estado,
    image: image,
    propiedades: propiedades,
  );

  /// Construye un [Insumo] a partir del JSON devuelto por el backend real
  /// (`GET /api/insumos`).
  ///
  /// `categoria` llega como un ObjectId plano (no viene poblado por el
  /// backend), así que aquí solo se guarda el id — el nombre se resuelve
  /// después en [InsumoService] con el catálogo de categorías.
  factory Insumo.fromJson(Map<String, dynamic> json) {
    final rawCategoria = json['categoria'];
    String categoriaId = '';
    String? categoriaNombre;
    if (rawCategoria is Map) {
      // Por si en el futuro el backend empieza a popularla.
      categoriaId = (rawCategoria['_id'] ?? rawCategoria['id'] ?? '').toString();
      categoriaNombre = rawCategoria['nombre']?.toString();
    } else if (rawCategoria != null) {
      categoriaId = rawCategoria.toString();
    }

    // ── Estado: puede venir como 'estado' (bool) o 'activo' ───────────────
    final rawEstado = json['estado'] ?? json['activo'];
    final estado = rawEstado is bool
        ? rawEstado
        : (rawEstado?.toString().toLowerCase() == 'true' ||
            rawEstado?.toString().toLowerCase() == 'activo' ||
            rawEstado == null); // si no viene el campo, se asume activo

    // ── Imagen: campo real es `imagen` (URL de Cloudinary) ─────────────────
    final rawImage = json['imagen'] ?? json['image'] ?? json['imageUrl'];
    final image = rawImage is Map
        ? (rawImage['url'] ?? rawImage['secure_url'])?.toString()
        : rawImage?.toString();

    return Insumo(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      nombre: json['nombre']?.toString() ?? '',
      categoriaId: categoriaId,
      categoriaNombre: categoriaNombre,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      // Campo real del backend es `valor_medida` (snake_case).
      valorMedida:
          (json['valor_medida'] ?? json['valorMedida']) is num
              ? ((json['valor_medida'] ?? json['valorMedida']) as num).toDouble()
              : 0,
      medidaAbrev: json['medida']?.toString() ?? '',
      estado: estado,
      image: (image != null && image.isNotEmpty) ? image : null,
      propiedades: (json['propiedades'] as List<dynamic>? ?? [])
          .map((e) => PropiedadInsumo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
