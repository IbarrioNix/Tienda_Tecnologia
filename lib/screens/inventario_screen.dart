import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../widgets/producto_dialog.dart';
import '../config/api_config.dart';
import '../screens/home_screen.dart';
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
    // Calcular ancho de tarjeta según pantalla
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth > 600 ? 180 : 140; // Desktop vs Mobile

    return SizedBox(
      height: screenWidth > 600 ? 220 : 180, // Altura adaptativa
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: productos.length,
        itemBuilder: (context, index) {
          Producto producto = productos[index];
          return Container(
            width: cardWidth, // Ancho adaptativo
            margin: EdgeInsets.only(right: 12),
            child: Card(
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image,
                        size: screenWidth > 600 ? 40 : 30, // Ícono adaptativo
                        color: Colors.grey[600],
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
                              fontSize: screenWidth > 600
                                  ? 14
                                  : 12, // Texto adaptativo
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '\$${producto.precioVenta}',
                            style: TextStyle(
                              color: Colors.green,
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
      // No expandirse infinito
      physics: NeverScrollableScrollPhysics(),
      // No scroll independiente
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: productos.length,
      itemBuilder: (context, index) {
        Producto producto = productos[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              color: Colors.grey[300],
              child: Icon(Icons.image, color: Colors.grey[600]),
            ),
            title: Text(
              producto.nombre,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${producto.marca} • ${producto.modelo}'),
                Text('${producto.categoria} • Stock: ${producto.stock}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${producto.precioVenta}',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isDesktop)
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _mostrarDialogEditar(producto),
                  ),
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
              (producto.modelo?.toLowerCase() ?? '').contains(searchQuery.toLowerCase()); // ✅ CORRECCIÓN

      bool matchesCategory =
          selectedCategory == 'Todos' || producto.categoria == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }


  List<String> _getCategorias(List<Producto> productos) {
    List<String> categorias = ['Todos'];  // ← ESTE "Todos" causa el problema
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
      builder: (context) => ProductoDialog(
        categorias: _getCategorias(allProductos),
      ),
    );

    if (nuevoProducto != null) {
      await _crearProductoEnAPI(nuevoProducto);
      setState(() {

      });
    }
  }

  void _mostrarDialogEditar(Producto producto) async {
    final Producto? productoEditado = await showDialog<Producto>(
      context: context,
      builder: (context) => ProductoDialog(
        producto: producto, // Pre-cargar datos existentes
        categorias: _getCategorias(allProductos),
      ),
    );

    if (productoEditado != null) {
      await _actualizarProductoEnAPI(productoEditado);
      setState(() {

      });
    }
  }

  Future<void> _crearProductoEnAPI (Producto producto) async{
    try{
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/productos'),
        headers: {
          'Content-Type': 'application/json',
        },
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

      if(response.statusCode == 201){
        print('Producto creado exitosamente');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto creado exitosamente'),
          backgroundColor: Colors.green),
        );
      }else{
        throw Exception('Error ${response.statusCode}');
      }
    }catch(e){
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:
        Text('Error: no se pudo crear'),
        backgroundColor: Colors.red,)
      );
    }
  }

  Future<void> _actualizarProductoEnAPI(Producto producto) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/productos/${producto.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
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
}
