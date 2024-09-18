import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/config.dart';
import 'package:myapp/models/paymentMethod_model.dart';

class ApiServicePaymentMethod {
  static const String baseUrl = '${Config.baseUrl}/api/v1';

  static Future<List<PaymentMethod>> getActivePaymentMethods() async {
    final response = await http.get(Uri.parse('$baseUrl/paymentMethod/active'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<PaymentMethod>.from(
          data.map((model) => PaymentMethod.fromJson(model)));
    } else {
      throw Exception('Failed to load active paymentMethod');
    }
  }

  static Future<List<PaymentMethod>> getInactivePaymentMethods() async {
    final response =
        await http.get(Uri.parse('$baseUrl/paymentMethod/inactive'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<PaymentMethod>.from(
          data.map((model) => PaymentMethod.fromJson(model)));
    } else {
      throw Exception('Failed to load inactive paymentMethod');
    }
  }
}
