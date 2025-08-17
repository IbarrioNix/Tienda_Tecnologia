import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/producto.dart';
import '../screens/home_screen.dart';
import '../widgets/carrito_panel.dart'; // ← NUEVA IMPORTACIÓN

/// 🛒 Obtener solo productos activos con stock > 0
Future<List<Producto>> obtenerProductosActivos() async {
  try {
    final response = await http.get(Uri.parse(ApiConfig.productosEndpoint));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> jsonData = jsonResponse['productos'];

      final List<Producto> todosProductos =
      jsonData.map((json) => Producto.fromJson(json)).toList();

      final List<Producto> productosActivos = todosProductos
          .where((producto) => producto.activo && producto.stock > 0)
          .toList();

      return productosActivos;
    } else {
      throw Exception('Error al cargar productos: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

// ❌ QUITADO: with TickerProviderStateMixin
class _VentasScreenState extends State<VentasScreen> {
  // 🎮 Control de UI
  bool isGridView = true;
  String searchQuery = '';
  String selectedCategory = 'Todos';

  // 📦 Datos
  List<Producto> allProductos = [];
  List<Producto> filteredProductos = [];

  // 🛒 Carrito - SOLO lo esencial
  final List<ItemCarrito> carrito = [];
  bool isPanelOpen = false;

  // ❌ ELIMINADAS: Variables del panel (_panelWidth, _isDragging, etc.)
  // ❌ ELIMINADAS: AnimationController y Animation

  // ❌ ELIMINADO: initState()
  // ❌ ELIMINADO: dispose()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              _buildFiltroBar(),
              _buildProductosArea(),
            ],
          ),

          // 🔄 REEMPLAZADO: _buildCarritoSlide() por CarritoPanel
          CarritoPanel(
            carrito: carrito,
            isPanelOpen: isPanelOpen,
            onTogglePanel: _togglePanel,
            onModificarCantidad: _modificarCantidadCarrito,
            onVaciarCarrito: _vaciarCarrito,
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        },
        icon: const Icon(Icons.navigate_before),
      ),
      title: Row(
        children: const [
          Icon(Icons.point_of_sale, color: Colors.white),
          SizedBox(width: 8),
          Text('Punto de Venta'),
        ],
      ),
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: _togglePanel,
              icon: const Icon(Icons.shopping_cart),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_getTotalItems()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFiltroBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border(
          bottom: BorderSide(color: Colors.green[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar productos para vender...',
                prefixIcon: Icon(Icons.search, color: Colors.green[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[600]!, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _filterProductos();
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[600]!, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: Colors.white,
              ),
              hint: const Text('Categorías'),
              items: _getCategorias(allProductos)
                  .map((categoria) => DropdownMenuItem(
                value: categoria,
                child: Text(categoria),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value ?? 'Todos';
                  _filterProductos();
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.green[600],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                setState(() => isGridView = !isGridView);
              },
              icon: Icon(
                isGridView ? Icons.view_list : Icons.view_module,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductosContent() {
    if (!_getCategorias(allProductos).contains(selectedCategory)) {
      selectedCategory = 'Todos';
    }

    if (filteredProductos.isEmpty &&
        searchQuery.isEmpty &&
        selectedCategory == 'Todos') {
      filteredProductos = allProductos;
    }

    final groupedProductos = _groupProductosByCategory(filteredProductos);

    if (filteredProductos.isEmpty) {
      return _buildEmptyResults();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupedProductos.entries.map((entry) {
          final String categoria = entry.key;
          final List<Producto> productos = entry.value;
          return _buildCategorySection(categoria, productos);
        }).toList(),
      ),
    );
  }

  Widget _buildProductosArea() {
    return Expanded(
      child: allProductos.isEmpty
          ? FutureBuilder<List<Producto>>(
        future: obtenerProductosActivos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoading();
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          if (snapshot.hasData) {
            allProductos = snapshot.data!; // ← Guardamos en allProductos
            return _buildProductosContent();
          }

          return const Center(
            child: Text('No hay productos disponibles'),
          );
        },
      )
          : _buildProductosContent(), // ← Usar productos cacheados
    );
  }

  Widget _buildCategorySection(String categoria, List<Producto> productos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Icon(Icons.category, color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              Text(
                categoria,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[300]!),
                ),
                child: Text(
                  '${productos.length} productos',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
        ),
        isGridView
            ? _buildCategoryGrid(productos)
            : _buildCategoryList(productos),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCategoryGrid(List<Producto> productos) {
    final width = MediaQuery.of(context).size.width;
    final cross = width > 1200 ? 4 : 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cross,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: productos.length,
        itemBuilder: (context, index) {
          return _buildProductCard(productos[index]);
        },
      ),
    );
  }

  Widget _buildCategoryList(List<Producto> productos) {
    return Column(
      children: productos.map((producto) => _buildProductListItem(producto)).toList(),
    );
  }

  Widget _buildProductCard(Producto producto) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.green[100]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Text(
                producto.categoria,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${producto.marca} ${producto.modelo ?? ''}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.inventory, size: 14, color: Colors.orange[600]),
                      Text(' ${producto.stock}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${producto.precioVenta.toStringAsFixed(2)} MXN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _agregarAlCarrito(producto),
                      icon: const Icon(Icons.add_shopping_cart, size: 16),
                      label: const Text('Agregar', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListItem(Producto producto) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Text(
            producto.nombre.isNotEmpty ? producto.nombre[0].toUpperCase() : '?',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${producto.marca} - Stock: ${producto.stock}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${producto.precioVenta.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _agregarAlCarrito(producto),
              icon: const Icon(Icons.add_shopping_cart, size: 16),
              label: const Text('Agregar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 36),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _filterProductos() {
    filteredProductos = allProductos.where((producto) {
      final q = searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          producto.nombre.toLowerCase().contains(q) ||
          producto.marca.toLowerCase().contains(q) ||
          (producto.modelo?.toLowerCase() ?? '').contains(q);

      final matchesCategory =
          selectedCategory == 'Todos' || producto.categoria == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> _getCategorias(List<Producto> productos) {
    final List<String> categorias = ['Todos'];
    final Set<String> categoriasUnicas = productos.map((p) => p.categoria).toSet();
    categorias.addAll(categoriasUnicas.toList()..sort());
    return categorias;
  }

  Map<String, List<Producto>> _groupProductosByCategory(List<Producto> productos) {
    final Map<String, List<Producto>> grouped = {};
    for (var producto in productos) {
      grouped.putIfAbsent(producto.categoria, () => []).add(producto);
    }
    return grouped;
  }

  int _getTotalItems() {
    return carrito.fold(0, (sum, item) => sum + item.cantidad);
  }

  void _agregarAlCarrito(Producto producto) {

    setState(() {
      final existingIndex =
      carrito.indexWhere((item) => item.producto.id == producto.id);

      if (existingIndex != -1) {
        carrito[existingIndex].cantidad++;
        carrito[existingIndex].actualizarSubtotal();
      } else {
        carrito.add(ItemCarrito(producto: producto));
      }

      if (!isPanelOpen) {
        isPanelOpen = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${producto.nombre} agregado al carrito'),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // 🆕 NUEVO MÉTODO: Comunicación con CarritoPanel
  void _modificarCantidadCarrito(ItemCarrito item, int cambio) {
    setState(() {
      if (cambio > 0 && item.cantidad < item.producto.stock) {
        item.cantidad++;
      } else if (cambio < 0) {
        if (item.cantidad > 1) {
          item.cantidad--;
        } else {
          carrito.remove(item);
        }
      }
      item.actualizarSubtotal();
    });
  }

  void _vaciarCarrito() {
    setState(() {
      carrito.clear(); // Limpia toda la lista
    });

    _recargarProductos();

    // Mostrar mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Carrito vaciado'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _recargarProductos() async {
    try{
      final nuevosProductos = await obtenerProductosActivos();
      setState(() {
        allProductos = nuevosProductos;
        filteredProductos = nuevosProductos;
      });
    }catch(e){
      print('Error al obtener productos');
    }
  }

  // 🔄 SIMPLIFICADO: _togglePanel (sin animaciones)
  void _togglePanel() {
    setState(() {
      isPanelOpen = !isPanelOpen;
    });
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.green),
          const SizedBox(height: 16),
          Text('Cargando productos...', style: TextStyle(color: Colors.green[700])),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No se encontraron productos',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otra búsqueda o categoría',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}