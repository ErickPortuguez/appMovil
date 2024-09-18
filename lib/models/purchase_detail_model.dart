import 'package:myapp/models/product_model.dart';

class PurchaseDetail {
  int? id;
  Product product;
  double amount;
  double priceUnit;

  PurchaseDetail({
    this.id,
    required this.product,
    required this.amount,
    required this.priceUnit,
  });

  factory PurchaseDetail.fromJson(Map<String, dynamic> json) {
    return PurchaseDetail(
      id: json['id'],
      product: Product.fromJson(json['product']),
      amount: json['amount']?.toDouble(),
      priceUnit: json['priceUnit']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'amount': amount,
      'priceUnit': priceUnit,
    };
  }
}
