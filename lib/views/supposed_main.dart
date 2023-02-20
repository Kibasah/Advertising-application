import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vava/model/restaurant.dart';
import 'package:vava/views/menu_rest.dart';
import 'dart:math';
import '../model/location.dart';
import '../widget/homepage.dart';
import 'add_restaurant.dart';
import 'list_reservations.dart';
import 'map_page.dart';

class RestaurantMenu extends StatefulWidget {
  @override
  _RestaurantMenu createState() => _RestaurantMenu();
}

class _RestaurantMenu extends State<RestaurantMenu> {
  double _geofenceDistance = 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shops near you'),
      ),
      body: Column(
        children: [
          Slider(
            value: _geofenceDistance,
            min: 100,
            max: 5000,
            divisions: 49,
            label: '${_geofenceDistance.round()} m',
            onChanged: (value) {
              setState(() {
                _geofenceDistance = value;
              });
            },
          ),
          Expanded(child: buildRestaurants()),
        ],
      ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'Restaurants',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Restaurants',
            ),
          ],
          onTap: (int index) {
            switch (index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapPage()),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RestaurantMenu()),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>ReservationsPage()),
                );
            }
          },
        )
    );
  }






  Widget buildRestaurants() => StreamBuilder<List<Restaurant>>(
      stream: readRestaurant(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong ss! ${snapshot.error}');
        } else if (snapshot.hasData) {
          final restaurants = snapshot.data!;
          return FutureBuilder<Location>(
            future: getUserLocation(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong! ${snapshot.error}');
              } else if (snapshot.hasData) {
                final userLocation = snapshot.data!;
                restaurants.sort((r1, r2) {
                  double distance1 = calculateDistance(
                      double.parse(userLocation.latitude),
                      double.parse(userLocation.longitude),
                      double.parse(r1.latitude),
                      double.parse(r1.longitude));
                  double distance2 = calculateDistance(
                      double.parse(userLocation.latitude),
                      double.parse(userLocation.longitude),
                      double.parse(r2.latitude),
                      double.parse(r2.longitude));
                  return distance1.compareTo(distance2);
                });
                return GridView.count(
                  crossAxisCount: 2, // Number of columns
                  mainAxisSpacing: 0, // Space between rows
                  crossAxisSpacing: 0, // Space between columns
                  children: restaurants.map((r) => buildRestaurant(r)).toList(),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      });


  Widget buildRestaurant(Restaurant? restaurant) {
    if (restaurant == null) {
      return Center(child: Text('No restaurant'));
    }
    if (!restaurant.isOpen) {
      return Container(); // return an empty Container widget if the restaurant is not open
    }
    // rest of the code
    return FutureBuilder<Location>(
      future: getUserLocation(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong! ${snapshot.error}');
        } else if (snapshot.hasData) {
          final userLocation = snapshot.data;
          double distance = 0.0;
          if (userLocation != null) {
            double userLat;
            double userLong;
            double restLat;
            double restLong;

            try {
              userLat = double.parse(userLocation.latitude);
              userLong = double.parse(userLocation.longitude);
              restLat = double.parse(restaurant.latitude);
              restLong = double.parse(restaurant.longitude);
            } on FormatException {
              return Text(
                  'Could not parse the latitude and longitude values');
            }

            distance = calculateDistance(
                userLat,
                userLong,
                restLat,
                restLong
            );
          }
          if (distance <= _geofenceDistance) {
            return InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => MenuPage(restaurant: restaurant),
            )),
              child: Container(
                height: 300,
                width: 300,
                  child: Card(
                    margin: EdgeInsets.all(16.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                        child: Image.network(
                        restaurant.imageUrl,
                        fit: BoxFit.cover,
                        height: 250,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Distance: ${distance.round()} meters",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Cuisine:",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                restaurant.cuisine,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Price range:",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                restaurant.price_range,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            );


          } else {
            return Container();
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );


  }



  Stream<List<Restaurant>> readRestaurant() => FirebaseFirestore.instance
      .collection('Restaurants')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map<Restaurant>((doc) => Restaurant.fromJson(doc.data()))
          .toList());


}

Future<Location> getUserLocation() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not signed in");
      return Future.error("User not signed in");
    }

    final uid = user.uid;
    print("User's uid: $uid");
    final querySnapshot = await FirebaseFirestore.instance.collection('Locasi').where('uid', isEqualTo: uid).get();

    if (querySnapshot.docs.isNotEmpty) {
      final docUser = querySnapshot.docs.first;
      return Location.fromJson(docUser.data() as Map<String, dynamic>);
    } else {
      throw Exception("Document not found");
    }
  } catch (e) {
    print('An error occurred: $e');
    return Future.error(e);
  }
}



double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  final earthRadius = 6371 * 1000; // Earth's radius in kilometers

  final dLat = radians(lat2 - lat1);
  final dLon = radians(lon2 - lon1);

  lat1 = radians(lat1);
  lat2 = radians(lat2);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

double radians(double deg) {
  return deg * (pi / 180);
}
