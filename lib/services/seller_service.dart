import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/config.dart';
import 'package:myapp/models/seller_model.dart';

class ApiServiceSeller {
  static const String baseUrl =
      '${Config.baseUrl}/api/v1';

  static Future<List<Seller>> getActiveSellers() async {
    final response = await http.get(Uri.parse('$baseUrl/sellers/active'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Seller>.from(data.map((model) => Seller.fromJson(model)));
    } else {
      throw Exception('Failed to load active Sellers');
    }
  }

  static Future<List<Seller>> getInactiveSellers() async {
    final response = await http.get(Uri.parse('$baseUrl/sellers/inactive'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Seller>.from(data.map((model) => Seller.fromJson(model)));
    } else {
      throw Exception('Failed to load inactive Sellers');
    }
  }


  static Future<void> deleteSeller(int sellerId) async {
    final response =
        await http.put(Uri.parse('$baseUrl/sellers/disable/$sellerId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete sellers');
    }
  }

  static Future<void> activeSeller(int sellerId) async {
    final response =
        await http.put(Uri.parse('$baseUrl/sellers/activate/$sellerId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to activate sellers');
    }
  }

  static Future<void> createSeller(Seller seller) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sellers'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(seller.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to create seller: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> updateSeller(Seller seller) async {
    final response = await http.put(
      Uri.parse('$baseUrl/sellers/${seller.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(seller.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to update seller: ${response.statusCode} - ${response.body}');
    }
  }

  // Función para verificar si existe un vendedor con el número de documento dado
  static Future<bool> checkExistingSeller(String documentNumber) async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/sellers/exists?numberDocument=$documentNumber'));
      if (response.statusCode == 200) {
        return true; // Si existe un seller con ese número de documento
      } else if (response.statusCode == 404) {
        return false; // Si no existe un seller con ese número de documento
      } else {
        throw Exception('Failed to check seller existence');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
