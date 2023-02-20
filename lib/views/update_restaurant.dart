import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vava/model/restaurant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../widget/add_page.dart';

class AddRestaurantPage extends StatefulWidget {
  final Restaurant? restaurant; // id of the restaurant to be updated, if any

  const AddRestaurantPage({Key? key, this.restaurant}) : super(key: key);

  @override
  _AddRestaurantPageState createState() => _AddRestaurantPageState();
}

class _AddRestaurantPageState extends State<AddRestaurantPage> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController controllerName;
  late TextEditingController controllerLocation;
  late TextEditingController controllerAddress;
  late TextEditingController controllerPhoneNumber;
  late TextEditingController controllerCuisine;
  late TextEditingController controllerPriceRange;
  late TextEditingController controllerEmail;
  late TextEditingController controllerLatitude;
  late TextEditingController controllerLongitude;
  late String lat = '';
  late String long = '';
  File _image = File('');


  bool isUpdating = false;

  @override
  void initState() {
    super.initState();

    controllerName = TextEditingController();
    controllerLocation = TextEditingController();
    controllerAddress = TextEditingController();
    controllerPhoneNumber = TextEditingController();
    controllerCuisine = TextEditingController();
    controllerPriceRange = TextEditingController();
    controllerEmail = TextEditingController();
    controllerLatitude = TextEditingController();
    controllerLongitude = TextEditingController();

    controllerLatitude.text = lat;
    controllerLongitude.text = long;

    if (widget.restaurant != null) {
      final restaurant = widget.restaurant!;

      // set the initial values of the controller
      controllerName.text = restaurant.name;
      controllerLocation.text = restaurant.location;
      controllerAddress.text = restaurant.address;
      controllerPhoneNumber.text = restaurant.phone_number;
      controllerCuisine.text = restaurant.cuisine;
      controllerPriceRange.text = restaurant.price_range;
      controllerEmail.text = restaurant.email;
      lat = restaurant.latitude;
      long = restaurant.longitude;
      controllerLatitude.text = lat;
      controllerLongitude.text = long;
    }
  }

  @override
  void dispose() {
    //dispose the controllers
    controllerName.dispose();
    controllerLocation.dispose();
    controllerAddress.dispose();
    controllerPhoneNumber.dispose();
    controllerCuisine.dispose();
    controllerPriceRange.dispose();
    controllerEmail.dispose();
    controllerLatitude.dispose();
    controllerLongitude.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.restaurant != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? controllerName.text : 'Edit User'),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                deleteRestaurant(widget.restaurant!);

                final snackBar = SnackBar(
                  backgroundColor: Colors.green,
                  content: Text(
                    'Deleted ${controllerName.text} from Firebase!',
                    style: TextStyle(fontSize: 24),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);

                Navigator.pop(context);
              },
            ),
          IconButton(
            icon: Text("Add menu"),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => FoodaddPage(menuId: widget.restaurant!.menuId, lat:widget.restaurant!.latitude,long: widget.restaurant!.longitude),
            )),
          ),
        ],
      ),

      body: Form(
        key: formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: <Widget>[
            GestureDetector(
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  image: _image == null
                      ? DecorationImage(
                    image: AssetImage('assets/images/select_image.png'),
                    fit: BoxFit.cover,
                  )
                      : DecorationImage(
                    image: FileImage(_image),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_image == null) // show the icon only when _image is null
                      const Icon(Icons.add_a_photo, size: 80, color: Colors.grey),
                  ],
                ),
              ),

              onTap: () async {
                final pickedFile = await ImagePicker()
                    .pickImage(source: ImageSource.gallery, maxWidth: 600);
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: controllerName,
              decoration: decoration('Name'),
              validator: (text) =>
                  text != null && text.isEmpty ? 'Not valid input' : null,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: controllerLocation,
              decoration: decoration('Location'),
              validator: (text) =>
                  text != null && text.isEmpty ? 'Not valid input' : null,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: controllerAddress,
              decoration: decoration('Address'),
              validator: (text) =>
                  text != null && text.isEmpty ? 'Not valid input' : null,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: controllerPhoneNumber,
              decoration: decoration('Phone Number'),
              validator: (text) =>
                  text != null && text.isEmpty ? 'Not valid input' : null,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: controllerCuisine,
              decoration: decoration('Cuisine'),
              validator: (text) =>
                  text != null && text.isEmpty ? 'Not valid input' : null,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: controllerPriceRange,
              decoration: decoration('Price Range'),
              validator: (text) =>
                  text != null && text.isEmpty ? 'Not valid input' : null,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: controllerEmail,
              decoration: decoration('Email'),
              validator: (text) =>
                  text != null && text.isEmpty ? 'Not valid input' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              child: Text(isEditing ? 'Save' : 'Create'),
              onPressed: () async {
                final isValid = formKey.currentState!.validate();


                if (isValid) {
                  FirebaseStorage storage = FirebaseStorage.instance;

                  final Reference storageReference =
                  storage.ref().child('restaurants/${DateTime.now()}.jpg');
                  final UploadTask uploadTask = storageReference.putFile(_image);
                  final TaskSnapshot snapshot = await uploadTask;
                  final String imageUrl = await snapshot.ref.getDownloadURL();

                  final restaurant = Restaurant(
                    id: widget.restaurant?.id ?? '',
                    name: controllerName.text,
                    location: controllerLocation.text,
                    address: controllerAddress.text,
                    phone_number: controllerPhoneNumber.text,
                    cuisine: controllerCuisine.text,
                    price_range: controllerPriceRange.text,
                    email: controllerEmail.text,
                    latitude: lat,
                    longitude: long,
                    menuId: widget.restaurant?.menuId ?? '',
                    UID: widget.restaurant?.UID ?? '',
                    imageUrl: imageUrl,
                  );

                  if (isEditing) {
                    updateRestaurant(restaurant);
                    final snackBar = SnackBar(
                      backgroundColor: Colors.green,
                      content: Text(
                        'Updated ${controllerName.text} in Firebase!',
                        style: TextStyle(fontSize: 24),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    addRestaurant(restaurant);
                    final snackBar = SnackBar(
                      backgroundColor: Colors.green,
                      content: Text(
                        'Added ${controllerName.text} to Firebase!',
                        style: TextStyle(fontSize: 24),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }

                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void addRestaurant(Restaurant restaurant) async {
    final doc = FirebaseFirestore.instance.collection('Restaurants').doc();

    final json = restaurant.toJson();

    await doc.set(json);

    // Assign the document ID to the restaurant object
    await doc.update({'id': doc.id});
  }

  void updateRestaurant(Restaurant restaurant) async {
    final doc = FirebaseFirestore.instance
        .collection('Restaurants')
        .doc(restaurant.id!);

    final json = restaurant.toJson();

    await doc.update(json);
  }

  void deleteRestaurant(Restaurant restaurant) async {
    final restaurantDoc = FirebaseFirestore.instance
        .collection('Restaurants')
        .doc(restaurant.id!);

    final shopDocs = await FirebaseFirestore.instance
        .collection('Shop')
        .where('menuId', isEqualTo: restaurant.menuId)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    batch.delete(restaurantDoc);

    for (final doc in shopDocs.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }


  InputDecoration decoration(String label) {
    return InputDecoration(labelText: label);
  }
}
