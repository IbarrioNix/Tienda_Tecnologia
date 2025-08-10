import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';
import '../config/api_config.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
    // Detectar si es PC o móvil
    bool isDesktop = MediaQuery.of(context).size.width > 600;

    // Valores dinámicos según el dispositivo
    double logoRadius = isDesktop ? 40 : 60;
    double titleSize = isDesktop ? 24 : 28;
    double cardWidth = isDesktop ? 400 : double.infinity;
    double padding = isDesktop ? 48 : 24;
    EdgeInsets margins = isDesktop
        ? EdgeInsets.symmetric(horizontal: 100)
        : EdgeInsets.all(16);

    return Scaffold(
        body: Container(
          // Gradiente solo en desktop
          decoration:  BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[900]!, Colors.blue[600]!],
            ),
          ),
          child: Center(
            child: Padding(
              padding: margins,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: cardWidth,
                ),
                child: Card(
                  elevation: isDesktop ? 12 : 4,  // Más sombra en desktop
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo con tamaño dinámico
                        CircleAvatar(
                          radius: logoRadius,
                          backgroundImage: AssetImage('assets/images/logo.jpg'),
                        ),
                        SizedBox(height: isDesktop ? 24 : 32),

                        // Título con tamaño dinámico
                        Text(
                          'Tienda Cinammons',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: isDesktop ? 32 : 48),

                        // Email field
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: isDesktop ? 16 : 20),

                        // Password field
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                        ),
                        SizedBox(height: isDesktop ? 24 : 32),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: isLoading ? null : () async {
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
                                style: TextStyle(fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
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
    ),
    );
  }
}
