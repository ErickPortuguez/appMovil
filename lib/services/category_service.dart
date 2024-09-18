import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/config.dart';
import 'package:myapp/models/category_model.dart';

class ApiServiceCategory {
  static const String baseUrl =
      '${Config.baseUrl}/api/v1';

  static Future<List<Category>> getActiveCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories/active'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Category>.from(data.map((model) => Category.fromJson(model)));
    } else {
      throw Exception('Failed to load active Categories');
    }
  }

  static Future<List<Category>> getInactiveCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories/inactive'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Category>.from(data.map((model) => Category.fromJson(model)));
    } else {
      throw Exception('Failed to load inactive Categories');
    }
  }

  static Future<void> deleteCategory(int categoryId) async {
    final response =
        await http.put(Uri.parse('$baseUrl/categories/disable/$categoryId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete Categories');
    }
  }

  static Future<void> activeCategory(int categoryId) async {
    final response =
        await http.put(Uri.parse('$baseUrl/categories/activate/$categoryId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to activate Categories');
    }
  }

  static Future<void> createCategory(Category category) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(category.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to create category: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> updateCategory(Category category) async {
    final response = await http.put(
      Uri.parse('$baseUrl/categories/${category.id}'), // Verifica la ruta aquí
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(category.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to update Category: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<bool> checkExistingCategory(String name) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/categories/exists?name=$name'));
      if (response.statusCode == 200) {
        // Si el nombre existe, retornar true
        return true;
      } else if (response.statusCode == 404) {
        // Si el nombre no existe, retornar false
        return false;
      } else {
        throw Exception('Failed to check category existence');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
