import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'screens/login_screen.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tienda Cinnamons',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
  
}