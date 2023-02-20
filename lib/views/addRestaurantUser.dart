import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vava/model/restaurant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;



/// Restaurant landing page

class RestaurantsAddPage extends StatefulWidget {
  const RestaurantsAddPage({super.key});

  @override
  _RestaurantsAddPageState createState() => _RestaurantsAddPageState();
}

class _RestaurantsAddPageState extends State<RestaurantsAddPage> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _priceRangeController = TextEditingController();
  final _emailController = TextEditingController();
  String lat = '';
  String long = '';
  late StreamSubscription _positionStream;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  File? _imageFile;


  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _cuisineController.text = 'Malay cuisine';
    _priceRangeController.text = 'High End';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Restaurant'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          SizedBox(height: 24),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(labelText: 'Location'),
          ),
          SizedBox(height: 24),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(labelText: 'Address'),
          ),
          SizedBox(height: 24),
          TextField(
            controller: _phoneNumberController,
            decoration: InputDecoration(labelText: 'Phone Number'),
          ),
          SizedBox(height: 24),
          DropdownButton(
            value: _cuisineController.text,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: TextStyle(
                color: Colors.grey,
                fontSize: 18
            ),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (value) {
              setState(() {
                _cuisineController.text = value!;
              });
            },
            items: ['Malay cuisine', 'Chinese cuisine', 'Indian cuisine', 'Fusion', 'Other']
                .map((e) => DropdownMenuItem(
              value: e,
              child: Text(e),
            ))
                .toList(),
          ),


          SizedBox(height: 24),
          DropdownButton(
            value: _priceRangeController.text,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: TextStyle(
                color: Colors.grey,
                fontSize: 18
            ),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (ewValue) {
              setState(() {
                _priceRangeController.text = ewValue!;
              });
            },
            items: ['High End', 'Medium End', 'Cheap']
                .map((e) => DropdownMenuItem(
              value: e,
              child: Text(e),
            ))
                .toList(),
          ),


          SizedBox(height: 24),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          SizedBox(height: 24),
          GestureDetector(
            onTap: () async {
              final imageFile = await ImagePicker().getImage(source: ImageSource.gallery);
              setState(() {
                _imageFile = File(imageFile!.path);
              });
            },
            child: _imageFile == null
                ? Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey.shade200,
              child: const Icon(Icons.add_a_photo, size: 80, color: Colors.grey),
            )
                : Image.file(_imageFile!),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            child: Icon(Icons.add),
            onPressed: () async {
              if (_nameController.text.isEmpty ||
                  _locationController.text.isEmpty ||
                  _addressController.text.isEmpty ||
                  _phoneNumberController.text.isEmpty ||
                  _cuisineController.text.isEmpty ||
                  _priceRangeController.text.isEmpty ||
                  _emailController.text.isEmpty) {
                // Show an error message if any of the required fields are empty
                final snackBar = SnackBar(
                  content: Text(
                    'Please fill in all required fields',
                    style: TextStyle(fontSize: 24),
                  ),
                  backgroundColor: Colors.red,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return;
              }

              int newMenuId = await createRestaurant();
              // Create the restaurant object using the newMenuId
              final restaurant = Restaurant(
                name: _nameController.text,
                location: _locationController.text,
                address: _addressController.text,
                phone_number: _phoneNumberController.text,
                cuisine: _cuisineController.text,
                price_range: _priceRangeController.text,
                email: _emailController.text,
                latitude: lat,
                longitude: long,
                menuId: newMenuId.toString(),
                UID: uid,
              );

              // Show a snackbar to confirm the addition of the restaurant
              final snackBar = SnackBar(
                content: Text(
                  'Added ${_nameController.text} to the database!',
                  style: TextStyle(fontSize: 24),
                ),
                backgroundColor: Colors.green,
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              Navigator.pop(context);
            },
          ),

        ],
      ),
    );
  }

  Future<int> createRestaurant() async {
    // Retrieve the current value of the "menuId" counter
    final counterRef = FirebaseFirestore.instance.collection('counter').doc('menuId');
    final counterSnapshot = await counterRef.get();
    final currentValue = counterSnapshot.get('count');
    int newMenuId = currentValue + 1;

    // Upload the image to Firebase Storage and get its URL
    final imageUrl = await _uploadImage();

    // Add the restaurant to the Firestore database
    final doc = FirebaseFirestore.instance.collection('pending_restaurants').doc();

    final json = Restaurant(
      name: _nameController.text,
      location: _locationController.text,
      address: _addressController.text,
      phone_number: _phoneNumberController.text,
      cuisine: _cuisineController.text,
      price_range: _priceRangeController.text,
      email: _emailController.text,
      latitude: lat,
      longitude: long,
      menuId: newMenuId.toString(),
      UID: uid,
      imageUrl: imageUrl,
    ).toJson();

    await doc.set(json);

    // Assign the document ID to the restaurant object
    await doc.update({'id': doc.id});
    // Update the value of the "menuId" counter in the Firestore database
    await counterRef.update({'count': newMenuId});

    // Return the newMenuId
    return newMenuId;
  }

  StreamSubscription _liveLocation() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      lat = position.latitude.toString();
      long = position.longitude.toString();
    });
  }

  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      lat = position.latitude.toString();
      long = position.longitude.toString();
    });
  }

  Future<String> _uploadImage() async {
    final fileName = 'restaurants/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = firebase_storage.FirebaseStorage.instance.ref().child(fileName);
    await ref.putFile(_imageFile!);
    final url = await ref.getDownloadURL();
    return url;
  }


}
