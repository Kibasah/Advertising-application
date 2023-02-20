import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vava/model/food.dart';
import 'package:vava/views/menu_rest.dart';
import 'package:vava/model/restaurant.dart';


class FoodDetailsPage extends StatelessWidget {
  final Shop food;

  const FoodDetailsPage({Key? key, required this.food}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(food.food),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(food.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        food.food,
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '\RM${food.price}',
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Text(
                'Description',
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                food.description,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              SizedBox(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remarks',
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      food.remarks,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      food.remarks2,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  // Retrieve the restaurant data from Firebase
                  final restaurantSnapshot = await FirebaseFirestore.instance
                      .collection('Restaurants')
                      .where('menuId', isEqualTo: food.menuId)
                      .limit(1)
                      .get();

                  // Convert the restaurant data to a Restaurant object
                  final restaurant = Restaurant.fromJson(restaurantSnapshot.docs.first.data());

                  // Navigate to the MenuRestPage, passing in the Restaurant object
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MenuPage(restaurant: restaurant),
                    ),
                  );
                },
                child: Text('Go to Restaurant'),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
