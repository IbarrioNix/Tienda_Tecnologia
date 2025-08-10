class Producto {
  final int? id;                    // ✅ Nullable - null al crear
  final String nombre;
  final String marca;
  final String categoria;
  final String? modelo;             // ✅ Nullable - opcional
  final double precioVenta;
  final double precioCompra;
  final int stock;
  final int stockMinimo;
  final String? descripcion;        // ✅ Nullable - opcional
  final bool activo;
  final DateTime createdAt;

  Producto({
    this.id,                        // ✅ Sin required
    required this.nombre,
    required this.marca,
    required this.categoria,
    this.modelo,                    // ✅ Sin required
    required this.precioVenta,
    required this.precioCompra,
    required this.stock,
    required this.stockMinimo,
    this.descripcion,               // ✅ Sin required
    required this.activo,
    required this.createdAt,
  });

  // ✅ fromJson() MEJORADO - Maneja nulls
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      marca: json['marca'] ?? '',
      categoria: json['categoria'] ?? '',
      modelo: json['modelo'],                         // ✅ Puede ser null
      precioVenta: double.parse(json['precio_venta'].toString()),
      precioCompra: double.parse(json['precio_compra'].toString()),
      stock: json['stock'] ?? 0,
      stockMinimo: json['stock_minimo'] ?? 0,
      descripcion: json['descripcion'],              // ✅ Puede ser null
      activo: json['activo'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

}