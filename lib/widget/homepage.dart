import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'package:vava/widget/add_page.dart';
import 'package:vava/model/food.dart';
import 'package:vava/views/supposed_main.dart';
//import 'package:vava/misc/actioninfo.dart';
//import 'package:vava/widget/update_page.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../views/list_reservations.dart';
import '../views/map_page.dart';
import '../views/profile_about.dart';
import '../views/restaurant_dashboard.dart';
import 'admin_main.dart';
import 'food_desc.dart';
import 'dart:math';

class GlobalContextService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String lat = '';
  String long = '';
  late StreamSubscription _positionStream ;
  double distance = 1000;



  @override
  void initState() {
    super.initState();
    _positionStream = _liveLocation();
    _determinePosition();
    Geolocator.getCurrentPosition().then((position) {
      setState(() {
        lat = position.latitude.toString();
        long = position.longitude.toString();
        String uid = FirebaseAuth.instance.currentUser!.uid;
        FirebaseFirestore.instance.collection("Locasi")
            .where("uid", isEqualTo: uid)
            .get()
            .then((QuerySnapshot snapshot) {
          if (snapshot.docs.isNotEmpty) {
            FirebaseFirestore.instance.collection("Locasi")
                .doc(snapshot.docs[0].id)
                .update({
              "uid": uid,
              "latitude": lat,
              "longitude": long
            });
          } else {
            FirebaseFirestore.instance.collection("Locasi").add({
              "uid": uid,
              "latitude": lat,
              "longitude": long,
            });
          }
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _positionStream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
        appBar: AppBar(
          title: Text('Home'),
          actions: [
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text("Sign Out"),
                onTap: () => FirebaseAuth.instance.signOut(),
              ),
              currentUserUid == '3CVULpOrD0XpvT3CPFafyfzSSuJ2'
                  ? ListTile(
                leading: Icon(Icons.settings),
                title: Text("Admin Interface"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminDashboard()),
                  );
                },
              )
                  : Container(),
              ListTile(
                leading: Icon(Icons.info),
                title: Text("About"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutPage()),
                  );

                },
              ),
              Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.restaurant),
                    title: Text("Manage Your Restaurant"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RestaurantDetailsPage()),
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.directions_bike),
                    title: Text("Adjust Distance"),
                  ),
                  ListTile(
                    title: Text('500 meters'),
                    selected: distance == 500,
                    onTap: () {
                      setState(() {
                        distance = 500;
                        Navigator.pop(context);
                      });
                    },
                  ),
                  ListTile(
                    title: Text('1000 meters'),
                    selected: distance == 1000,
                    onTap: () {
                      setState(() {
                        distance = 1000;
                        Navigator.pop(context);
                      });
                    },
                  ),
                  ListTile(
                    title: Text('2000 meters'),
                    selected: distance == 2000,
                    onTap: () {
                      setState(() {
                        distance = 2000;
                        Navigator.pop(context);
                      });
                    },
                  ),
                  Divider(),
                ],
              ),
            ],
          ),
        ),


        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        Padding(
        padding: const EdgeInsets.all(16.0),
      child: Text(
        'Current distance: ${distance} meters',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
    Expanded(
    child: ListView(
          children: [
            Expanded(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: StreamBuilder<List<Shop>>(
                  stream: readShop(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong! ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      final userLat = lat.isNotEmpty ? double.tryParse(lat) ?? 0.0 : 0.0;

                      print('userLat: $userLat');
                      final userLong = long.isNotEmpty ? double.parse(long) : 0.0;
                      print('userLong: $userLong');


                      final shop = snapshot.data!
                          .where((s) {
                        print("s.lat: ${s.lat}, s.long: ${s.long}");
                        return _calculateDistance(userLat, userLong, double.parse(s.lat), double.parse(s.long)) <= distance;
                      })
                          .toList();

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: shop.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FoodDetailsPage(
                                      food: shop[index],
                                      key: null,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                child: Column(
                                  children: [
                                    Image.network(
                                      shop[index].imageUrl,
                                      width: double.infinity,
                                      height: 350,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      shop[index].food,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Divider(),
                                    Text(
                                      shop[index].description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${_calculateDistance(userLat, userLong, double.parse(shop[index].lat), double.parse(shop[index].long)).toStringAsFixed(0)} m',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );



                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),

            SizedBox(height: 16),

          ],
        ),
    ),
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

  double _calculateDistance(double userLat, double userLong, double shopLat, double shopLong) {
    const int earthRadius = 6371000; // in meters
    double latDiff = (shopLat - userLat) * pi / 180;
    double longDiff = (shopLong - userLong) * pi / 180;
    double a = pow(sin(latDiff / 2), 2) + cos(userLat * pi / 180) * cos(shopLat * pi / 180) * pow(sin(longDiff / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    return distance;
  }


  StreamSubscription _liveLocation() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      lat = position.latitude.toString();
      long = position.longitude.toString();
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }



  Stream<List<Shop>> readShop() => FirebaseFirestore.instance
      .collection('Shop')
      .where('isOpen', isEqualTo: true)
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map<Shop>((doc) => Shop.fromJson(doc.data())).toList());


}


Future<bool> isUserLoggedIn() async {
  var user = await FirebaseAuth.instance.currentUser!;
  return user != null;
}
