class Location {
  final String latitude;
  final String longitude;
  final String uid;

  Location({required this.latitude, required this.longitude, required this.uid});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'],
      longitude: json['longitude'],
      uid: json['uid'],
    );
  }
}
