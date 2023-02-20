import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/restaurant.dart';
import 'package:intl/intl.dart';



class ReservationsPage extends StatefulWidget {
  final Restaurant restaurant;

  ReservationsPage({required this.restaurant});

  @override
  _ReservationsPageState createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Reservations'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Reservations')
            .where('restaurantId', isEqualTo: widget.restaurant.id)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No reservations found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> reservation = snapshot.data!.docs[index].data() as Map<String, dynamic>;

              List<dynamic> foodIds = reservation['foodIds'];
              List<dynamic> quantities = reservation['quantities'];

              return FutureBuilder<Card>(
                future: getCard(reservation, foodIds, quantities),
                builder: (BuildContext context, AsyncSnapshot<Card> cardSnapshot) {
                  if (cardSnapshot.hasError) {
                    return Center(child: Text('Error: ${cardSnapshot.error}'));
                  }

                  if (!cardSnapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return cardSnapshot.data!;
                },
              );
            },
          );

        },
      ),
    );
  }//build

  Future<Card> getCard(Map<String, dynamic> reservation, List<dynamic> foodIds, List<dynamic> quantities) async {
    List<String> foodItems = [];

    // Get the current user's ID
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // Get the current user's name from the "profile" collection
    DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance.collection('profile').doc(uid).get();
    String name = profileSnapshot.get('name');

    for (int i = 0; i < foodIds.length; i++) {
      String foodId = foodIds[i];
      int quantity = quantities[i];
      DocumentSnapshot foodSnapshot = await FirebaseFirestore.instance.collection('Shop').doc(foodId).get();
      String foodName = foodSnapshot.get('food');
      String foodItem = '${quantity} x ${foodName}';
      foodItems.add(foodItem);
    }

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User: ${name}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Reservation Date and Time: ${DateFormat('EEEE, MMMM d, yyyy hh:mm a').format(reservation['dateTime'].toDate())}',
                ),
                SizedBox(height: 16),
                Text(
                  'Order Details:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Column(
                  children: foodItems.map((foodItem) {
                    return Text(
                      foodItem,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: reservation['status'] == 'pending' ? Colors.red : Colors.green,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: Text(
                reservation['status'],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Change reservation status to Completed
                      reservation['status'] = 'Completed';
                      await FirebaseFirestore.instance.collection('Reservations').doc(reservation['id']).update({
                        'status': reservation['status'],
                      });
                      print('Reservation status updated successfully!');
                    } catch (error) {
                      print('Failed to update reservation status: $error');
                    }
                  },
                  child: Icon(Icons.check),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),

                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Delete the reservation
                    FirebaseFirestore.instance.collection('Reservations').doc(reservation['id']).delete();
                  },
                  child: Icon(Icons.close),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
