import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_screen.dart';
import '../config/api_config.dart';
import '../models/reabastecimiento.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class ReabastecimientoScreen extends StatefulWidget {
  const ReabastecimientoScreen({super.key});

  @override
  _ReabastecimientoScreenState createState() => _ReabastecimientoScreenState();
}

class _ReabastecimientoScreenState extends State<ReabastecimientoScreen> {
  String selectedCategory = 'Todos';
  String searchQuery = '';
  bool isLoading = true;

  List<Reabastecimiento> allReabastecimientos = [];
  List<Reabastecimiento> filteredReabastecimientos = [];

  final List<String> _options = ['Todos', 'Compra', 'Devolución', 'Ajuste Manual'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarReabastecimientos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        title: Text('Reabastecimiento'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: _cargarReabastecimientos,
            icon: Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Sección de filtros
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar producto, marca o proveedor...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            searchQuery = '';
                            _filtrarReabastecimientos();
                          });
                        },
                        icon: Icon(Icons.clear),
                      )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        _filtrarReabastecimientos();
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
                    items: _options
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
                        _cargarReabastecimientos();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Estadísticas rápidas
          if (!isLoading && filteredReabastecimientos.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    'Total',
                    filteredReabastecimientos.length.toString(),
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Compras',
                    filteredReabastecimientos
                        .where((r) => r.reabastecimiento)
                        .length
                        .toString(),
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Devoluciones',
                    filteredReabastecimientos
                        .where((r) => r.devolucion)
                        .length
                        .toString(),
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Ajustes',
                    filteredReabastecimientos
                        .where((r) => r.ajusteManual)
                        .length
                        .toString(),
                    Colors.purple,
                  ),
                ],
              ),
            ),

          // Lista de reabastecimientos
          Expanded(
            child: isLoading
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando reabastecimientos...'),
                ],
              ),
            )
                : filteredReabastecimientos.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    searchQuery.isNotEmpty
                        ? 'No se encontraron resultados'
                        : 'No hay reabastecimientos registrados',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (searchQuery.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          searchQuery = '';
                          selectedCategory = 'Todos';
                          _filtrarReabastecimientos();
                        });
                      },
                      child: Text('Limpiar filtros'),
                    ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _cargarReabastecimientos,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: filteredReabastecimientos.length,
                itemBuilder: (context, index) {
                  final reabastecimiento = filteredReabastecimientos[index];
                  return _buildReabastecimientoCard(reabastecimiento);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navegar a pantalla de crear reabastecimiento
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Función de agregar reabastecimiento próximamente')),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
        tooltip: 'Agregar reabastecimiento',
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReabastecimientoCard(Reabastecimiento reabastecimiento) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: reabastecimiento.colorTipo,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con tipo y fecha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: reabastecimiento.colorTipo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: reabastecimiento.colorTipo.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          reabastecimiento.iconoTipo,
                          size: 16,
                          color: reabastecimiento.colorTipo,
                        ),
                        SizedBox(width: 6),
                        Text(
                          reabastecimiento.tipoDisplay,
                          style: TextStyle(
                            color: reabastecimiento.colorTipo,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatter.format(reabastecimiento.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Información del producto
              Row(
                children: [
                  Icon(Icons.inventory_2, color: Colors.grey[600], size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reabastecimiento.productoCompleto,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Información de cantidad y costo
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Cantidad',
                      '${reabastecimiento.cantidadAgregada} unidades',
                      Icons.add_circle_outline,
                    ),
                  ),
                  if (reabastecimiento.costoTotal > 0)
                    Expanded(
                      child: _buildInfoItem(
                        'Costo Total',
                        currencyFormat.format(reabastecimiento.costoTotal),
                        Icons.attach_money,
                      ),
                    ),
                ],
              ),

              // Información adicional si está disponible
              if (reabastecimiento.proveedor != null && reabastecimiento.proveedor!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: _buildInfoItem(
                    'Proveedor',
                    reabastecimiento.proveedor!,
                    Icons.business,
                  ),
                ),

              if (reabastecimiento.notas != null && reabastecimiento.notas!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: _buildInfoItem(
                    'Notas',
                    reabastecimiento.notas!,
                    Icons.note,
                  ),
                ),

              // Costo unitario si está disponible
              if (reabastecimiento.costoUnitario > 0)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calculate, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          'Costo unitario: ${currencyFormat.format(reabastecimiento.costoUnitario)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _filtrarReabastecimientos() {
    setState(() {
      filteredReabastecimientos = allReabastecimientos.where((reabastecimiento) {
        // Filtro por categoría
        bool coincideCategoria = true;
        if (selectedCategory != 'Todos') {
          switch (selectedCategory) {
            case 'Compra':
              coincideCategoria = reabastecimiento.reabastecimiento;
              break;
            case 'Devolución':
              coincideCategoria = reabastecimiento.devolucion;
              break;
            case 'Ajuste Manual':
              coincideCategoria = reabastecimiento.ajusteManual;
              break;
          }
        }

        // Filtro por búsqueda
        bool coincideBusqueda = true;
        if (searchQuery.isNotEmpty) {
          final query = searchQuery.toLowerCase();
          coincideBusqueda = reabastecimiento.productoNombre.toLowerCase().contains(query) ||
              reabastecimiento.marca.toLowerCase().contains(query) ||
              (reabastecimiento.modelo?.toLowerCase().contains(query) ?? false) ||
              (reabastecimiento.proveedor?.toLowerCase().contains(query) ?? false) ||
              reabastecimiento.tipoDisplay.toLowerCase().contains(query);
        }

        return coincideCategoria && coincideBusqueda;
      }).toList();

      // Ordenar por fecha más reciente
      filteredReabastecimientos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  Future<void> _cargarReabastecimientos() async {
    setState(() {
      isLoading = true;
    });

    try {
      String endpoint;

      switch (selectedCategory) {
        case 'Compra':
          endpoint = '${ApiConfig.baseUrl}/reabastecimientos/reabastecimiento';
          break;
        case 'Devolución':
          endpoint = '${ApiConfig.baseUrl}/reabastecimientos/devolucion';
          break;
        case 'Ajuste Manual':
          endpoint = '${ApiConfig.baseUrl}/reabastecimientos/ajuste_manual';
          break;
        default:
          endpoint = '${ApiConfig.baseUrl}/reabastecimientos';
      }

      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        List<dynamic> data;
        if (selectedCategory == 'Todos') {
          data = jsonResponse['reabastecimientos'] ?? [];
        } else {
          data = jsonResponse['registros'] ?? [];
        }

        setState(() {
          allReabastecimientos = data
              .map((json) => Reabastecimiento.fromJson(json))
              .toList();
          _filtrarReabastecimientos();
          isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${allReabastecimientos.length} registros cargados'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar reabastecimientos: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }

      print('Error cargando reabastecimientos: $e');
    }
  }
}