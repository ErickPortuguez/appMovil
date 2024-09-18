import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/config.dart';
import 'package:myapp/models/client_model.dart';

class ApiServiceClient {
  static const String baseUrl =
       '${Config.baseUrl}/api/v1';

   static Future<List<Client>> getActiveClients() async {
    final response = await http.get(Uri.parse('$baseUrl/clients/active'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Client>.from(data.map((model) => Client.fromJson(model)));
    } else {
      throw Exception('Failed to load active clients');
    }
  }

  static Future<List<Client>> getInactiveClients() async {
    final response = await http.get(Uri.parse('$baseUrl/clients/inactive'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Client>.from(data.map((model) => Client.fromJson(model)));
    } else {
      throw Exception('Failed to load inactive clients');
    }
  }


  static Future<void> deleteClient(int clientId) async {
    final response =
        await http.put(Uri.parse('$baseUrl/clients/disable/$clientId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete clients');
    }
  }

  static Future<void> activeClient(int clientId) async {
    final response =
        await http.put(Uri.parse('$baseUrl/clients/activate/$clientId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to activate clients');
    }
  }

  static Future<void> createClient(Client client) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clients'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(client.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to create client: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> updateClient(Client client) async {
    final response = await http.put(
      Uri.parse('$baseUrl/clients/${client.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(client.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to update client: ${response.statusCode} - ${response.body}');
    }
  }

  // Función para verificar si existe un cliente con el número de documento dado
  static Future<bool> checkExistingClient(String documentNumber) async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/clients/exists?numberDocument=$documentNumber'));
      if (response.statusCode == 200) {
        return true; // Si existe un cliente con ese número de documento
      } else if (response.statusCode == 404) {
        return false; // Si no existe un cliente con ese número de documento
      } else {
        throw Exception('Failed to check client existence');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
