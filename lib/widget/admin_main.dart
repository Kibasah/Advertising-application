import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'package:vava/widget/add_page.dart';
import 'package:vava/widget/homepage.dart';
//import 'package:vava/misc/actioninfo.dart';
//import 'package:vava/widget/update_page.dart';
import 'package:vava/widget/verify_land.dart';

import '../views/add_restaurant.dart';



class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PendingRestaurantsPage()),
                );
              },
              child: Text('Verify Restaurant'),
            ),
            SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RestaurantUpdate()),
                );
              },
              child: Text('Manage Restaurants'),
            ),
            SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Text('Go to Homepage'),
            ),

          ],
        ),
      ),
    );
  }
}
