import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:vava/model/food.dart';
import 'package:vava/model/restaurant.dart';
import 'package:vava/widget/button.dart';
import 'package:vava/widget/widget_functions.dart';

import '../widget/add_page.dart';
import '../widget/update_page.dart';

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
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xffE2F3D4),
                                ),
                                child: Center(
                                  child: Text(
                                    "${widget.restaurant.name}",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
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
                                  )),
                            ],
                          ),
                        ),
                        addVerticalSpace(10),
                        SizedBox(
                          height: constraints.maxHeight * 0.60,
                          width: double.infinity,
                          child: Container(
                            color: Colors.grey.shade50,
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
                                    return GestureDetector(
                                        onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FoodPage(
                                            shop: foods[index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                    decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black, width: 1),
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                    ),
                                    child: ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
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
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: 8.0,
                                                  top: 8.0,
                                                  bottom: 8.0,
                                                  left: 11.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Food: ${foods[index].food}',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: 8.0,
                                                  top: 8.0,
                                                  bottom: 8.0,
                                                  left: 11.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Price: ${foods[index].price}',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: 8.0,
                                                  top: 8.0,
                                                  bottom: 8.0,
                                                  left: 11.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Remarks: ${foods[index].remarks}',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
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
                                            Text("Reservation",
                                                style: TextStyle(
                                                    color: Colors.black)),
                                          ],
                                        ),
                                      ),
                                    ));
                                  },
                                  staggeredTileBuilder: (index) {
                                    return StaggeredTile.count(
                                        1, index.isEven ? 1.4 : 1.5);
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
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FoodaddPage(menuId: widget.restaurant.menuId, lat:widget.restaurant.latitude,long: widget.restaurant.longitude,),
                        ),
                      );
                      Icon(Icons.add);
                    },
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
