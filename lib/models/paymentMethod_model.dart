class PaymentMethod {
  final int id;
  final String name;
  final String description;
  final String active;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.active,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      active: json["active"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'active': active,
    };
  }

  static PaymentMethod empty() {
    return PaymentMethod(
      id: 0,
      name: '',
      description: '',
      active: '',
    );
  }
}
