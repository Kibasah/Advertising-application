import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // import the geolocator package
import 'package:vava/model/food.dart';
import 'package:vava/views/supposed_main.dart';
import 'package:vava/widget/homepage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'list_reservations.dart';


class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(2.9312251, 101.7480285);
  Set<Marker> markers = Set();

  @override
  void initState() {
    super.initState();
    _getMarkers();
  }

  void _getMarkers() async {

    final snapshot =
    await FirebaseFirestore.instance.collection('Restaurants').get();
    final restaurants = snapshot.docs;
    for (var i = 0; i < restaurants.length; i++) {
      final data = restaurants[i].data() as Map<String, dynamic>;
      final lat = double.parse(data['latitude']);
      final lng = double.parse(data['longitude']);
      final marker = Marker(
        markerId: MarkerId(restaurants[i].id),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: data['name'],
        ),
          onTap: () async {
            final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              throw 'Could not launch $url';
            }
          }



      );

      setState(() {
        markers.add(marker);
      });
    }

    // get user's location and add a new marker
    final position = await Geolocator.getCurrentPosition();
    final userMarker = Marker(
      markerId: MarkerId('user'),
      position: LatLng(position.latitude, position.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(title: 'You are here'),
    );
    setState(() {
      markers.add(userMarker);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
        actions: [
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  markers: markers,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 15.0,
                  ),
                ),
              ),
            ),
            BottomNavigationBar(
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
          ],
        ),
      ),

    );


  }


  Stream<List<Shop>> readShop() => FirebaseFirestore.instance
      .collection('Shop')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map<Shop>((doc) => Shop.fromJson(doc.data())).toList());
}


Future<bool> isUserLoggedIn() async {
  var user = await FirebaseAuth.instance.currentUser!;
  return user != null;
}
