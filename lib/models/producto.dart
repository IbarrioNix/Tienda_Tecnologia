class Producto {

  final int id;
  final String nombre;
  final String marca;
  final String categoria;
  final String modelo;
  final double precioVenta;
  final double precioCompra;
  final int stock;
  final int stockMinimo;
  final String descripcion;
  final bool activo;
  final DateTime createdAt;

  Producto({
    required this.id,
    required this.nombre,
    required this.marca,
    required this.categoria,
    required this.modelo,
    required this.precioVenta,
    required this.precioCompra,
    required this.stock,
    required this.stockMinimo,
    required this.descripcion,
    required this.activo,
    required this.createdAt,
  });

// Convertir JSON a objeto Producto
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'],
      marca: json['marca'],
      categoria: json['categoria'],
      modelo: json['modelo'],
      precioVenta: double.parse(json['precio_venta']),
      precioCompra: double.parse(json['precio_compra']),
      stock: json['stock'],
      stockMinimo: json['stock_minimo'],
      descripcion: json['descripcion'],
      activo: json['activo'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}