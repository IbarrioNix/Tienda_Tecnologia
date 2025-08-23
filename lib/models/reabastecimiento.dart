import 'package:flutter/material.dart';

class Reabastecimiento {
  final int id;
  final int productoId;
  final String productoNombre;
  final String marca;
  final String? modelo;
  final int cantidadAgregada;
  final double costoTotal;
  final bool reabastecimiento;
  final bool devolucion;
  final bool ajusteManual;
  final String? proveedor;
  final String? notas;
  final DateTime createdAt;

  Reabastecimiento({
    required this.id,
    required this.productoId,
    required this.productoNombre,
    required this.marca,
    this.modelo,
    required this.cantidadAgregada,
    required this.costoTotal,
    required this.reabastecimiento,
    required this.devolucion,
    required this.ajusteManual,
    this.proveedor,
    this.notas,
    required this.createdAt,
  });

  factory Reabastecimiento.fromJson(Map<String, dynamic> json){
    return Reabastecimiento(
      id: json['id'],
      productoId: json['producto_id'],
      productoNombre: json['producto_nombre'] ?? 'Sin nombre',
      marca: json['marca'] ?? 'Sin marca',
      modelo: json['modelo'],
      cantidadAgregada: json['cantidad_agregada'],
      costoTotal: (json['costo_total'] ?? 0.0).toDouble(),
      reabastecimiento: json['reabastecimiento'] ?? false,
      devolucion: json['devolucion'] ?? false,
      ajusteManual: json['ajuste_manual'] ?? false,
      proveedor: json['proveedor'],
      notas: json['notas'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Convertir a JSON (por si necesitas enviar datos de vuelta al servidor)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto_id': productoId,
      'cantidad_agregada': cantidadAgregada,
      'costo_total': costoTotal,
      'reabastecimiento': reabastecimiento,
      'devolucion': devolucion,
      'ajuste_manual': ajusteManual,
      'proveedor': proveedor,
      'notas': notas,
    };
  }


  // Getters para la UI
  String get tipoDisplay {
    if (reabastecimiento) return 'Compra';
    if (devolucion) return 'Devolución';
    if (ajusteManual) return 'Ajuste Manual';
    return 'Desconocido';
  }

  String get tipoApi {
    if (reabastecimiento) return 'reabastecimiento';
    if (devolucion) return 'devolucion';
    if (ajusteManual) return 'ajuste_manual';
    return '';
  }

  Color get colorTipo {
    if (reabastecimiento) return Colors.purple;
    if (devolucion) return Colors.deepOrangeAccent;
    if (ajusteManual) return Colors.lightBlue;
    return Colors.grey;
  }

  IconData get iconoTipo {
    if (reabastecimiento) return Icons.shopping_cart;
    if (devolucion) return Icons.undo;
    if (ajusteManual) return Icons.tune;
    return Icons.help_outline;
  }

  // Calcular costo unitario
  double get costoUnitario {
    if (cantidadAgregada > 0 && costoTotal > 0) {
      return costoTotal / cantidadAgregada;
    }
    return 0.0;
  }

  // Información completa del producto
  String get productoCompleto {
    String resultado = productoNombre;
    if (marca.isNotEmpty && marca != 'Sin marca') {
      resultado += ' - $marca';
    }
    if (modelo != null && modelo!.isNotEmpty) {
      resultado += ' $modelo';
    }
    return resultado;
  }

  // Para debugging
  @override
  String toString() {
    return 'Reabastecimiento{id: $id, producto: $productoNombre, tipo: $tipoDisplay, cantidad: $cantidadAgregada}';
  }

  // Para comparaciones
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reabastecimiento && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

}
