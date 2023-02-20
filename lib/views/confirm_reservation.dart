import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

//import 'package:firebase_core/firebase_core.dart';
//import 'package:vava/widget/add_page.dart';
import 'package:vava/model/food.dart';
import 'package:twilio/twilio.dart';
import 'package:vava/views/supposed_main.dart';

import '../model/TwilioConfig.dart';
import 'list_reservations.dart';





class ReservationConfirmationPage extends StatefulWidget {
  final List<String> selectedCheckboxes;
  final String restaurantId;



  ReservationConfirmationPage(this.selectedCheckboxes, this.restaurantId);

  @override
  _ReservationConfirmationPageState createState() =>
      _ReservationConfirmationPageState(selectedCheckboxes: selectedCheckboxes);
}

class _ReservationConfirmationPageState extends State<ReservationConfirmationPage> {
  final List<String> selectedCheckboxes;
  DateTime _selectedTime = DateTime.now();
  int _selectedFoodIndex = 0;
  List<FoodQuantity> selectedFoodsWithQuantity = []; // Define selectedFoodsWithQuantity here

  _ReservationConfirmationPageState({required this.selectedCheckboxes});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Confirm Reservation")),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Shop>>(
                stream: FirebaseFirestore.instance
                    .collection('Shop')
                    .snapshots()
                    .map((snapshot) => snapshot.docs
                    .map((doc) => Shop.fromJson(doc.data()))
                    .toList()),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final foods = snapshot.data;
                  final selectedFoods = foods!
                      .where((food) => selectedCheckboxes.contains(food.id))
                      .toList();
                  selectedFoodsWithQuantity = selectedFoods.map((food) => FoodQuantity(food, 1)).toList();
                  return ListView.builder(
                    itemCount: selectedFoods.length,
                    itemBuilder: (context, index) {
                      final food = selectedFoods[index];
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          leading: Image.network(food.imageUrl),
                          title: Text(
                            food.food,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "RM ${food.price}",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(""),
                                  FoodQuantityWidget(
                                    foodQuantity: selectedFoodsWithQuantity[index],
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[100],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            food.remarks,
                                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[100],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Text(
                                            food.remarks2,
                                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    SizedBox(height: 10),
    Container(
    width: double.infinity,
    child: ElevatedButton(
    onPressed: () {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Confirm Reservation"),
            content: Text(
                "Are you sure you want to confirm the reservation?"),
            actions: [
              TextButton(
                child: Text("Yes"),
                onPressed: () async {
                  final date = await DatePicker.showDateTimePicker(
                    context,
                    showTitleActions: true,
                    currentTime: _selectedTime,
                    locale: LocaleType.en,
                  );
                  if (date != null) {
                    setState(() {
                      _selectedTime = date;
                    });

                    try {
                      final User user = await FirebaseAuth.instance.currentUser!;
                      if (user != null) {
                        final String userId = user.uid;
                        final String restaurantId = widget.restaurantId;
                        final List<String> foodIds = selectedCheckboxes;
                        final List<int> quantities =
                        selectedFoodsWithQuantity.map((f) => f.quantity).toList();
                        final DateTime dateTime = _selectedTime;
                        final status = "pending";
                        final reservationRef = FirebaseFirestore.instance.collection('Reservations').doc();
                        final reservationId = reservationRef.id;

                        await reservationRef.set({
                          'id': reservationId,
                          'userId': userId,
                          'restaurantId': restaurantId,
                          'foodIds': foodIds,
                          'quantities': quantities,
                          'dateTime': dateTime,
                          'status': status,
                        });

// Use the reservationId variable as needed
                        print('Reservation created with id: $reservationId');


                        sendMessage(widget.restaurantId);
                        // Use sendMessage with the recipient number and message body.

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Reservation Successful"),
                            duration: Duration(seconds: 2),
                          ),
                        );

                        // Navigate back to the previous page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ReservationsPage()
                          ),
                        );

                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("User is not logged in."),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Reservation Failed: $e"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),

              TextButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
      child: Text("Confirm Reservation"),
    ),
    ),
          ],
      ));
  }

  Future sendMessage(String restaurantId) async {
  DocumentSnapshot restaurant = await FirebaseFirestore.instance
      .collection('Restaurants')
      .doc(restaurantId)
      .get();

  String phoneNumber =
  (restaurant.data() as Map<String, dynamic>)['phone_number'];

  String messageBody =
  "A customer might be coming to your Shop. Selected items:\n\n";

  for (var foodQuantity in selectedFoodsWithQuantity) {
  messageBody +=
  "${foodQuantity.food.food} x ${foodQuantity.quantity}\n";
  }

  twilio.messages.sendMessage('+6$phoneNumber', messageBody);
  }




}

class FoodQuantity {
  final Shop food;
  int quantity;

  FoodQuantity(this.food, this.quantity);

  void increment() {
    quantity++;
  }

  void decrement() {
    if (quantity > 1) {
      quantity--;
    }
  }
}

class FoodReservation {
  final String foodId;
  final int quantity;

  FoodReservation(this.foodId, this.quantity);

  Map<String, dynamic> toMap() {
    return {'foodId': foodId, 'quantity': quantity};
  }
}


class FoodQuantityWidget extends StatefulWidget {
  final FoodQuantity foodQuantity;

  const FoodQuantityWidget({Key? key, required this.foodQuantity}) : super(key: key);

  @override
  _FoodQuantityWidgetState createState() => _FoodQuantityWidgetState();
}

class _FoodQuantityWidgetState extends State<FoodQuantityWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              widget.foodQuantity.increment();
            });
          },
          child: Text("+"),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            setState(() {
              widget.foodQuantity.decrement();
            });
          },
          child: Text("-"),
        ),
        SizedBox(width: 8),
        Text("Quantity: ${widget.foodQuantity.quantity}"),
      ],
    );
  }
}

