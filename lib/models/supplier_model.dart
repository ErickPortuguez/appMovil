class Supplier {
  final int id;
  final String ruc;
  final String nameCompany;
  final String typeDocument;
  final String numberDocument;
  final String names;
  final String lastName;
  final String email;
  final String cellPhone;
  final String active;

  Supplier({
    required this.id,
    required this.ruc,
    required this.nameCompany,
    required this.typeDocument,
    required this.numberDocument,
    required this.names,
    required this.lastName,
    required this.email,
    required this.cellPhone,
    required this.active,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json["id"] ?? 0,
      ruc: json["ruc"] ?? "",
      nameCompany: json["nameCompany"] ?? "",
      typeDocument: json["typeDocument"] ?? "",
      numberDocument: json["numberDocument"] ?? "",
      names: json["names"] ?? "",
      lastName: json["lastName"] ?? "",
      email: json["email"] ?? "",
      cellPhone: json["cellPhone"] ?? "",
      active: json["active"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ruc': ruc,
      'nameCompany': nameCompany,
      'typeDocument': typeDocument,
      'numberDocument': numberDocument,
      'names': names,
      'lastName': lastName,
      'email': email,
      'cellPhone': cellPhone,
      'active': active,
    };
  }

  static Supplier empty() {
    return Supplier(
      id: 0,
      ruc: '',
      nameCompany: '',
      typeDocument: '',
      numberDocument: '',
      names: '',
      lastName: '',
      email: '',
      cellPhone: '',
      active: '',
    );
  }
}
