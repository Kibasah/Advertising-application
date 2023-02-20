import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vava/model/restaurant.dart';
import 'package:vava/views/rest_reservations.dart';
import 'package:vava/views/update_restaurant.dart';
import '../widget/food_list.dart';
import 'addRestaurantUser.dart';
//papa
class RestaurantDetailsPage extends StatefulWidget {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  _RestaurantDetailsPageState createState() => _RestaurantDetailsPageState();
}


class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  bool _isOpen = false;


  @override
  void initState() {
    super.initState();
    _getRestaurants();
  }

  Future<List<Restaurant>> _getRestaurants() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Restaurants')
        .where('UID', isEqualTo: widget.uid)
        .get();
    List<Restaurant> restaurants = [];
    for (var document in snapshot.docs) {
      var restaurant = Restaurant.fromJson(document.data() as Map<String, dynamic>);
      restaurants.add(restaurant);
    }
    print('Number of restaurants: ${restaurants.length}');
    return restaurants;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  text: 'Want to add your restaurant? ',
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RestaurantsAddPage()),
                          );
                        },
                      text: 'Register Restaurant',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10),
              child: Text("Restaurant Details"),
            ),
          ],
        ),
      ),

        body:
      FutureBuilder(
        future: _getRestaurants(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              var restaurants = snapshot.data;
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 1000,
                  childAspectRatio: 2.5,
                ),
                itemCount: restaurants.length,
                itemBuilder: (BuildContext context, int index) {
                  var restaurant = restaurants[index];
                  return Card(
                    margin: EdgeInsets.all(16),
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            restaurant.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            restaurant.location,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddRestaurantPage(
                                        restaurant: restaurant,
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Update Restaurant Info'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Foodupdate(
                                        menuId: restaurant.menuId,
                                        key: null,
                                        lat: restaurant.latitude,
                                        long: restaurant.longitude,
                                      ),
                                    ),
                                  );
                                },
                                child: Text('View Food'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReservationsPage(
                                        restaurant: restaurant,
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Pending Reservations'),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                restaurant.isOpen ? 'Shop is open' : 'Shop is closed',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Switch(
                                value: restaurant.isOpen,
                                onChanged: (value) async {
                                  bool success = await updateRestaurantStatus(value, restaurant);
                                  if (success) {
                                    setState(() {
                                      restaurant.isOpen = value;
                                    });
                                  } else {
                                    // Show an error message to the user
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );


            } else {
              return Center(
                child: Text("No data found"),
              );
            }
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Future<bool> updateRestaurantStatus(bool isOpen, Restaurant restaurant) async {
    try {
      await FirebaseFirestore.instance
          .collection('Restaurants')
          .doc(restaurant.id)
          .update({'isOpen': isOpen});

      await FirebaseFirestore.instance
          .collection('Shop')
          .where('menuId', isEqualTo: restaurant.menuId)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          await doc.reference.update({'isOpen': isOpen});
        });
      });

      return true;
    } catch (e) {
      print('Failed to update restaurant status: $e');
      return false;
    }
  }



}
