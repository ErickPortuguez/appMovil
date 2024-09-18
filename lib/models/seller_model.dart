class Seller {
  final int id;
  final String rolPerson;
  final String typeDocument;
  final String numberDocument;
  final String names;
  final String lastName;
  final String email;
  final String cellPhone;
  final double salary;
  final String sellerRol;
  final String sellerUser;
  final String sellerPassword;
  final String active;

  Seller({
    required this.id,
    required this.rolPerson,
    required this.typeDocument,
    required this.numberDocument,
    required this.names,
    required this.lastName,
    required this.email,
    required this.cellPhone,
    required this.salary,
    required this.sellerRol,
    required this.sellerUser,
    required this.sellerPassword,
    required this.active,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json["id"] ?? 0,
      rolPerson: json["rolPerson"] ?? "",
      typeDocument: json["typeDocument"] ?? "",
      numberDocument: json["numberDocument"] ?? "",
      names: json["names"] ?? "",
      lastName: json["lastName"] ?? "",
      email: json["email"] ?? "",
      cellPhone: json["cellPhone"] ?? "",
      salary: (json["salary"] != null)
          ? (json["salary"] is String)
              ? double.tryParse(json["salary"]) ?? 0.0
              : json["salary"].toDouble()
          : 0.0,
      sellerRol: json["sellerRol"] ?? "",
      sellerUser: json["sellerUser"] ?? "",
      sellerPassword: json["sellerPassword"] ?? "",
      active: json["active"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rolPerson': rolPerson,
      'typeDocument': typeDocument,
      'numberDocument': numberDocument,
      'names': names,
      'lastName': lastName,
      'email': email,
      'cellPhone': cellPhone,
      'salary': salary,
      'sellerRol': sellerRol,
      'sellerUser': sellerUser,
      'sellerPassword': sellerPassword,
      'active': active,
    };
  }

  static Seller empty() {
    return Seller(
      id: 0,
      rolPerson: '',
      typeDocument: '',
      numberDocument: '',
      names: '',
      lastName: '',
      email: '',
      cellPhone: '',
      salary: 0.0,
      sellerRol: '',
      sellerUser: '',
      sellerPassword: '',
      active: '',
    );
  }
}
