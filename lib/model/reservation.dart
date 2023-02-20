class Reservation {
  String id;
  String user_id;
  String menuId;
  DateTime time;
  String status;

  Reservation({
    required this.id,
    required this.user_id,
    required this.menuId,
    required this.time,
    required this.status,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      user_id: json['user_id'],
      menuId: json['menuId'],
      time: DateTime.parse(json['time']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user_id,
      'menuId': menuId,
      'time': time.toIso8601String(),
      'status': status,
    };
  }
}
