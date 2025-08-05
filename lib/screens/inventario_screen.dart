import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Producto>> obtenerProductos() async {
  try {
    final response = await http.get(Uri.parse(ApiConfig.productosEndpoint));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> jsonData = jsonResponse['productos'];
      return jsonData.map((json) => Producto.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar productos: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error de conexion: $e');
  }
}

class InventarioScreen extends StatefulWidget {
  @override
  _InventarioScreenState createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inventario'), backgroundColor: Colors.blue),
      body: FutureBuilder<List<Producto>>(
        future: obtenerProductos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error:${snapshot.error}'));
          }
          if (snapshot.hasData) {
            List<Producto> productos = snapshot.data!;
            return ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                Producto producto = productos[index];
                return Card(
                  child: ListTile(
                    title: Text(producto.nombre),
                    subtitle: Text(
                      '${producto.marca} - Stock: ${producto.stock}',
                    ),
                    trailing: Text('\$ ${producto.precioVenta}'),
                  ),
                );
              },
            );
          }
          return Center(child: Text('No hay datos'));
        },
      ),
    );
  }
}
