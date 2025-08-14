import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'inventario_screen.dart';
import 'ventas_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> opcionesMenu = [
    {
      'titulo': 'Inventario',
      'icono': Icons.inventory_2_outlined,
      'color': Colors.blue,
    },
    {'titulo': 'Ventas', 'icono': Icons.shopping_cart, 'color': Colors.green},
    {
      'titulo': 'Caja',
      'icono': Icons.account_balance_wallet_sharp,
      'color': Colors.orange,
    },
    {
      'titulo': 'Reabastecimiento',
      'icono': Icons.local_shipping,
      'color': Colors.purple,
    },
  ];

  Widget _crearCard(Map<String, dynamic> opcion, bool isDesktop, BuildContext context) {
    // Valores dinámicos para el card
    double cardElevation = isDesktop ? 6 : 8;
    double borderRadius = isDesktop ? 16 : 20;
    double iconContainerSize = isDesktop ? 90 : 80;
    double iconSize = isDesktop ? 48 : 40;
    double fontSize = isDesktop ? 20 : 12;
    double cardPadding = isDesktop ? 20 : 16;

    return Card(
      elevation: cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey[50]!],
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
            onTap: () {
              if(opcion['titulo'] == 'Inventario') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => InventarioScreen()),
                );
              }
              else if(opcion['titulo'] == 'Ventas'){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => VentasScreen()),
                );
            }
            print('${opcion['titulo']} presionado');
          },
          child: Container(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Contenedor del icono con fondo de color
                Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    color: opcion['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isDesktop ? 12 : 16),
                  ),
                  child: Icon(
                    opcion['icono'],
                    size: iconSize,
                    color: opcion['color'],
                  ),
                ),
                SizedBox(height: isDesktop ? 12 : 16),

                // Texto del título
                Text(
                  opcion['titulo'],
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: isDesktop ? 1 : 2, // Una línea en PC, dos en móvil
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 600;

    int gridColumns = isDesktop ? 4 : 2;
    double gridSpace = isDesktop ? 20 : 16;
    double cardPadding = isDesktop ? 24 : 16;
    double appBarHeight = isDesktop ? 80 : 70;
    double appBarTextSize = isDesktop ? 24 : 20;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.blue[900]!, Colors.blue[600]!],
            ),
          ),
          child: SafeArea(
            child: Container(
              height: appBarHeight,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Tienda Tecnologia',
                    style: TextStyle(
                      fontSize: appBarTextSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  IconButton(
                    icon: Icon(
                      Icons.logout,
                      size: isDesktop ? 28 : 24,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.grey[100]!, Colors.grey[300]!],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: GridView.count(
            crossAxisCount: gridColumns,
            crossAxisSpacing: gridSpace,
            mainAxisSpacing: gridSpace,
            children: opcionesMenu
                .map((opcion) => _crearCard(opcion, isDesktop, context))
                .toList(),
          ),
        ),
      ),
    );
  }
}
