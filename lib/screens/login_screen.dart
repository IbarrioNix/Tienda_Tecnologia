import 'package:flutter/material.dart';
import '../config/supabase_config.dart';

class LoginScreen extends StatefulWidget{
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<bool> verificarUsuario(String email, String password) async {
    try{
      print('Buscando usuario con email: $email y password: $password');

      final response = await SupabaseConfig.client
          .from('usuarios')
          .select()
          .eq('email', email)
          .eq('password', password);

      print('Respuesta de la base de datos: $response');

      return response.length > 0;
    }catch(e){
      print('error al verificar usuario: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tienda Cinammons',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue
              ),
            ),
            SizedBox(height: 40),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                  onPressed: () async{
                    String email = emailController.text;
                    String password = passwordController.text;

                    if (email.isEmpty || password.isEmpty){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content:
                        Text('Ingrese todos los campos'),
                        backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    bool usuarioValido = await verificarUsuario(email, password);

                    if(usuarioValido) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content:
                        Text('Login Exitoso'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content:
                        Text('Email o contraseña incorrectos'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text('Iniciar Sesion',
                  style: TextStyle(fontSize: 20),)
              )
            )
          ],
        ),
      ),
    );
  }

}