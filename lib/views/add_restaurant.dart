import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vava/model/restaurant.dart';
import 'package:vava/views/add_page_restaurant.dart';
import 'package:vava/views/update_restaurant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


import 'admin_rest_choice.dart';

class RestaurantUpdate extends StatefulWidget {
  @override
  _RestaurantUpdate createState() => _RestaurantUpdate();
}

class _RestaurantUpdate extends State<RestaurantUpdate> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('All Restaurants'),
        ),
        body: buildRestaurants(),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => RestaurantsAddPage(),
            ));
          },
        ),
      );

  Widget buildRestaurants() => StreamBuilder<List<Restaurant>>(
      stream: readRestaurant(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong ss! ${snapshot.error}');
        } else if (snapshot.hasData) {
          final restaurant = snapshot.data!;

          return ListView(
            children: restaurant.map(buildRestaurant).toList(),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      });

  Widget buildSingleRestaurant() => FutureBuilder<Restaurant?>(
        future: readRestaurants(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrongaaa! ${snapshot.error}');
          } else if (snapshot.hasData) {
            final restaurant = snapshot.data;

            return restaurant == null
                ? Center(child: Text('No restaurant'))
                : buildRestaurant(restaurant);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );

  Widget buildRestaurant(Restaurant? restaurant) => restaurant == null
      ? Center(child: Text('No restaurant'))
      : ListTile(
          leading: CircleAvatar(child: Text(restaurant.name)),
          title: Text(restaurant.name),
          subtitle: Text(restaurant.location),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => RestaurantDetailsPage(restaurant: restaurant),
          )),
        );

  Stream<List<Restaurant>> readRestaurant() => FirebaseFirestore.instance
      .collection('Restaurants')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map<Restaurant>((doc) => Restaurant.fromJson(doc.data()))
          .toList());
}

Future<Restaurant?> readRestaurants() async {
  final docUser = FirebaseFirestore.instance.collection('Restaurants').doc();
  final snapshot = await docUser.get();

  if (snapshot.exists) {
    return Restaurant.fromJson(snapshot.data()!);
  } else {
    return null;
  }
}

Future createRestaurant({required String restaurant}) async {
  /// Reference to document
  final docUser = FirebaseFirestore.instance.collection('Restaurants').doc();

  final json = {
    'id': docUser.id,
    'name': restaurant,
  };

  /// Create document and write data to Firebase
  await docUser.set(json);
}
