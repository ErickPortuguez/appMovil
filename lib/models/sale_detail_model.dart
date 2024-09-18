import 'package:myapp/models/product_model.dart';

class SaleDetail {
  int? id;
  Product product;
  double amount;

  SaleDetail({
    this.id,
    required this.product,
    required this.amount,
  });

  factory SaleDetail.fromJson(Map<String, dynamic> json) {
    return SaleDetail(
      id: json['id'],
      product: Product.fromJson(json['product']),
      amount: json['amount']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'amount': amount,
    };
  }
}
