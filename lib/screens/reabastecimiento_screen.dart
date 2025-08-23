import 'package:flutter/material.dart';
import 'home_screen.dart';

class ReabastecimientoScreen extends StatefulWidget{
  const ReabastecimientoScreen({super.key});

  @override
  _ReabastecimientoScreenState createState() => _ReabastecimientoScreenState();
}

class _ReabastecimientoScreenState extends State<ReabastecimientoScreen> {

  String selectedCategory = 'Todos';
  final List<String> _options = ['Opción 1', 'Opción 2', 'Opción 3'];

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery
        .of(context)
        .size
        .width > 600;
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
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
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
                          (categoria) =>
                          DropdownMenuItem(
                            value: categoria,
                            child: Text(categoria),
                          ),
                    ).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value ?? 'Todos';
                      });
                    },
                  ),
                ),
                SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}