import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReservationsPage extends StatefulWidget {
  @override
  _ReservationsPageState createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  User? _user;
  String? restaurantId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  _getCurrentUser() async {
    _user = await FirebaseAuth.instance.currentUser!;
    if (_user != null) {
      print("User UID: ${_user!.uid}");
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Reservations')
          .where('userId', isEqualTo: _user!.uid)
          .get();
      if (snapshot.docs.isEmpty) {
        print("No reservation found for user with UID: ${_user!.uid}");
      } else {
        for (var doc in snapshot.docs) {
          var restaurantId = doc['restaurantId'];
          print("restaurantId: $restaurantId");
          QuerySnapshot restaurantSnapshot = await FirebaseFirestore.instance
              .collection('Restaurants')
              .where('id', isEqualTo: restaurantId)
              .get();
          if (restaurantSnapshot.docs.isEmpty) {
            print("No restaurant found for ID: $restaurantId");
          } else {
            for (var restaurantDoc in restaurantSnapshot.docs) {
              print("Restaurant data: $restaurantDoc.data()");
              setState(() {
                this.restaurantId = restaurantId;
              });
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservations'),
      ),
      body: _user == null
          ? Center(
        child: CircularProgressIndicator(),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Reservations')
            .where('userId', isEqualTo: _user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          var reservations = snapshot.data!.docs;
          print("Number of reservations: ${reservations.length}");
          if (reservations.isEmpty) {
            return Center(
              child: Text('No reservations found'),
            );
          }
          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              var reservation = reservations[index];
              var foodIds = reservation['foodIds'];
              var quantities = reservation['quantities'];
              List<Widget> foodItems = [];
              for (int i = 0; i < foodIds.length; i++) {
                var foodId = foodIds[i];
                var quantity = quantities[i];
                foodItems.add(Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('Shop')
                        .doc(foodId)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text(
                          'Loading...',
                          style: TextStyle(fontSize: 16.0),
                        );
                      }
                      var foodName = snapshot.data!.get('food');
                      return Row(
                        children: [
                          Text(
                            foodName,
                            style: TextStyle(fontSize: 16.0),
                          ),
                          Spacer(),
                          Text(
                            'x$quantity',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      );
                    },
                  ),
                ));
              }

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Restaurants')
                    .doc(reservation['restaurantId'])
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var restaurantName = snapshot.data!['name'];
                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 16),
                        color: Colors.red,
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Confirm"),
                              content: Text("Are you sure you want to delete this reservation?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: Text("Delete"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) async {
                        setState(() {
                          // Remove the reservation from the list here
                        });

                        // Delete the reservation from the database
                        await FirebaseFirestore.instance
                            .collection('Reservations')
                            .doc(reservation.id)
                            .delete();
                      },

                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.centerRight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                                color: reservation['status'] == 'Completed' ? Colors.green : Colors.red,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                reservation['status'],
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    restaurantName,
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: foodItems,
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    "Date and Time: ${DateFormat('MMM dd, yyyy h:mm a').format(reservation['dateTime'].toDate())}",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );


                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }


}
