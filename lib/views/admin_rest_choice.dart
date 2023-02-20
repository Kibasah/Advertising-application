import 'package:flutter/material.dart';
import 'package:vava/model/restaurant.dart';
import 'package:vava/views/update_restaurant.dart';

import '../widget/food_list.dart';

class RestaurantDetailsPage extends StatefulWidget {
  final Restaurant restaurant;

  RestaurantDetailsPage({Key? key, required this.restaurant}) : super(key: key);

  @override
  _RestaurantDetailsPageState createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Image.network(
              widget.restaurant.imageUrl,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              widget.restaurant.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 16, bottom: 16),
            child: Text(
              widget.restaurant.location,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              width: double.infinity,
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddRestaurantPage(restaurant: widget.restaurant),
                        ),
                      );
                    },
                    child: Text('Update Restaurant Info'),
                  ),

                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Foodupdate(
                              menuId: widget.restaurant.menuId, key: null, lat: widget.restaurant.latitude, long: widget.restaurant.longitude
                          ),
                        ),
                      );
                    },
                    child: Text('View Food'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
