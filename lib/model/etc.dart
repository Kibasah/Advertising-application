

class etc {
  final int count;

  etc({required this.count});

  Map<String, dynamic> toJson() => {'count': count};

  static etc fromJson(Map<String, dynamic> json) => etc(count: json['count']);
}
