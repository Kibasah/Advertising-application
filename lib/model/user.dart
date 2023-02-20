class User {
  final String id;
  final String fullName;
  final String email;
  final String userRole;
  final String menuId;

  User(
      {required this.id,
      required this.fullName,
      required this.email,
      required this.userRole,
      required this.menuId});

  User.fromData(Map<String, dynamic> data)
      : id = data['id'],
        fullName = data['fullName'],
        email = data['email'],
        userRole = data['userRole'],
        menuId = data['menuId'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'userRole': userRole,
      'menuId': menuId,
    };
  }
}
