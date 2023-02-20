import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:vava/model/food.dart';
import 'package:vava/model/restaurant.dart';
import 'package:vava/widget/button.dart';
import 'package:vava/widget/widget_functions.dart';
import 'package:vava/widget/food_desc.dart';

import '../widget/add_page.dart';
import 'confirm_reservation.dart';

//it will receive the data from the previous page
//it will receive a map of data
//it will receive data from buildShop in update_landing.dart which is Shop
//it has a const called FoodPage
class MenuPage extends StatefulWidget {
  final Restaurant restaurant;


  const MenuPage({Key? key, required this.restaurant}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  //create a list to store the selected checkboxes

  @override
  final GlobalKey<SlideActionState> _buttonKey = GlobalKey<SlideActionState>();
  bool addedToCart = false; // Just for Demonstration
  final _selectedCheckboxes = <String>{};

  @override
  Widget build(BuildContext context) {

    final TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(builder: (context, constraints) {
          return Container(
            height: constraints.maxHeight,
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: [
                        Container(
                          height: constraints.maxHeight * 0.40,
                          child: Stack(
                            children: [
                              // Restaurant image
                              Positioned.fill(
                                child: Image.network(
                                  widget.restaurant.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Dark overlay for better visibility of text
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                ),
                              ),
                              // Restaurant name
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Text(
                                  "${widget.restaurant.name}",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // Back button
                              Positioned(
                                top: 10,
                                left: 10,
                                child: SquareIconButton(
                                  icon: Icons.arrow_back_ios_outlined,
                                  width: 50,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  buttonColor: Colors.orange.shade100,
                                  iconColor: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // add space for showing restaurant details
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${widget.restaurant.name}",
                          style: textTheme.headline6,
                        ),
                        Text(
                          "${widget.restaurant.phone_number}",
                          style: textTheme.subtitle1,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "${widget.restaurant.address}",
                      style: textTheme.subtitle1,
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Cuisine: ${widget.restaurant.cuisine}",
                            style: textTheme.subtitle1,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Price Range: ${widget.restaurant.price_range}",
                            style: textTheme.bodyText1,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),



              addVerticalSpace(10),
                        SizedBox(
                          height: constraints.maxHeight * 0.70,
                          width: double.infinity,
                          child: Container(
                            color: Colors.grey.shade900,
                            child: StreamBuilder<List<Shop>>(
                              stream: FirebaseFirestore.instance
                                  .collection('Shop')
                                  .where('menuId',
                                      isEqualTo: widget.restaurant.menuId)
                                  .snapshots()
                                  .map((snapshot) => snapshot.docs
                                      .map((doc) => Shop.fromJson(doc.data()))
                                      .toList()),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                if (!snapshot.hasData) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                                final foods = snapshot.data;
                                return StaggeredGridView.countBuilder(
                                  shrinkWrap: true,
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                  itemCount: foods!.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 1),
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        child: Column(
                                          children: <Widget>[
                                            SizedBox(
                                              height:
                                                  constraints.maxHeight * 0.25,
                                              width: double.infinity,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                child: Image.network(
                                                  foods[index].imageUrl,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0, left: 15.0),
                                                    child: Text(
                                                      '${foods[index].food}',
                                                      style: TextStyle(
                                                        color: Colors.grey.shade100,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 25,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(right: 15.0),
                                                  child: Text(
                                                    'RM ${foods[index].price}',
                                                    style: TextStyle(
                                                      color: Colors.grey.shade100,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(),
                                            SizedBox(height: 8),
                                            Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey.shade100,
                                                  width: 1,
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${foods[index].description}',
                                                style: TextStyle(
                                                  color: Colors.grey.shade100,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),


                                            Padding(
                                              padding: EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0, left: 11.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      padding: EdgeInsets.all(8.0),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        borderRadius: BorderRadius.circular(8.0),
                                                      ),
                                                      child: Text(
                                                        '${foods[index].remarks}',
                                                        style: TextStyle(
                                                          color: Colors.grey.shade800,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8.0),
                                                  Expanded(
                                                    child: Container(
                                                      padding: EdgeInsets.all(8.0),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        borderRadius: BorderRadius.circular(8.0),
                                                      ),
                                                      child: Text(
                                                        '${foods[index].remarks2}',
                                                        style: TextStyle(
                                                          color: Colors.grey.shade800,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),


                                            Checkbox(
                                              value: _selectedCheckboxes
                                                  .contains(foods[index].id),
                                              activeColor: Colors.greenAccent,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    _selectedCheckboxes
                                                        .add(foods[index].id);
                                                  } else {
                                                    _selectedCheckboxes.remove(
                                                        foods[index].id);
                                                  }
                                                });
                                              },
                                            ),
                                            Text("Add to reservation",
                                                style: TextStyle(
                                                    color: Colors.grey.shade100)),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  staggeredTileBuilder: (index) {
                                    return StaggeredTile.count(
                                        1, index.isEven ? 1.6 : 1.6);
                                  },
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 10,
                  right: 10,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedCheckboxes.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(""),
                              content: Text("Please select at least one food if you are ordering"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReservationConfirmationPage(
                                    _selectedCheckboxes.toList(),
                                    widget.restaurant.id
                                )
                            )
                        );
                      }
                    },
                    child: Text("Next"),
                  ),
                ),

              ],
            ),
          );
        }),
      ),
    );
  }
}
