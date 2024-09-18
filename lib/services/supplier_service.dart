import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/config.dart';
import 'package:myapp/models/supplier_model.dart';

class ApiServiceSupplier {
  static const String baseUrl =
      '${Config.baseUrl}/api/v1';

  static Future<List<Supplier>> getActiveSuppliers() async {
    final response = await http.get(Uri.parse('$baseUrl/suppliers/active'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Supplier>.from(data.map((model) => Supplier.fromJson(model)));
    } else {
      throw Exception('Failed to load active Proveedores');
    }
  }

  static Future<List<Supplier>> getInactiveSuppliers() async {
    final response = await http.get(Uri.parse('$baseUrl/suppliers/inactive'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Supplier>.from(data.map((model) => Supplier.fromJson(model)));
    } else {
      throw Exception('Failed to load inactive Proveedores');
    }
  }

  static Future<void> deleteSupplier(int supplierId) async {
    final response =
        await http.put(Uri.parse('$baseUrl/suppliers/disable/$supplierId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete Proveedores');
    }
  }

  static Future<void> activeSupplier(int supplierId) async {
    final response =
        await http.put(Uri.parse('$baseUrl/suppliers/activate/$supplierId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to activate Proveedores');
    }
  }

  static Future<void> createSupplier(Supplier supplier) async {
    final response = await http.post(
      Uri.parse('$baseUrl/suppliers'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(supplier.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to create Proveedor: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> updateSupplier(Supplier supplier) async {
    final response = await http.put(
      Uri.parse('$baseUrl/suppliers/${supplier.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(supplier.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to update Proveedor: ${response.statusCode} - ${response.body}');
    }
  }

  // Función para verificar si existe un suppliere con el número de documento dado
  static Future<bool> checkExistingSupplier(String documentNumber) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/suppliers/exists?numberDocument=$documentNumber'));
      if (response.statusCode == 200) {
        return true; // Si existe un suppliere con ese número de documento
      } else if (response.statusCode == 404) {
        return false; // Si no existe un suppliere con ese número de documento
      } else {
        throw Exception('Failed to check Proveedor existence');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
