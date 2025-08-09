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
      _modeloController.text = p.modelo;
      _precioVentaController.text = p.precioVenta.toString();
      _precioCompraController.text = p.precioCompra.toString();
    }
  }

  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.producto != null ? 'Editar Producto' : 'Crear Producto',
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
    if (_formKey.currentState!.validate()){
      String nombre = _nombreController.text.trim();
      print('Guardando: $nombre');
      Navigator.of(context).pop();
    }
  }
}
