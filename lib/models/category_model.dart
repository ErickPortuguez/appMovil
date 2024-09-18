class Category {
  final int id;
  final String name;
  final String description;
  final String active;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.active,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
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

  static Category empty() {
    return Category(
    id: 0,
    name: '',
    description: '',
    active: '',
    );
  }
  
}
