// Modelos para Compras (órdenes)

// ─── Modelos de Compras ───────────────────────────────────────────────────

class CompraDetalle {
  final int id;
  final String nombre;
  final int cantidad;
  final double costoUnitario;
  final double costo;

  const CompraDetalle({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.costoUnitario,
    required this.costo,
  });

  factory CompraDetalle.fromJson(Map<String, dynamic> json) => CompraDetalle(
    id: json['id'] as int,
    nombre: json['nombre']?.toString() ?? '',
    cantidad: json['cantidad'] as int,
    costoUnitario: (json['costoUnitario'] as num).toDouble(),
    costo: (json['costo'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'cantidad': cantidad,
    'costoUnitario': costoUnitario,
    'costo': costo,
  };
}

class Compra {
  final int id;
  final String numeroFactura;
  final int proveedorId;
  final String proveedor;
  final String fecha; // formato YYYY-MM-DD
  final String observaciones;
  final double costoTotal;
  final bool anulada;
  final List<CompraDetalle> detalles;

  const Compra({
    required this.id,
    required this.numeroFactura,
    required this.proveedorId,
    required this.proveedor,
    required this.fecha,
    required this.observaciones,
    required this.costoTotal,
    required this.anulada,
    this.detalles = const [],
  });

  factory Compra.fromJson(Map<String, dynamic> json) => Compra(
    id: json['id'] as int,
    numeroFactura: json['numeroFactura']?.toString() ?? '',
    proveedorId: json['proveedorId'] as int,
    proveedor: json['proveedor']?.toString() ?? '',
    fecha: json['fecha']?.toString() ?? '',
    observaciones: json['observaciones']?.toString() ?? '',
    costoTotal: (json['costoTotal'] as num).toDouble(),
    anulada: json['anulada'] as bool,
    detalles: (json['detalles'] as List<dynamic>? ?? [])
        .map((e) => CompraDetalle.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'numeroFactura': numeroFactura,
    'proveedorId': proveedorId,
    'proveedor': proveedor,
    'fecha': fecha,
    'observaciones': observaciones,
    'costoTotal': costoTotal,
    'anulada': anulada,
    'detalles': detalles.map((d) => d.toJson()).toList(),
  };
}

// Datos iniciales de ejemplo
const INITIAL_SHOPPINGS = [
  Compra(
    id: 1,
    numeroFactura: '1873',
    proveedorId: 1,
    proveedor: 'Compras Corseteros',
    fecha: '2025-12-10',
    observaciones: 'Compra para la orden x para la ref x',
    costoTotal: 13300.00,
    anulada: false,
    detalles: [
      CompraDetalle(
        id: 101,
        nombre: 'Tela Rosada',
        cantidad: 50,
        costoUnitario: 200.00,
        costo: 10000.00,
      ),
      CompraDetalle(
        id: 102,
        nombre: 'Hilos',
        cantidad: 100,
        costoUnitario: 3.00,
        costo: 300.00,
      ),
      CompraDetalle(
        id: 103,
        nombre: 'Botones',
        cantidad: 300,
        costoUnitario: 10.00,
        costo: 3000.00,
      ),
    ],
  ),
];
