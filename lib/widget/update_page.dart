import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vava/model/food.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

//it will receive the data from the previous page
//it will receive a map of data
//it will receive data from buildShop in update_landing.dart which is Shop
//it has a const called FoodPage
class FoodPage extends StatefulWidget {
  final Shop? shop;

  const FoodPage({Key? key, this.shop}) : super(key: key);

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController controllerFood;
  late TextEditingController controllerPrice;
  late TextEditingController controllerRemarks;
  late TextEditingController controllerDescription;
  late TextEditingController controllerRemarks2;
  late TextEditingController controllerImageUrl;
  File _image = File('');
  late String lat = '';
  late String long = '';

  @override
  void initState() {
    super.initState();

    controllerFood = TextEditingController();
    controllerPrice = TextEditingController();
    controllerRemarks = TextEditingController();
    controllerDescription = TextEditingController();
    controllerRemarks2 = TextEditingController();
    controllerImageUrl = TextEditingController();


    if (widget.shop != null) {
      final shop = widget.shop!;

      controllerFood.text = shop.food;
      controllerPrice.text = shop.price.toString();
      controllerRemarks.text = shop.remarks;
      controllerDescription.text = shop.description;
      controllerRemarks2.text = shop.remarks2;

    }
  }

  @override
  void dispose() {
    controllerFood.dispose();
    controllerPrice.dispose();
    controllerRemarks.dispose();
    controllerDescription.dispose();
    controllerRemarks2.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.shop != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? controllerFood.text : 'Edit Food'),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                deleteFood(widget.shop!);

                final snackBar = SnackBar(
                  backgroundColor: Colors.green,
                  content: Text(
                    'Deleted ${controllerFood.text} to Firebase!',
                    style: TextStyle(fontSize: 24),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);

                Navigator.pop(context);
              },
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
                  image: _image == null
                      ? DecorationImage(
                    image: AssetImage('assets/images/select_image.png'),
                    fit: BoxFit.cover,
                  )
                      : DecorationImage(
                      image: FileImage(_image), fit: BoxFit.cover),
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
              controller: controllerFood,
              decoration: decoration('Name'),
              validator: (text) =>
                  text != null && text.isEmpty ? 'Not valid input' : null,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: controllerPrice,
              decoration: decoration('Price'),
              keyboardType: TextInputType.number,
              validator: (text) => text != null && int.tryParse(text) == null
                  ? 'Not valid input'
                  : null,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: controllerDescription,
              decoration: decoration('Description'),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: controllerRemarks,
              decoration: decoration('Remarks'),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: controllerRemarks2,
              decoration: decoration('Remarks 2'),
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              child: Text(isEditing ? 'Save' : 'Create'),
              onPressed: () async {
                final isValid = formKey.currentState!.validate();


                if (isValid) {
                  FirebaseStorage storage = FirebaseStorage.instance;

                  final Reference storageReference =
                  storage.ref().child('food_images/${DateTime.now()}.jpg');
                  final UploadTask uploadTask = storageReference.putFile(_image);
                  final TaskSnapshot snapshot = await uploadTask;
                  final String imageUrl = await snapshot.ref.getDownloadURL();

                  final shop = Shop(
                    id: widget.shop?.id ?? '',
                    food: controllerFood.text,
                    price: int.parse(controllerPrice.text),
                    remarks: controllerRemarks.text,
                    description: controllerDescription.text,
                    remarks2: controllerRemarks2.text,
                    menuId: widget.shop!.menuId,
                    imageUrl: imageUrl,
                    lat: widget.shop!.lat,
                    long: widget.shop!.long,
                  );

                  if (isEditing) {
                    updateFood(shop);
                  } else {
                    createFood(shop);
                  }

                  final action = isEditing ? 'Edited' : 'Added';
                  final snackBar = SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                      '$action ${controllerFood.text} to Firebase!',
                      style: TextStyle(fontSize: 24),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);

                  Navigator.pop(context);
                }

              },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration decoration(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      );

  Future createFood(Shop shop) async {
    final docFood = FirebaseFirestore.instance.collection('Shop').doc();
    shop.id = docFood.id;
    shop.imageUrl = controllerImageUrl.text;

    final json = shop.toJson();
    await docFood.set(json);
  }

  Future updateFood(Shop shop) async {
    final docFood = FirebaseFirestore.instance.collection('Shop').doc(shop.id);

    await docFood.update({
      ...shop.toJson(),
      'food': shop.food,
      'description': shop.description,
      'imageUrl': shop.imageUrl,
    });
  }


  Future deleteFood(Shop shop) async {
    /// Reference to document
    final docFood = FirebaseFirestore.instance.collection('Shop').doc(shop.id);

    await docFood.delete();
  }
}
