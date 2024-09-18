class Client {
  final int id;
  final String rolPerson;
  final String typeDocument;
  final String numberDocument;
  final String names;
  final String lastName;
  final String? email;
  final String? cellPhone;
  final DateTime? birthDate;
  final String active;

  Client({
    required this.id,
    required this.rolPerson,
    required this.typeDocument,
    required this.numberDocument,
    required this.names,
    required this.lastName,
    this.email,
    this.cellPhone,
    this.birthDate,
    required this.active,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json["id"] ?? 0,
      rolPerson: json["rolPerson"] ?? "",
      typeDocument: json["typeDocument"] ?? "",
      numberDocument: json["numberDocument"] ?? "",
      names: json["names"] ?? "",
      lastName: json["lastName"] ?? "",
      email: json["email"],
      cellPhone: json["cellPhone"],
      birthDate:
          json["birthdate"] != null ? DateTime.parse(json["birthdate"]) : null,
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
      'birthdate': birthDate?.toIso8601String(),
      'active': active,
    };
  }

  static Client empty() {
    return Client(
      id: 0,
      rolPerson: '',
      typeDocument: '',
      numberDocument: '',
      names: '',
      lastName: '',
      email: null,
      cellPhone: null,
      birthDate: null,
      active: '',
    );
  }
}
