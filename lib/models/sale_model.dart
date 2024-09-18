import 'package:myapp/models/client_model.dart';
import 'package:myapp/models/paymentMethod_model.dart';
import 'package:myapp/models/sale_detail_model.dart';
import 'package:myapp/models/seller_model.dart';

class Sale {
  int? id;
  Client client;
  Seller seller;
  PaymentMethod paymentMethod;
  String dateTime;
  String active;
  List<SaleDetail> saleDetails;
  String? clientNames;
  String? sellerNames;
  String? formattedDateTime;
  double? totalSale;

  Sale({
    this.id,
    required this.client,
    required this.seller,
    required this.paymentMethod,
    required this.dateTime,
    this.active = 'A',
    required this.saleDetails,
    this.clientNames,
    this.sellerNames,
    this.formattedDateTime,
    this.totalSale,
  });

  factory Sale.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('Failed to parse JSON');
    }

    return Sale(
      id: json['id'],
      client: Client.fromJson(json['client'] ?? {}),
      seller: Seller.fromJson(json['seller'] ?? {}),
      paymentMethod: PaymentMethod.fromJson(json['paymentMethod'] ?? {}),
      dateTime: json['dateTime'] ?? '',
      active: json["active"] ?? "A",
      saleDetails: (json['saleDetails'] as List<dynamic>?)
              ?.map((e) => SaleDetail.fromJson(e))
              .toList() ??
          [],
      clientNames: json['clientNames'] ?? '',
      sellerNames: json['sellerNames'] ?? '',
      formattedDateTime: json['formattedDateTime'] ?? '',
      totalSale: json['totalSale']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client': client.toJson(),
      'seller': seller.toJson(),
      'paymentMethod': paymentMethod.toJson(),
      'dateTime': dateTime,
      'active': active,
      'saleDetails': saleDetails.map((i) => i.toJson()).toList(),
      'clientNames': clientNames,
      'sellerNames': sellerNames,
      'formattedDateTime': formattedDateTime,
      'totalSale': totalSale,
    };
  }

  static Sale empty() {
    return Sale(
      id: null,
      client: Client.empty(),
      seller: Seller.empty(),
      paymentMethod: PaymentMethod.empty(),
      dateTime: DateTime.now().toIso8601String(),
      active: 'A',
      saleDetails: [],
    );
  }
}
