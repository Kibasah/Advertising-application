import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vava/model/food.dart';
import 'package:vava/widget/homepage.dart';
import 'package:vava/widget/update_page.dart';

import '../views/supposed_main.dart';
import 'add_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(foodupdates());
}

class foodupdates extends StatelessWidget {
  static final String title = 'Add Food';

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: title,
    theme: ThemeData(
      primarySwatch: Colors.red,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(46),
          textStyle: TextStyle(fontSize: 24),
        ),
      ),
    ),
    home: HomePage(),
  );
}

class Foodupdate extends StatefulWidget {
  final String menuId;
  final String lat;
  final String long;

  Foodupdate({Key? key, required this.menuId, required this.lat, required this.long}) : super(key: key);

  @override
  _FoodupdateState createState() => _FoodupdateState(menuId: menuId, lat: lat, long: long);
}


class _FoodupdateState extends State<Foodupdate> {

  final String menuId;
  final String lat;
  final String long;
  final controller = TextEditingController();

  _FoodupdateState({required this.menuId, required this.lat, required this.long});


  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Menu'),
    ),
    body: buildFoods(menuId),
    // body: buildSingleFood(),
    floatingActionButton: FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => FoodaddPage(menuId: menuId, lat: lat,long:long),
        ));
      },
    ),
  );

  Widget buildFoods(String menuId) => StreamBuilder<List<Shop>>(
      stream: readShop(menuId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong! ${snapshot.error}');
        } else if (snapshot.hasData) {
          final shop = snapshot.data!;

          return ListView(
            children: shop.map(buildShop).toList(),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      });

  Widget buildSingleFood() => FutureBuilder<Shop?>(
    future: readFood(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text('Something went wrong! ${snapshot.error}');
      } else if (snapshot.hasData) {
        final food = snapshot.data;

        return food == null
            ? Center(child: Text('No Food'))
            : buildShop(food);
      } else {
        return Center(child: CircularProgressIndicator());
      }
    },
  );

  // This method is used to build a single user
  // It will be called by buildUsers() method
  // It will transform a User object into a ListTile
  // It will be used in ListView
  // will be used in update_page.dart
  // It will use the onTap() method to navigate to update_page.dart
  // It will pass the user object to update_page.dart
  // It will pass the map of user object to update_page.dart which has Shop? type
  Widget buildShop(Shop? shop) => ListTile(
    leading: CircleAvatar(backgroundImage: NetworkImage(shop!.imageUrl)),
    title: Text('Food: ${shop.food}'),
    subtitle: Text("RM: ${shop.price}     Remarks:  ${shop.remarks}"),
    onTap: () => Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FoodPage(shop: shop),
    )),
  );

  Stream<List<Shop>> readShop(String menuId) => FirebaseFirestore.instance
      .collection('Shop')
      .where('menuId', isEqualTo: menuId)
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map<Shop>((doc) => Shop.fromJson(doc.data())).toList());

}

Future<Shop?> readFood() async {
  /// Get single document by ID
  final docUser = FirebaseFirestore.instance.collection('Shop').doc();
  final snapshot = await docUser.get();

  if (snapshot.exists) {
    return Shop.fromJson(snapshot.data()!);
  }
}

Future createShop({required String food}) async {
  /// Reference to document
  final docUser = FirebaseFirestore.instance.collection('Shop').doc();

  final json = {
    'id': docUser.id,
    'food': food,
  };

  /// Create document and write data to Firebase
  await docUser.set(json);
}

class Dada extends StatefulWidget {
  @override
  Context(BuildContext context) {
    return context;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
