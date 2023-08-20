class Product {
  String localId;
  String image;
  String name;
  String description;
  int quantity;
  String status;

  Product({
    required this.localId,
    this.image = '',
    required this.name,
    required this.description,
    required this.quantity,
    required this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        localId: json['localId'] ?? '',
        image: json['image'],
        name: json['name'],
        description: json['description'],
        quantity: json['quantity'],
        status: json['status'],);
  }

  Map<String, dynamic> toJson() => {
        'localId': localId,
        'image': image,
        'name': name,
        'description': description,
        'quantity': quantity,
        'status': status,
      };
}
