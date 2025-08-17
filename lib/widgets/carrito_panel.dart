import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tienda_tecnologia/config/api_config.dart';
import '../models/producto.dart';
import 'package:http/http.dart' as http;

// 🧩 Modelo ItemCarrito
class ItemCarrito {
  final Producto producto;
  int cantidad;
  double subtotal;

  ItemCarrito({required this.producto, this.cantidad = 1})
    : subtotal = producto.precioVenta * cantidad;

  void actualizarSubtotal() {
    subtotal = producto.precioVenta * cantidad;
  }
}

// 🎯 WIDGET DEL PANEL DEL CARRITO
class CarritoPanel extends StatefulWidget {
  final List<ItemCarrito> carrito;
  final VoidCallback onTogglePanel;
  final bool isPanelOpen;
  final Function(ItemCarrito, int) onModificarCantidad;
  final VoidCallback onVaciarCarrito;

  const CarritoPanel({
    super.key,
    required this.carrito,
    required this.onTogglePanel,
    required this.isPanelOpen,
    required this.onModificarCantidad,
    required this.onVaciarCarrito,
  });

  @override
  State<CarritoPanel> createState() => _CarritoPanelState();
}

class _CarritoPanelState extends State<CarritoPanel>
    with TickerProviderStateMixin {
  late AnimationController _panelController;
  late Animation<Offset> _panelAnimation;

  double _panelWidth = 400.0;
  double _minPanelWidth = 280.0;
  double _maxPanelWidth = 600.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();

    _panelController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _panelAnimation =
        Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(parent: _panelController, curve: Curves.easeInOut),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final screenWidth = MediaQuery.of(context).size.width;
        setState(() {
          _maxPanelWidth = screenWidth * 0.8;
          _panelWidth = screenWidth * 0.35;
        });
      }
    });
  }

  @override
  void didUpdateWidget(CarritoPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPanelOpen && !_panelController.isCompleted) {
      _panelController.forward();
    } else if (!widget.isPanelOpen && !_panelController.isDismissed) {
      _panelController.reverse();
    }
  }

  @override
  void dispose() {
    _panelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  Expanded(child: _buildCarritoContent()),
                ],
              ),
            ),
          ),
        ),
        if (!widget.isPanelOpen) _buildCarritoTab(),
      ],
    );
  }

  Widget _buildCarritoTab() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.3,
      right: 0,
      child: GestureDetector(
        onTap: widget.onTogglePanel,
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
              const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
              const SizedBox(height: 4),
              if (_getTotalItems() > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
                quarterTurns: -1,
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
          double newWidth = _panelWidth - details.delta.dx;
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
          border: Border(right: BorderSide(color: Colors.grey[400]!, width: 1)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ...List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _isDragging ? Colors.white : Colors.grey[500],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarritoContent() {
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
          _buildCarritoHeader(),
          _buildCarritoBody(),
          if (widget.carrito.isNotEmpty) _buildCarritoFooter(),
        ],
      ),
    );
  }

  Widget _buildCarritoHeader() {
    return Container(
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
          if (widget.carrito.isNotEmpty)...[
            GestureDetector(
              onTap: _mostrarConfirmacionVaciar,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_sweep,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8,),
          ],
          GestureDetector(
            onTap: widget.onTogglePanel,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.isPanelOpen
                    ? Icons.keyboard_arrow_right
                    : Icons.keyboard_arrow_left,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarritoBody() {
    return Expanded(
      child: widget.carrito.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'Carrito vacío',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            )
          : ListView.builder(
              itemCount: widget.carrito.length,
              itemBuilder: (context, index) {
                return _buildCarritoItem(widget.carrito[index]);
              },
            ),
    );
  }

  Widget _buildCarritoFooter() {
    return Container(
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              onPressed: _mostrarConfirmacionVenta,
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => widget.onModificarCantidad(item, -1),
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.red,
                ),
              ),
              Text(
                '${item.cantidad}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => widget.onModificarCantidad(item, 1),
                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getTotalItems() {
    return widget.carrito.fold(0, (sum, item) => sum + item.cantidad);
  }

  double _getTotalCarrito() {
    return widget.carrito.fold(0, (sum, item) => sum + item.subtotal);
  }

  Future<void> _procesarVenta() async {
    if (widget.carrito.isEmpty) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Procesando Venta...')));

    final productosList = widget.carrito.map((item) {
      return {'producto_id': item.producto.id, 'cantidad': item.cantidad};
    }).toList();

    final ventaData = {
      'usuario_id': 1,
      'metodo_pago': 'Efectivo',
      'productos': productosList,
    };

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.ventasEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ventaData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Venta realizada correctamente');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Venta realizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        widget.onVaciarCarrito();

        Future.delayed(Duration(seconds: 2), (){
          if (mounted){
            widget.onTogglePanel();
          }
        });

      } else {
        print('⚠ Error ${response.statusCode}: ${response.body}');
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
  void _mostrarConfirmacionVenta(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text('Confirmar accion'),
            ],
          ),
          content: Text('Confirmar Venta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _procesarVenta();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
              ),
              child: Text('Vender'),
            ),
          ],
        );
      },
    );
  }
  void _mostrarConfirmacionVaciar() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text('Confirmar accion'),
            ],
          ),
          content: Text('Estas seguro de que quieres vaciar el carrito?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onVaciarCarrito();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Vaciar'),
            ),
          ],
        );
      },
    );
  }
}
