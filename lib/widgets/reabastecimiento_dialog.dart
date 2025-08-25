import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/producto.dart';

class ReabastecimientoDialog extends StatefulWidget {
  final Producto producto;

  const ReabastecimientoDialog({super.key, required this.producto});

  @override
  _ReabastecimientoDialogState createState() => _ReabastecimientoDialogState();
}

class _ReabastecimientoDialogState extends State<ReabastecimientoDialog> {
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _costoTotalController = TextEditingController();
  final TextEditingController _proveedorController = TextEditingController();
  final TextEditingController _notasController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  int _stockActual = 0;
  int _cantidadAAgregar = 0;
  int _stockFinal = 0;
  double _costoUnitario = 0.0;
  String _tipoReabastecimiento = 'compra';

  @override
  void initState() {
    super.initState();
    _stockActual = widget.producto.stock;
    _stockFinal = _stockActual;

    // Prellenar algunos campos
    _costoUnitario = widget.producto.precioCompra;
  }

  void _calcularStockFinal() {
    int cantidad = int.tryParse(_cantidadController.text) ?? 0;

    print('🔍 Tipo seleccionado: $_tipoReabastecimiento');
    print('🔍 Cantidad ingresada: $cantidad');
    print('🔍 Stock actual: $_stockActual');

    setState(() {
      _cantidadAAgregar = cantidad;

      if (_tipoReabastecimiento == 'ajuste') {
        // En ajuste manual, la cantidad ingresada ES el stock final
        _stockFinal = cantidad;
        print('🔍 AJUSTE: Stock final será: $_stockFinal');
      } else if (_tipoReabastecimiento == 'devolucion') {
        // En devolución, el stock NO cambia
        _stockFinal = _stockActual;
        print('🔍 DEVOLUCIÓN: Stock final queda igual: $_stockFinal');
      } else {
        // En compra, se suma al stock actual
        _stockFinal = _stockActual + cantidad;
        print('🔍 COMPRA: Stock final será: $_stockFinal');
      }
    });
  }

  void _calcularCostoUnitario() {
    double costoTotal = double.tryParse(_costoTotalController.text) ?? 0.0;
    int cantidad = int.tryParse(_cantidadController.text) ?? 0;

    if (cantidad > 0 && costoTotal > 0) {
      setState(() {
        _costoUnitario = costoTotal / cantidad;
      });
    } else if (cantidad > 0 && costoTotal == 0) {
      // Si no hay costo total, usar el precio de compra del producto
      setState(() {
        _costoUnitario = widget.producto.precioCompra;
      });
    }
  }

