import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/config.dart';
import 'package:myapp/models/purchase_model.dart'; // Asegúrate de tener este archivo

class PurchaseService {
  static const String baseUrl =
      '${Config.baseUrl}/api/purchases';

  static Future<List<Purchase>> getActivePurchases() async {
    final response = await http.get(Uri.parse('$baseUrl/status/A'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Purchase>.from(data.map((model) => Purchase.fromJson(model)));
    } else {
      throw Exception('Failed to load active purchases');
    }
  }

  static Future<List<Purchase>> getInactivePurchases() async {
    final response = await http.get(Uri.parse('$baseUrl/status/I'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Purchase>.from(data.map((model) => Purchase.fromJson(model)));
    } else {
      throw Exception('Failed to load inactive purchases');
    }
  }

  static Future<Purchase> getPurchaseById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Purchase.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load purchase');
    }
  }

  static Future<void> createPurchase(Purchase purchase) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(purchase.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to create purchase: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> updatePurchase(int id, Purchase purchase) async {
    final url = Uri.parse('$baseUrl/$id');
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    final body = jsonEncode(purchase.toJson());

    try {
      final response = await http.put(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        // Handle success case
      } else {
        throw Exception(
            'Failed to update purchase: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update purchase: $e');
    }
  }

  static Future<void> logicalDeletePurchase(int id) async {
    final response = await http.put(Uri.parse('$baseUrl/delete/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to logically delete purchase');
    }
  }

  static Future<void> activatePurchase(int id) async {
    final response = await http.put(Uri.parse('$baseUrl/activate/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to activate purchase');
    }
  }
}
