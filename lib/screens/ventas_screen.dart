import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/producto.dart';
import '../screens/home_screen.dart';

/// 🧩 Item del carrito
class ItemCarrito {
  final Producto producto;
  int cantidad;
  double subtotal;

  ItemCarrito({
    required this.producto,
    this.cantidad = 1,
  }) : subtotal = producto.precioVenta * cantidad;

  void actualizarSubtotal() {
    subtotal = producto.precioVenta * cantidad;
  }
}

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

      // print('🛒 PRODUCTOS PARA VENTA: ${productosActivos.length}');
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

class _VentasScreenState extends State<VentasScreen>
    with TickerProviderStateMixin {
  // 🎮 Control de UI
  bool isGridView = true;
  String searchQuery = '';
  String selectedCategory = 'Todos';

  // 📦 Datos
  List<Producto> allProductos = [];
  List<Producto> filteredProductos = [];

  // 🛒 Carrito
  final List<ItemCarrito> carrito = [];
  double _panelWidth = 400.0;
  double _minPanelWidth = 280.0;
  double _maxPanelWidth = 600.0;
  bool _isDragging = false;

  // 🎬 Panel lateral (carrito)
  late AnimationController _panelController;
  late Animation<Offset> _panelAnimation;
  bool isPanelOpen = false;

  @override
  void initState() {
    super.initState();

    _panelController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 👉 El panel entra desde la derecha completamente (1,0) hasta su lugar (0,0)
    _panelAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _panelController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_){
      final screenWidth = MediaQuery.of(context).size.width;
      _maxPanelWidth = screenWidth * 0.8;
      _panelWidth = screenWidth * 0.35;
    });
  }

  @override
  void dispose() {
    _panelController.dispose();
    super.dispose();
  }

  // ========================
  // 🧱 Build
  // ========================
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
          _buildCarritoSlide(), // ← Panel deslizante corregido
        ],
      ),
    );
  }

  // ========================
  // 🧩 AppBar
  // ========================
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

  // ========================
  // 🔎 Barra de filtros
  // ========================
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
          // 🔍 Búsqueda
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
                contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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

          // 🏷️ Categorías
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
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

          // 🔄 Vista
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

  // ========================
  // 📦 Área de productos
  // ========================
  Widget _buildProductosArea() {
    return Expanded(
      child: FutureBuilder<List<Producto>>(
        future: obtenerProductosActivos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoading();
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          if (snapshot.hasData) {
            allProductos = snapshot.data!;

            // Validar categoría seleccionada
            if (!_getCategorias(allProductos).contains(selectedCategory)) {
              selectedCategory = 'Todos';
            }

            // Inicializar filtros la primera vez
            if (filteredProductos.isEmpty &&
                searchQuery.isEmpty &&
                selectedCategory == 'Todos') {
              filteredProductos = allProductos;
            }

            final groupedProductos =
            _groupProductosByCategory(filteredProductos);

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

          return const Center(
            child: Text('No hay productos disponibles'),
          );
        },
      ),
    );
  }

  // ========================
  // 🧾 Sección por categoría
  // ========================
  Widget _buildCategorySection(String categoria, List<Producto> productos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de categoría
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
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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

        // Grid o lista
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
      children:
      productos.map((producto) => _buildProductListItem(producto)).toList(),
    );
  }

  // ========================
  // 🧱 Cards/ListTiles de producto
  // ========================
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
          // Header con gradiente
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
                      Icon(Icons.inventory,
                          size: 14, color: Colors.orange[600]),
                      Text(' ${producto.stock}',
                          style: const TextStyle(fontSize: 12)),
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
                      label:
                      const Text('Agregar', style: TextStyle(fontSize: 12)),
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
            producto.nombre.isNotEmpty
                ? producto.nombre[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title:
        Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
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

  // ========================
  // 🧾 Panel del carrito (Slide)
  // ========================
  Widget _buildCarritoSlide() {
    return Stack(
      children: [
        Align(
      alignment: Alignment.centerRight,
      child: SlideTransition(
        position: _panelAnimation,
        child: SizedBox(
          width: _panelWidth,
          height: double.infinity,
          child: Row(
            children: [
              _buildResizeBar(),
              
              Expanded(child: _buildCarritoPanel()),
            ],
          ),
        ),
      ),
    ),
        if(!isPanelOpen) _buildCarritoTab(),
      ],
    );
  }

  Widget _buildCarritoTab() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.3,  // 30% desde arriba
      right: 0,
      child: GestureDetector(
        onTap: _togglePanel,
        child: Container(
          width: 60,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.green[600],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_cart,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 4),
              if (_getTotalItems() > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 8),
              const RotatedBox(
                quarterTurns: -1,  // Texto vertical
                child: Text(
                  'CARRITO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResizeBar() {
    return GestureDetector(
      onPanStart: (details) {
        setState(() => _isDragging = true);
      },
      onPanUpdate: (details) {
        setState(() {
          // Calcular nuevo ancho basado en el movimiento
          double newWidth = _panelWidth - details.delta.dx;

          // Aplicar límites
          newWidth = newWidth.clamp(_minPanelWidth, _maxPanelWidth);

          _panelWidth = newWidth;
        });
      },
      onPanEnd: (details) {
        setState(() => _isDragging = false);
      },
      child: Container(
        width: 8,
        decoration: BoxDecoration(
          color: _isDragging ? Colors.green[400] : Colors.grey[300],
          border: Border(
            right: BorderSide(
              color: Colors.grey[400]!,
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // ⚪ Indicadores visuales
            ...List.generate(3, (index) => Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: _isDragging ? Colors.white : Colors.grey[500],
                borderRadius: BorderRadius.circular(2),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCarritoPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[600]!],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Carrito (${_getTotalItems()} items)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: _togglePanel,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isPanelOpen ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_left,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                )
              ],
            ),
          ),

          // Lista del carrito
          Expanded(
            child: carrito.isEmpty
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text('Carrito vacío',
                    style: TextStyle(color: Colors.grey[600])),
              ],
            )
                : ListView.builder(
              itemCount: carrito.length,
              itemBuilder: (context, index) {
                return _buildCarritoItem(carrito[index]);
              },
            ),
          ),

          // Footer con total
          if (carrito.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Total: ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${_getTotalCarrito().toStringAsFixed(2)} MXN',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Procesar venta
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Procesando venta...'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Procesar Venta'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCarritoItem(ItemCarrito item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.producto.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '\$${item.producto.precioVenta.toStringAsFixed(2)} c/u',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),

          // Controles de cantidad
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (item.cantidad > 1) {
                      item.cantidad--;
                      item.actualizarSubtotal();
                    } else {
                      carrito.remove(item);
                    }
                  });
                },
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              ),
              Text(
                '${item.cantidad}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (item.cantidad < item.producto.stock) {
                      item.cantidad++;
                      item.actualizarSubtotal();
                    }
                  });
                },
                icon:
                const Icon(Icons.add_circle_outline, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========================
  // 🔎 Lógica de filtros
  // ========================
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

  // ========================
  // 🏷️ Categorías
  // ========================
  List<String> _getCategorias(List<Producto> productos) {
    final List<String> categorias = ['Todos'];
    final Set<String> categoriasUnicas =
    productos.map((p) => p.categoria).toSet();
    categorias.addAll(categoriasUnicas.toList()..sort());
    return categorias;
  }

  // ========================
  // 👪 Agrupar por categoría
  // ========================
  Map<String, List<Producto>> _groupProductosByCategory(
      List<Producto> productos) {
    final Map<String, List<Producto>> grouped = {};
    for (var producto in productos) {
      grouped.putIfAbsent(producto.categoria, () => []).add(producto);
    }
    return grouped;
  }

  // ========================
  // 🛒 Carrito helpers
  // ========================
  int _getTotalItems() {
    return carrito.fold(0, (sum, item) => sum + item.cantidad);
  }

  double _getTotalCarrito() {
    return carrito.fold(0, (sum, item) => sum + item.subtotal);
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
        _togglePanel();
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

  void _togglePanel() {
    setState(() {
      isPanelOpen = !isPanelOpen;
      if (isPanelOpen) {
        _panelController.forward();
      } else {
        _panelController.reverse();
      }
    });
    // print('Panel ${isPanelOpen ? "Abierto" : "Cerrado"}');
  }

  // ========================
  // ⛑️ UI auxiliares
  // ========================
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
