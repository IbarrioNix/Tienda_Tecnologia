import 'package:flutter/material.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {

  final List<Map<String, dynamic>> opcionesMenu = [
    {
      'titulo' : 'Inventario',
      'icono' : Icons.inventory_2_outlined,
      'color' : Colors.blue,
    },
    {
      'titulo' : 'Ventas',
      'icono' : Icons.shopping_cart,
      'color' : Colors.green,
    },
    {
      'titulo' : 'Caja',
      'icono' : Icons.account_balance_wallet_sharp,
      'color' : Colors.orange,
    },
    {
      'titulo' : 'Reabastecimiento',
      'icono' : Icons.local_shipping,
      'color' : Colors.purple,
    }
  ];

  Widget crearCard(Map<String, dynamic> opcion){
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          print('${opcion['titulo']} presionado');
        },
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                opcion['icono'],
                size: 40,
                color: Colors.blue,
              ),
              SizedBox(height: 8),
              Text(
                opcion['titulo'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tienda Cinnamons'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children:
            opcionesMenu.map((opcion) => crearCard(opcion)).toList(),
        ),
      ),
    );
  }
}
