import 'package:myapp/models/paymentMethod_model.dart';
import 'package:myapp/models/purchase_detail_model.dart';
import 'package:myapp/models/seller_model.dart';
import 'package:myapp/models/supplier_model.dart';

class Purchase {
  int? id;
  Supplier supplier;
  Seller seller;
  PaymentMethod paymentMethod;
  String dateTime;
  String active;
  List<PurchaseDetail> purchaseDetails;
  String? supplierNames;
  String? sellerNames;
  String? formattedDateTime;
  double? totalPurchase;

  Purchase({
    this.id,
    required this.supplier,
    required this.seller,
    required this.paymentMethod,
    required this.dateTime,
    this.active = 'A',
    required this.purchaseDetails,
    this.supplierNames,
    this.sellerNames,
    this.formattedDateTime,
    this.totalPurchase,
  });

  factory Purchase.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('Failed to parse JSON');
    }

    return Purchase(
      id: json['id'],
      supplier: Supplier.fromJson(json['supplier'] ?? {}),
      seller: Seller.fromJson(json['seller'] ?? {}),
      paymentMethod: PaymentMethod.fromJson(json['paymentMethod'] ?? {}),
      dateTime: json['dateTime'] ?? '',
      active: json["active"] ?? "A",
      purchaseDetails: (json['purchaseDetails'] as List<dynamic>?)
              ?.map((e) => PurchaseDetail.fromJson(e))
              .toList() ??
          [],
      supplierNames: json['supplierNames'] ?? '',
      sellerNames: json['sellerNames'] ?? '',
      formattedDateTime: json['formattedDateTime'] ?? '',
      totalPurchase: json['totalPurchase']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier': supplier.toJson(),
      'seller': seller.toJson(),
      'paymentMethod': paymentMethod.toJson(),
      'dateTime': dateTime,
      'active': active,
      'purchaseDetails': purchaseDetails.map((i) => i.toJson()).toList(),
      'supplierNames': supplierNames,
      'sellerNames': sellerNames,
      'formattedDateTime': formattedDateTime,
      'totalPurchase': totalPurchase,
    };
  }

  static Purchase empty() {
    return Purchase(
      id: null,
      supplier: Supplier.empty(),
      seller: Seller.empty(),
      paymentMethod: PaymentMethod.empty(),
      dateTime: DateTime.now().toIso8601String(),
      active: 'A',
      purchaseDetails: [],
    );
  }
}
