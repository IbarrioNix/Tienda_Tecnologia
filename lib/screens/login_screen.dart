import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';
import '../config/api_config.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<Map<String, dynamic>> realizarLogin(String email, String password) async {
    try{
      print('Enviado login a: $email con password $password');

      final response = await http.post(
        Uri.parse(ApiConfig.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email' : email,
          'password' : password,
        }),
      );
      
      print('Respuesta de api: ${response.statusCode}');

      final data = json.decode(response.body);
      print('Datos recibidos: $data');

      return {
        'success': response.statusCode == 200 && data['success'],
        'mensaje': data['mensaje'] ?? data['error'] ?? 'Error desconocido',
        'usuario': data['usuario'],
      };
    } catch (e) {
      print('❌ Error de conexión: $e');
      return {
        'success': false,
        'mensaje': 'Error de conexión con el servidor',
        'usuario': null,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.1,
            vertical: 50,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: double.infinity, // Máximo 400px de ancho
            ),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(50.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.07,
                      backgroundImage: AssetImage('assets/images/logo.jpg'),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Tienda Cinammonss',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.02,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 40),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 20),

                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.password),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 30),

                    SizedBox(
                      width: 300,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                setState(() {
                                  isLoading = true;
                                });
                                String email = emailController.text;
                                String password = passwordController.text;

                                if (email.isEmpty || password.isEmpty) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Ingrese todos los campos'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                Map<String, dynamic> resultado = await realizarLogin(
                                  email,
                                  password,
                                );

                                if (resultado['success']) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(resultado['mensaje']),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(resultado['mensaje']),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                                setState(() {
                                  isLoading = false;
                                });
                              },
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Iniciar Sesion',
                                style: TextStyle(fontSize: 20),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
