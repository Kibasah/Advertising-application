import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vava/model/restaurant.dart';
import 'package:vava/views/add_page_restaurant.dart';
import 'package:vava/views/update_restaurant.dart';

class PendingRestaurantsPage extends StatefulWidget {
  @override
  _PendingRestaurantsPage createState() => _PendingRestaurantsPage();
}

class _PendingRestaurantsPage extends State<PendingRestaurantsPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Pending restaurant verification'),
    ),
    body: buildRestaurants(),

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


  Widget buildRestaurant(Restaurant? restaurant) => restaurant == null
      ? Center(child: Text('No Pending Restaurants'))
      : Card(
    child: Container(
      height: 150,
      child: ListTile(
        leading: CircleAvatar(child: Text(restaurant.name[0])),
        title: Text(restaurant.name),
        subtitle: Text(restaurant.location),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddRestaurantPage(restaurant: restaurant),
        )),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check, color: Colors.green),
              onPressed: () => verifyRestaurant(restaurant),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () => declineRestaurant(restaurant),
            ),
          ],
        ),

      ),
    ),
  );


  Stream<List<Restaurant>> readRestaurant() => FirebaseFirestore.instance
      .collection('pending_restaurants')
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map<Restaurant>((doc) => Restaurant.fromJson(doc.data()))
      .toList());
}

void verifyRestaurant(Restaurant restaurant) async {
  // Add the restaurant to the Restaurants collection with a new ID
  final docRef = FirebaseFirestore.instance.collection("Restaurants").doc();
  final newId = docRef.id; // Get the new ID
  await docRef.set({...restaurant.toJson(), 'id': newId});

  // Update the verified restaurant document with the new ID
  await FirebaseFirestore.instance
      .collection("Restaurants")
      .doc(restaurant.id)
      .delete();

  // Delete the pending restaurant document
  await FirebaseFirestore.instance
      .collection("pending_restaurants")
      .doc(restaurant.id)
      .delete();
}




void declineRestaurant(Restaurant restaurant) async {
  await FirebaseFirestore.instance
      .collection('pending_restaurants')
      .doc(restaurant.id)
      .delete();
}