  void _calcularCostoTotal() {
    int cantidad = int.tryParse(_cantidadController.text) ?? 0;

    if (cantidad > 0) {
      if (_tipoReabastecimiento == 'compra') {
        setState(() {
          _costoTotalController.text = (cantidad * _costoUnitario)
              .toStringAsFixed(2);
        });
      } else if (_tipoReabastecimiento == 'devolucion') {
        setState(() {
          double costoNegativo = -(cantidad * widget.producto.precioCompra);
          _costoTotalController.text = costoNegativo.toStringAsFixed(2);
        });
      } else if (_tipoReabastecimiento == 'ajuste') {
        setState(() {
          _costoTotalController.text = '0.00';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade600, Colors.indigo.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.local_shipping, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Reabastecer Producto',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.producto.nombre,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      content: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información del producto
                _buildProductoInfo(),
                SizedBox(height: 20),

                // Tipo de reabastecimiento
                _buildTipoReabastecimiento(),
                SizedBox(height: 16),

                // Cantidad a agregar
                _buildCantidadInput(),
                SizedBox(height: 16),

                // Resumen de stock
                _buildStockSummary(),
                SizedBox(height: 20),

                // Información de costos
                _buildCostosSection(),
                SizedBox(height: 16),

                // Proveedor
                _buildProveedorInput(),
                SizedBox(height: 16),

                // Notas adicionales
                _buildNotasInput(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _procesarReabastecimiento,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple.shade600,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_box, size: 18),
              SizedBox(width: 8),
              Text('Reabastecer'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductoInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600),
              SizedBox(width: 8),
              Text(
                'Información del Producto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text('Marca: ${widget.producto.marca}')),
              Expanded(
                child: Text('Modelo: ${widget.producto.modelo ?? 'N/A'}'),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text('Categoría: ${widget.producto.categoria}')),
              Expanded(
                child: Text('Stock Mínimo: ${widget.producto.stockMinimo}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipoReabastecimiento() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Tipo de Reabastecimiento',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text('Compra'),
                  subtitle: Text('Compra a proveedor (suma al stock)'),
                  value: 'compra',
                  groupValue: _tipoReabastecimiento,
                  onChanged: (value) {
                    setState(() {
                      _tipoReabastecimiento = value!;
                      _calcularStockFinal(); // Recalcular al cambiar tipo
                      _calcularCostoTotal();
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: Text('Devolución'),
                  subtitle: Text('Producto devuelto (no suma al stock)'),
                  value: 'devolucion',
                  groupValue: _tipoReabastecimiento,
                  onChanged: (value) {
                    setState(() {
                      _tipoReabastecimiento = value!;
                      _calcularStockFinal();
                      _calcularCostoTotal();
                    });
                  },
                ),
              ),
              Expanded(
                  child: RadioListTile<String>(
                    title: Text('Ajuste de Inventario'),
                    subtitle: Text('Corrección manual (sin costo)'),
                    value: 'ajuste',
                    groupValue: _tipoReabastecimiento,
                    onChanged: (value) {
                      setState(() {
                        _tipoReabastecimiento = value!;
                        _calcularStockFinal();
                        _calcularCostoTotal();
                      });
                    },
                  ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCantidadInput() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade100, Colors.green.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: TextFormField(
        controller: _cantidadController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.green.shade800,
        ),
        decoration: InputDecoration(
          labelText: _tipoReabastecimiento == 'ajuste'
              ? 'Stock Final Deseado'
              : 'Cantidad a Agregar',
          hintText: '0',
          prefixIcon: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.add_box, color: Colors.white, size: 20),
          ),
          suffixText: 'unidades',
          suffixStyle: TextStyle(
            color: Colors.green.shade600,
            fontWeight: FontWeight.bold,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.green.shade600, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
        onChanged: (value) {
          _calcularStockFinal();
          _calcularCostoTotal(); // Calcula el costo total basado en cantidad x precio unitario
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Ingrese la cantidad a agregar';
          }
          int? cantidad = int.tryParse(value);
          if (cantidad == null || cantidad <= 0) {
            return 'Ingrese una cantidad válida';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildStockSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade50, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.inventory, color: Colors.amber.shade700),
              SizedBox(width: 8),
              Text(
                'Resumen de Stock',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Para ajuste manual, mostrar layout diferente
          if (_tipoReabastecimiento == 'ajuste')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStockCard('Actual', _stockActual, Colors.blue),
                Icon(Icons.arrow_forward, color: Colors.grey.shade600),
                _buildStockCard('Nuevo Stock', _cantidadAAgregar, Colors.purple),
              ],
            )
          else
          // Para compra y devolución, mostrar el layout original
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStockCard('Actual', _stockActual, Colors.blue),
                Icon(
                    _tipoReabastecimiento == 'devolucion' ? Icons.remove : Icons.add,
                    color: Colors.grey.shade600
                ),
                _buildStockCard(
                    _tipoReabastecimiento == 'devolucion' ? 'A Devolver' : 'A Agregar',
                    _cantidadAAgregar,
                    Colors.green
                ),
                Icon(Icons.arrow_forward, color: Colors.grey.shade600),
                _buildStockCard('Final', _stockFinal, Colors.purple),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStockCard(String label, int cantidad, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade300),
          ),
          child: Text(
            '$cantidad',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent.shade700,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCostosSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.red.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.orange.shade700),
              SizedBox(width: 8),
              Text(
                'Información de Costos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _costoTotalController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}$'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Costo Total',
                    hintText: '\$0.00',
                    prefixIcon: Icon(
                      Icons.receipt,
                      color: Colors.orange.shade600,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => _calcularCostoUnitario(),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Costo Unitario',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '\$${_costoUnitario.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProveedorInput() {
    return TextFormField(
      controller: _proveedorController,
      decoration: InputDecoration(
        labelText: 'Proveedor (Opcional)',
        hintText: 'Nombre del proveedor',
        prefixIcon: Icon(Icons.business, color: Colors.indigo.shade600),
        filled: true,
        fillColor: Colors.indigo.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade600, width: 2),
        ),
      ),
    );
  }

  Widget _buildNotasInput() {
    return TextFormField(
      controller: _notasController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Notas Adicionales (Opcional)',
        hintText: 'Observaciones sobre el reabastecimiento...',
        prefixIcon: Icon(Icons.note_add, color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600, width: 2),
        ),
      ),
    );
  }

  void _procesarReabastecimiento() {
    if (_formKey.currentState!.validate()) {
      // Mapear los tipos del dialog a los que espera el servidor
      Map<String, bool> tipoFlags = {
        'reabastecimiento': false,
        'devolucion': false,
        'ajuste_manual': false,
      };

      // Convertir el tipo seleccionado a las banderas que espera el backend
      switch (_tipoReabastecimiento) {
        case 'compra':
          tipoFlags['reabastecimiento'] = true;
          break;
        case 'devolucion':
          tipoFlags['devolucion'] = true;
          break;
        case 'ajuste':
          tipoFlags['ajuste_manual'] = true;
          break;
      }

      // Crear objeto con los datos del reabastecimiento según el formato del backend
      final reabastecimiento = {
        'producto_id': widget.producto.id,
        'cantidad_agregada': _cantidadAAgregar,
        'costo_total': double.tryParse(_costoTotalController.text) ?? 0.0,

        // Banderas booleanas según el tipo seleccionado
        'reabastecimiento': tipoFlags['reabastecimiento']!,
        'devolucion': tipoFlags['devolucion']!,
        'ajuste_manual': tipoFlags['ajuste_manual']!,

        'proveedor': _proveedorController.text.trim().isEmpty
            ? null
            : _proveedorController.text.trim(),
        'notas': _notasController.text.trim().isEmpty
            ? null
            : _notasController.text.trim(),

        // Datos adicionales para mostrar en la UI (estos no se envían al servidor)
        'stock_anterior': _stockActual,
        'stock_final': _stockFinal,
        'costo_unitario': _costoUnitario,
        'tipo_display': _tipoReabastecimiento,
      };

      // DEBUG: Imprimir antes de enviar
      print('🔍 Datos del dialog antes de enviar:');
      print('  Tipo seleccionado: $_tipoReabastecimiento');
      print('  Banderas: ${tipoFlags.toString()}');
      print('  Producto ID: ${widget.producto.id}');
      print('  Cantidad: $_cantidadAAgregar');
      print(
        '  Costo total: ${double.tryParse(_costoTotalController.text) ?? 0.0}',
      );

      Navigator.of(context).pop(reabastecimiento);
    }
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _costoTotalController.dispose();
    _proveedorController.dispose();
    _notasController.dispose();
    super.dispose();
  }
}
