import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/producto.dart';

class ProductoDialog extends StatefulWidget {
  final Producto? producto; // null = crear, con datos = editar
  final List<String> categorias;

  const ProductoDialog({super.key, this.producto, required this.categorias});

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
      _stockController.text = p.stock.toString() ?? '';
      _stockMinimoController.text = p.stockMinimo.toString() ?? '';
      _descripcionController.text = p.descripcion ?? '';
      _categoriaSeleccionada = p.categoria;
      _activo = p.activo ?? true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.producto != null
                ? [Colors.blue.shade600, Colors.blue.shade800] // Editar = Azul
                : [Colors.green.shade600, Colors.green.shade800],
            // Crear = Verde
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
            ),
          ],
        ),
      ),
      content: Container(
        height: double.infinity,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.height * 0.7,
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(4),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del producto',
                      prefixIcon: Icon(
                        Icons.shopping_bag,
                        color: Colors.blue.shade500,
                      ),
                      filled: true,
                      fillColor: Colors.green.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.blue.shade600,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
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
                      prefixIcon: Icon(
                        Icons.business,
                        color: Colors.orange.shade600,
                      ),
                      filled: true,
                      fillColor: Colors.orange.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.orange.shade600,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
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
                      prefixIcon: Icon(
                        Icons.info_outline,
                        color: Colors.grey.shade600,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.shade600,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  Container(
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
                      controller: _precioVentaController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(
                            r'^\d*\.?\d{0,}$',
                          ), // permite un punto y números
                        ),
                      ],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade800,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Precio de venta:',
                        hintText: '\$0.00',
                        prefixIcon: Container(
                          margin: EdgeInsets.all(12),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.attach_money,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        suffixText: 'MXN',
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
                          borderSide: BorderSide(
                            color: Colors.green.shade200,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El precio de venta es obligatorio';
                        }
                        double? precio = double.tryParse(value);
                        if (precio == null || precio <= 0) {
                          return 'Ingrese un precio valido';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade100, Colors.orange.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: TextFormField(
                      controller: _precioCompraController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,}$'),
                        ),
                      ],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade800,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Precio de Compra',
                        hintText: '\$0.00',
                        prefixIcon: Container(
                          margin: EdgeInsets.all(12),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        suffixText: 'MXN',
                        suffixStyle: TextStyle(
                          color: Colors.orange.shade600,
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
                          borderSide: BorderSide(
                            color: Colors.orange.shade600,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El precio de compra es obligatorio';
                        }
                        double? precio = double.tryParse(value);
                        if (precio == null || precio <= 0) {
                          return 'Ingrese un precio válido';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade100, Colors.grey.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: TextFormField(
                      controller: _stockController,
                      enabled: false, // 🔒 NO EDITABLE
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Stock Actual',
                        hintText: '0 unidades',
                        helperText: '📦 Se actualizará por reabastecimiento',
                        helperStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        prefixIcon: Container(
                          margin: EdgeInsets.all(12),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade500,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.inventory_2,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        suffixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.grey.shade500,
                        ),
                        suffixText: 'uds',
                        suffixStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      // ✅ SIN VALIDATOR porque no es editable
                    ),
                  ),
                  SizedBox(height: 20),

                  // ✨ STOCK MÍNIMO - Estilo de alerta profesional
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade50, Colors.orange.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: TextFormField(
                      controller: _stockMinimoController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Stock Mínimo',
                        hintText: '5 unidades',
                        helperText:
                            '⚠️ Alerta cuando el stock baje de este número',
                        helperStyle: TextStyle(
                          color: Colors.amber.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Container(
                          margin: EdgeInsets.all(12),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade600,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.warning_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        suffixIcon: Icon(
                          Icons.notifications_active,
                          color: Colors.amber.shade600,
                        ),
                        suffixText: 'uds',
                        suffixStyle: TextStyle(
                          color: Colors.amber.shade700,
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
                          borderSide: BorderSide(
                            color: Colors.amber.shade600,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
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
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: _descripcionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Descripcion (Opcional)',
                      prefixIcon: Icon(
                        Icons.description,
                        color: Colors.orange.shade600,
                      ),
                      filled: true,
                      fillColor: Colors.orange.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.orange.shade600,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade50, Colors.indigo.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purple.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _categoriaSeleccionada,
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        hintText: 'Selecciona una categoría',
                        prefixIcon: Icon(Icons.category, color: Colors.purple.shade600),
                        // Icono que cambia según si hay selección
                        suffixIcon: _categoriaSeleccionada != null
                            ? Icon(Icons.check_circle, color: Colors.green.shade600)
                            : Icon(Icons.expand_more, color: Colors.purple.shade600),
                        filled: true,
                        fillColor: Colors.transparent, // Usa el gradiente del Container
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none, // Sin borde (usa el del Container)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.purple.shade600, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      // Estilo del texto seleccionado
                      style: TextStyle(
                        color: Colors.purple.shade800,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      dropdownColor: Colors.white, // Fondo de la lista desplegable
                      icon: SizedBox.shrink(), // Oculta la flecha por defecto
                      items: widget.categorias
                          .where((categoria) => categoria != 'Todos')
                          .map((categoria) => DropdownMenuItem<String>(
                        value: categoria,
                        child: Text(categoria), // ✅ SUPER SIMPLE, SIN ERRORES
                      ))
                          .toList(),
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
                  ),

                  SizedBox(height: 12),

                  // 🎛️ REEMPLAZA TU SwitchListTile CON ESTE:

                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _activo
                            ? [Colors.green.shade50, Colors.greenAccent.shade100]
                            : [Colors.red.shade50, Colors.orange.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _activo ? Colors.green.shade200 : Colors.red.shade200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_activo ? Colors.green : Colors.red).withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icono del estado
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _activo ? Colors.green.shade600 : Colors.red.shade600,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: (_activo ? Colors.green : Colors.red).withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _activo ? Icons.check_circle : Icons.cancel,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),

                        // Textos del estado
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _activo ? 'Producto Activo' : 'Producto Inactivo',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _activo ? Colors.green.shade800 : Colors.red.shade800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _activo
                                    ? '✅ Disponible para ventas'
                                    : '⚠️ Oculto del sistema de ventas',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _activo ? Colors.green.shade700 : Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 16),

                        // Switch personalizado
                        Transform.scale(
                          scale: 1.2, // Hace el switch un poco más grande
                          child: Switch(
                            value: _activo,
                            onChanged: (bool valor) {
                              setState(() {
                                _activo = valor;
                              });
                            },
                            activeColor: Colors.white,
                            activeTrackColor: Colors.green.shade600,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.red.shade400,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
          onPressed: _guardar,
          child: Text(widget.producto != null ? 'Actualizar' : 'Crear'),
        ),
      ],
    );
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final producto = Producto(
        id: widget.producto?.id,
        // ✅ null para crear, ID para editar
        nombre: _nombreController.text.trim(),
        marca: _marcaController.text.trim(),
        categoria: _categoriaSeleccionada!,
        modelo: _modeloController.text.trim().isEmpty
            ? null
            : _modeloController.text.trim(),
        // ✅ Ahora acepta null
        precioVenta: double.parse(_precioVentaController.text),
        precioCompra: double.parse(_precioCompraController.text),
        stock: int.parse(_stockController.text),
        stockMinimo: int.parse(_stockMinimoController.text),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        // ✅ Ahora acepta null
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
