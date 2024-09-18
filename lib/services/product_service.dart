import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/config.dart';
import 'package:myapp/models/product_model.dart';

class ApiServiceProduct {
  static const String baseUrl =
     '${Config.baseUrl}/api/v1';
  static Future<List<Product>> getActiveProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products/active'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Product>.from(data.map((model) => Product.fromJson(model)));
    } else {
      throw Exception('Failed to load active Productos');
    }
  }

  static Future<List<Product>> getInactiveProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products/inactive'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Product>.from(data.map((model) => Product.fromJson(model)));
    } else {
      throw Exception('Failed to load inactive Productos');
    }
  }

  static Future<List<Product>> getStockProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products/lowstock'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Product>.from(data.map((model) => Product.fromJson(model)));
    } else {
      throw Exception('Failed to load inactive Productos');
    }
  }

  static Future<List<Product>> getExpiryProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products/expiring'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Product>.from(data.map((model) => Product.fromJson(model)));
    } else {
      throw Exception('Failed to load inactive Productos');
    }
  }

  static Future<void> deleteProduct(int productId) async {
    final response =
        await http.put(Uri.parse('$baseUrl/products/disable/$productId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete Proveedores');
    }
  }

  static Future<void> activeProduct(int productId) async {
    final response =
        await http.put(Uri.parse('$baseUrl/products/activate/$productId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to activate Proveedores');
    }
  }

  static Future<void> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception(
          'Failed to create producto: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/${product.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to update Proveedor: ${response.statusCode} - ${response.body}');
    }
  }

  // Función para verificar si existe un producte con el nombre dado
  static Future<bool> checkExistingProduct(String name) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/products/exists?name=$name'));
      if (response.statusCode == 200) {
        return true; // Si existe un producto con ese nombre
      } else if (response.statusCode == 404) {
        return false; // Si no existe un producto con ese nombre
      } else {
        throw Exception('Failed to check producto existence');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
