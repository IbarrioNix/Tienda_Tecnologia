import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/producto.dart';

class ProductoDialog extends StatefulWidget {
  final Producto? producto; // null = crear, con datos = editar
  final List<String> categorias;

  const ProductoDialog({Key? key, this.producto, required this.categorias})
    : super(key: key);

  @override
  _ProductoDialogState createState() => _ProductoDialogState();
}

class _ProductoDialogState extends State<ProductoDialog> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _precioVentaController = TextEditingController();
  final TextEditingController _precioCompraController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _stockMinimoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  String? _categoriaSeleccionada;
  bool _activo = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.producto != null) {
      final p = widget.producto!;
      _nombreController.text = p.nombre;
      _marcaController.text = p.marca;
      _modeloController.text = p.modelo ?? '';
      _precioVentaController.text = p.precioVenta.toString();
      _precioCompraController.text = p.precioCompra.toString();
      _stockController.text = p.stock?.toString() ?? '';
      _stockMinimoController.text = p.stockMinimo?.toString() ?? '';
      _descripcionController.text = p.descripcion ?? '';
      _categoriaSeleccionada = p.categoria;
      _activo = p.activo ?? true;

    }
  }

  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.producto != null
                ? [Colors.blue.shade600, Colors.blue.shade800]  // Editar = Azul
                : [Colors.green.shade600, Colors.green.shade800], // Crear = Verde
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (widget.producto != null ? Colors.blue : Colors.green)
                  .withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              widget.producto != null ? Icons.edit : Icons.add_circle,
              color: Colors.white,
              size: 28,
            ),
            SizedBox(width: 12),

            Text(
              widget.producto != null ? 'Editar Producto' : 'Crear Producto',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),

            )
          ],
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre del producto',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _marcaController,
              decoration: InputDecoration(
                labelText: 'Marca',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La marca es obligatoria';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _modeloController,
              decoration: InputDecoration(
                labelText: 'Modelo',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _precioVentaController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d{0,}$'), // permite un punto y números
                ),
              ],
              decoration: InputDecoration(
                labelText: 'Precio de venta:',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El precio de venta es obligatorio';
                }
                double? precio = double.tryParse(value);
                if(precio == null || precio <= 0){
                  return 'Ingrese un precio valido';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _precioCompraController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d{0,}$'), // permite un punto y números
                ),
              ],
              decoration: InputDecoration(
                labelText: 'Precio de compra:',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El precio de compra es obligatorio';
                }
                double? precio = double.tryParse(value);
                if(precio == null || precio <= 0){
                  return 'Ingrese un precio valido';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Solo números enteros
              ],
              decoration: InputDecoration(
                labelText: 'Stock actual',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El stock es obligatorio';
                }
                int? stock = int.tryParse(value);
                if (stock == null || stock < 0) {
                  return 'Ingrese un stock válido';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _stockMinimoController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Solo números enteros
              ],
              decoration: InputDecoration(
                labelText: 'Stock mínimo',
                border: OutlineInputBorder(),
                helperText: 'Alerta cuando el stock baje de este número',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El stock mínimo es obligatorio';
                }
                int? stockMin = int.tryParse(value);
                if (stockMin == null || stockMin < 0) {
                  return 'Ingrese un stock mínimo válido';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _descripcionController,
              maxLines: 3, // ✅ Campo de texto largo
              decoration: InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true, // ✅ Label arriba cuando es multilinea
              ),
              // ✅ NO tiene validator porque es OPCIONAL
            ),
            SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _categoriaSeleccionada,
              decoration: InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: widget.categorias
                  .where((categoria) => categoria != 'Todos')
                  .map((categoria) {
                return DropdownMenuItem<String>(
                  value: categoria,
                  child: Text(categoria),
                );
              }).toList(),
              onChanged: (String? nuevaCategoria) {
                setState(() {
                  _categoriaSeleccionada = nuevaCategoria;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Seleccione una categoría';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

// 🟢 SWITCH PARA ACTIVAR/DESACTIVAR
            SwitchListTile(
              title: Text('Producto activo'),
              subtitle: Text(_activo
                  ? 'Disponible para ventas'
                  : 'Oculto en el sistema de ventas'),
              value: _activo,
              onChanged: (bool value) {
                setState(() {
                  _activo = value;
                });
              },
              activeColor: Colors.green,
              contentPadding: EdgeInsets.zero, // Sin padding extra
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardar,
          child: Text(widget.producto != null ? 'Actualizar' : 'Crear'),
        ),
      ],
    );
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final producto = Producto(
        id: widget.producto?.id,  // ✅ null para crear, ID para editar
        nombre: _nombreController.text.trim(),
        marca: _marcaController.text.trim(),
        categoria: _categoriaSeleccionada!,
        modelo: _modeloController.text.trim().isEmpty
            ? null
            : _modeloController.text.trim(),     // ✅ Ahora acepta null
        precioVenta: double.parse(_precioVentaController.text),
        precioCompra: double.parse(_precioCompraController.text),
        stock: int.parse(_stockController.text),
        stockMinimo: int.parse(_stockMinimoController.text),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(), // ✅ Ahora acepta null
        activo: _activo,
        createdAt: widget.producto?.createdAt ?? DateTime.now(),
      );

      Navigator.of(context).pop(producto);
    }
  }


  @override
  void dispose() {
    // ✅ LIMPIAR TODOS LOS CONTROLLERS
    _nombreController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _precioVentaController.dispose();
    _precioCompraController.dispose();
    _stockController.dispose();
    _stockMinimoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}
