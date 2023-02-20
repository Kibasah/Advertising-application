import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/user.dart';

class FirestoreService {
  final CollectionReference _usersCollectionReference =
      FirebaseFirestore.instance.collection('users');

  Future createUser(User user) async {
    try {
      await _usersCollectionReference.doc(user.id).set(user.toJson());
    } catch (e) {
      return e.toString;
    }
  }
}
