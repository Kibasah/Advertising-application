import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  String id;
  final String name;
  final String location;
  final String address;
  final String phone_number;
  final String cuisine;
  final String price_range;
  final String email;
  String latitude;
  String longitude;
  final String menuId;
  final String UID;
  String imageUrl;
  bool isOpen;
  Stream<DocumentSnapshot> menuStream;

  Restaurant(
      {this.id = '',
        required this.name,
        required this.location,
        required this.address,
        required this.phone_number,
        required this.cuisine,
        required this.price_range,
        required this.email,
        required this.latitude,
        required this.longitude,
        required this.menuId,
        required this.UID,
        this.imageUrl = '',
        this.isOpen = true,
      })
      : menuStream = FirebaseFirestore.instance
      .collection('Shop')
      .doc(menuId)
      .snapshots();



  static Restaurant fromJson(Map<String, dynamic> json) => Restaurant(
    id: json['id'],
    name: json['name'],
    location: json['location'],
    address: json['address'],
    phone_number: json['phone_number'],
    cuisine: json['cuisine'],
    price_range: json['price_range'],
    email: json['email'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    menuId: json['menuId'],
    UID: json['UID'],
    imageUrl: json['imageUrl'],
    isOpen: json['isOpen'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'address': address,
    'phone_number': phone_number,
    'cuisine': cuisine,
    'price_range': price_range,
    'email': email,
    'latitude': latitude,
    'longitude': longitude,
    'menuId': menuId,
    'UID': UID,
    'imageUrl': imageUrl,
    'isOpen': isOpen,
  };
}
