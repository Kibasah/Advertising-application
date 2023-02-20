

class Shop {
  String id;
  final String food;
  final int price;
  final String remarks;
  final String menuId;
  final String description;
  final String remarks2;
  String imageUrl; // <-- added this line
  final String lat;
  final String long;

  Shop({
    this.id = '',
    required this.food,
    required this.price,
    required this.remarks,
    required this.menuId,
    this.description = '',
    this.remarks2 = '',
    this.imageUrl = '', // <-- added this line
    this.lat = '',
    this.long='',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'food': food,
        'Price': price,
        'Remarks': remarks,
        'menuId': menuId,
        'description': description,
        'remarks2': remarks2,
        'imageUrl': imageUrl, // <-- added this line
        'lat': lat,
        'long': long,
      };

  static Shop fromJson(Map<String, dynamic> json) => Shop(
      id: json['id'],
      food: json['food'],
      price: json['Price'],
      remarks: json['Remarks'],
      menuId: json['menuId'],
      description: json['description'],
      remarks2: json['remarks2'],
      imageUrl: json['imageUrl'], // <-- added this line
      lat: json['lat'],
      long: json['long'],
      );
}
