import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../widgets/producto_dialog.dart';
import '../config/api_config.dart';
import '../screens/home_screen.dart';
import 'package:http/http.dart' as http;
import '../widgets/reabastecimiento_dialog.dart';

Future<List<Producto>> obtenerProductos() async {
  try {
    final response = await http.get(Uri.parse(ApiConfig.productosEndpoint));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> jsonData = jsonResponse['productos'];

      // 🔍 DEBUG: Imprimir todos los productos que llegan del backend
      print('🔍 TOTAL PRODUCTOS RECIBIDOS: ${jsonData.length}');
      for (var producto in jsonData) {
        print(
          '🔍 Producto: ${producto['nombre']} - Activo: ${producto['activo']}',
        );
      }

      List<Producto> productos = jsonData
          .map((json) => Producto.fromJson(json))
          .toList();

      // 🔍 DEBUG: Verificar productos después de mapear
      int activos = productos.where((p) => p.activo == true).length;
      int inactivos = productos.where((p) => p.activo == false).length;
      print('🔍 PRODUCTOS MAPEADOS: $activos activos, $inactivos inactivos');

      return productos;
    } else {
      throw Exception('Error al cargar productos: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error de conexion: $e');
  }
}

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  _InventarioScreenState createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  bool isGridView = true;

  String searchQuery = '';
  String selectedCategory = 'Todos';

  List<Producto> allProductos = [];
  List<Producto> filteredProductos = [];

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
          icon: Icon(Icons.navigate_before),
        ),
        title: Text('Inventario'),
        backgroundColor: Colors.blue,
        actions: [
          if (isDesktop)
            IconButton(
              onPressed: () {
                _mostrarDialogCrear();
              },
              icon: Icon(Icons.add),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        _filterProductos();
                      });
                    },
                  ),
                ),
                SizedBox(width: 12),

                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    hint: Text('Categorías'),
                    items: _getCategorias(allProductos)
                        .map(
                          (categoria) => DropdownMenuItem(
                            value: categoria,
                            child: Text(categoria),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value ?? 'Todos';
                        _filterProductos();
                      });
                    },
                  ),
                ),
                SizedBox(width: 12),

                IconButton(
                  onPressed: () {
                    setState(() {
                      isGridView = !isGridView;
                    });
                  },
                  icon: Icon(isGridView ? Icons.view_list : Icons.view_module),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Producto>>(
              future: obtenerProductos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error:${snapshot.error}'));
                }
                if (snapshot.hasData) {
                  allProductos = snapshot.data!;

                  if (!_getCategorias(
                    allProductos,
                  ).contains(selectedCategory)) {
                    selectedCategory = 'Todos';
                  }

                  if (filteredProductos.isEmpty &&
                      searchQuery.isEmpty &&
                      selectedCategory == 'Todos') {
                    filteredProductos = allProductos;
                  }

                  Map<String, List<Producto>> groupedProductos =
                      _groupProductosByCategory(filteredProductos);

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: groupedProductos.entries.map((entry) {
                        String categoria = entry.key;
                        List<Producto> productos = entry.value;

                        return _buildCategorySection(categoria, productos);
                      }).toList(),
                    ),
                  );
                }
                return Center(child: Text('No hay datos'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(List<Producto> productos) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth > 600 ? 180 : 140;

    return SizedBox(
      height: screenWidth > 600 ? 220 : 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: productos.length,
        itemBuilder: (context, index) {
          Producto producto = productos[index];
          bool isActive = producto.activo;

          return Container(
            width: cardWidth,
            margin: EdgeInsets.only(right: 12),
            child: Card(
              elevation: isActive ? 4 : 1,
              child: Stack(
                children: [
                  if (!isActive)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          color: isActive ? Colors.grey[300] : Colors.grey[400],
                          child: Icon(
                            Icons.image,
                            size: screenWidth > 600 ? 20 : 10,
                            color: isActive
                                ? Colors.grey[600]
                                : Colors.grey[500],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                producto.nombre,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth > 600 ? 14 : 12,
                                  color: isActive
                                      ? Colors.black
                                      : Colors.grey[600],
                                  decoration: isActive
                                      ? TextDecoration.none
                                      : TextDecoration.lineThrough,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '\$${producto.precioVenta}',
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.green
                                      : Colors.grey[500],
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth > 600 ? 13 : 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (!isActive)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'INACTIVO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  if (isActive)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(Icons.check, color: Colors.white, size: 12),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryList(List<Producto> productos) {
    bool isDesktop = MediaQuery.of(context).size.width > 600;
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: productos.length,
      itemBuilder: (context, index) {
        Producto producto = productos[index];
        bool isActive = producto.activo;

        return Card(
          margin: EdgeInsets.only(bottom: 8.0),
          elevation: isActive ? 2 : 0.5,
          color: isActive ? Colors.white : Colors.grey[100],
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isActive ? Colors.grey[300] : Colors.grey[400],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.image,
                      color: isActive ? Colors.grey[600] : Colors.grey[500],
                    ),
                  ),
                  // 🚫 ICONO DE INACTIVO
                  if (!isActive)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.block, color: Colors.white, size: 10),
                      ),
                    ),
                ],
              ),
            ),
            title: Text(
              producto.nombre,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.black : Colors.grey[600],
                decoration: isActive
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${producto.marca} • ${producto.modelo ?? 'N/A'}',
                  style: TextStyle(
                    color: isActive ? Colors.grey[700] : Colors.grey[500],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${producto.categoria} • Stock: ${producto.stock}',
                      style: TextStyle(
                        color: isActive ? Colors.grey[700] : Colors.grey[500],
                      ),
                    ),
                    if (!isActive) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Text(
                          'INACTIVO',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${producto.precioVenta}',
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.grey[500],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isDesktop) ...[
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: isActive ? Colors.blue : Colors.grey[500],
                    ),
                    onPressed: () => _mostrarDialogEditar(producto),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.local_shipping_outlined,
                      color: isActive ? Colors.deepPurple : Colors.grey[500],
                    ),
                    onPressed: () => _mostrarDialogReabastecer(producto),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _filterProductos() {
    filteredProductos = allProductos.where((producto) {
      bool matchesSearch =
          searchQuery.isEmpty ||
          producto.nombre.toLowerCase().contains(searchQuery.toLowerCase()) ||
          producto.marca.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (producto.modelo?.toLowerCase() ?? '').contains(
            searchQuery.toLowerCase(),
          );

      bool matchesCategory =
          selectedCategory == 'Todos' || producto.categoria == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> _getCategorias(List<Producto> productos) {
    List<String> categorias = ['Todos'];
    Set<String> categoriasUnicas = productos.map((p) => p.categoria).toSet();
    categorias.addAll(categoriasUnicas.toList()..sort());
    return categorias;
  }

  Map<String, List<Producto>> _groupProductosByCategory(
    List<Producto> productos,
  ) {
    Map<String, List<Producto>> grouped = {};

    for (var producto in productos) {
      if (!grouped.containsKey(producto.categoria)) {
        grouped[producto.categoria] = [];
      }
      grouped[producto.categoria]!.add(producto);
    }

    return grouped;
  }

  Widget _buildCategorySection(String categoria, List<Producto> productos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '$categoria (${productos.length} productos)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ),

        isGridView
            ? _buildCategoryGrid(productos)
            : _buildCategoryList(productos),

        SizedBox(height: 16), // Separación entre categorías
      ],
    );
  }

  void _mostrarDialogCrear() async {
    final Producto? nuevoProducto = await showDialog<Producto>(
      context: context,
      builder: (context) =>
          ProductoDialog(categorias: _getCategorias(allProductos)),
    );

    if (nuevoProducto != null) {
      await _crearProductoEnAPI(nuevoProducto);
      setState(() {});
    }
  }

  void _mostrarDialogEditar(Producto producto) async {
    final Producto? productoEditado = await showDialog<Producto>(
      context: context,
      builder: (context) => ProductoDialog(
        producto: producto,
        categorias: _getCategorias(allProductos),
      ),
    );

    if (productoEditado != null) {
      await _actualizarProductoEnAPI(productoEditado);
      setState(() {});
    }
  }

  void _mostrarDialogReabastecer(Producto producto) async {
    final Map<String, dynamic>? reabastecimiento = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ReabastecimientoDialog(producto: producto),
    );

    if (reabastecimiento != null) {
      await _procesarReabastecimientoEnAPI(reabastecimiento);
      setState(() {}); // Recargar la lista
    }
  }

  Future<void> _crearProductoEnAPI(Producto producto) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/productos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': producto.nombre,
          'marca': producto.marca,
          'modelo': producto.modelo,
          'categoria': producto.categoria,
          'precio_venta': producto.precioVenta,
          'precio_compra': producto.precioCompra,
          'stock': producto.stock,
          'stock_minimo': producto.stockMinimo,
          'descripcion': producto.descripcion,
          'activo': producto.activo,
        }),
      );

      if (response.statusCode == 201) {
        print('Producto creado exitosamente');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: no se pudo crear'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _actualizarProductoEnAPI(Producto producto) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/productos/${producto.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': producto.nombre,
          'marca': producto.marca,
          'modelo': producto.modelo,
          'categoria': producto.categoria,
          'precio_venta': producto.precioVenta,
          'precio_compra': producto.precioCompra,
          'stock': producto.stock,
          'stock_minimo': producto.stockMinimo,
          'descripcion': producto.descripcion,
          'activo': producto.activo,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Producto actualizado exitosamente');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: No se pudo actualizar el producto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> _procesarReabastecimientoEnAPI(Map<String, dynamic> data) async {
    try {
      // DEBUG: Imprimir los datos que se van a enviar
      print('Datos a enviar: ${jsonEncode(data)}');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/reabastecimientos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      // DEBUG: Imprimir la respuesta del servidor
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${responseData['message']}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Mostrar el error específico del servidor
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${errorData['error'] ?? 'Error desconocido'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar reabastecimiento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
