import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:myapp/screen/sidebar/sidebar.dart'; // Ajusta esta importación según tu estructura de proyecto
import 'package:myapp/services/seller_service.dart';
import 'package:myapp/models/seller_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isVisible = false;
  bool isLoginTrue = false;
  bool isLoading = false;
  String errorMessage = '';

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Llamada al servicio para obtener la lista de vendedores activos
      List<Seller> activeSellers;
      try {
        activeSellers = await ApiServiceSeller.getActiveSellers();
      } catch (e) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error retrieving sellers: ${e.toString()}';
        });
        return;
      }

      // Verifica si el usuario y la contraseña coinciden con alguno de los vendedores activos
      final enteredUsername = _usernameController.text;
      final enteredPassword = _passwordController.text;
      final validSeller = activeSellers.firstWhereOrNull((seller) =>
          seller.sellerUser == enteredUsername &&
          seller.sellerPassword == enteredPassword);

      setState(() {
        isLoading = false;
      });

      if (validSeller != null) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => HomePage(seller: validSeller)),
        );
      } else {
        // Si el usuario y la contraseña no coinciden con ninguno de los vendedores activos
        setState(() {
          isLoginTrue = true;
          errorMessage = 'Usuario o Contraseña es invalido';
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Antes de mostrar la imagen, asegúrate de definir la ubicación en pubspec.yaml
                  Image.asset(
                    "lib/assets/login.png", // Ajusta esta ruta según tu estructura de proyecto
                    width: 210,
                  ),
                  const SizedBox(height: 15),
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue.withOpacity(.2),
                    ),
                    child: TextFormField(
                      controller: _usernameController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Usuario es requerido";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        border: InputBorder.none,
                        hintText: "Usuario",
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue.withOpacity(.2),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Contraseña es requerida";
                        }
                        return null;
                      },
                      obscureText: !isVisible,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.lock),
                        border: InputBorder.none,
                        hintText: "Contraseña",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                          icon: Icon(isVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width * .9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue,
                    ),
                    child: TextButton(
                      onPressed: _login,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "LOGIN",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
