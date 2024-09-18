import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/config.dart';
import 'package:myapp/models/sale_model.dart'; // Asegúrate de tener este archivo

class SaleService {
  static const String baseUrl = '${Config.baseUrl}/api/sales';

  static Future<List<Sale>> getActiveSales() async {
    final response = await http.get(Uri.parse('$baseUrl/status/A'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Sale>.from(data.map((model) => Sale.fromJson(model)));
    } else {
      throw Exception('Failed to load active sales');
    }
  }

  static Future<List<Sale>> getInactiveSales() async {
    final response = await http.get(Uri.parse('$baseUrl/status/I'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Sale>.from(data.map((model) => Sale.fromJson(model)));
    } else {
      throw Exception('Failed to load inactive sales');
    }
  }

  static Future<Sale> getSaleById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Sale.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load sale');
    }
  }

  static Future<void> createSale(Sale sale) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(sale.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to create sale: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> updateSale(int id, Sale sale) async {
    final url = Uri.parse('$baseUrl/$id');
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    final body = jsonEncode(sale.toJson());

    try {
      final response = await http.put(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        // Handle success case
      } else {
        throw Exception(
            'Failed to update sale: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update sale: $e');
    }
  }

  static Future<void> logicalDeleteSale(int id) async {
    final response = await http.put(Uri.parse('$baseUrl/delete/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to logically delete sale');
    }
  }

  static Future<void> activateSale(int id) async {
    final response = await http.put(Uri.parse('$baseUrl/activate/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to activate sale');
    }
  }
}
