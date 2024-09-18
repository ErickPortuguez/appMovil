import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/screen/login_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ventas Panchita',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Color principal de la aplicación
        scaffoldBackgroundColor: Colors.white, // Color de fondo de los Scaffold
        canvasColor: Colors.white, // Color de fondo del canvas, utilizado por varios widgets
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}


