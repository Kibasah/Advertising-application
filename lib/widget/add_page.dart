import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vava/model/food.dart';

class FoodaddPage extends StatefulWidget {
  final String menuId;
  final String lat;
  final String long;

  const FoodaddPage({Key? key, required this.menuId, required this.lat, required this.long}) : super(key: key);

  @override
  State<FoodaddPage> createState() => _FoodaddPageState();
}

class _FoodaddPageState extends State<FoodaddPage> {
  final controllerFood = TextEditingController();
  final controllerPrice = TextEditingController();
  final controllerRemarks = TextEditingController();
  final controllerDescription = TextEditingController();
  final controllerRemarks2 = TextEditingController();
  File _image = File('');
  late String lat = '';
  late String long = '';

  @override
  Widget build(BuildContext context) =>
      Scaffold(
          appBar: AppBar(title: Text('Add Food')),
          body: ListView(
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
              TextField(
                controller: controllerFood,
                decoration: InputDecoration(hintText: 'Food'),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controllerPrice,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Price'),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controllerRemarks,
                decoration: InputDecoration(hintText: 'Remarks'),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controllerDescription,
                decoration: InputDecoration(hintText: 'Description'),
                maxLength: 30,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controllerRemarks2,
                decoration: InputDecoration(hintText: 'Remarks2'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                child: Icon(Icons.add),
                onPressed: () async {
                  if (areAllFieldsFilled()) {
                    FirebaseStorage storage = FirebaseStorage.instance;

                    final Reference storageReference =
                    storage.ref().child('food_images/${DateTime.now()}.jpg');
                    final UploadTask uploadTask = storageReference.putFile(
                        _image);
                    uploadTask.then((res) {
                      res.ref.getDownloadURL();
                    });
                    final user = Shop(
                      food: controllerFood.text,
                      price: int.parse(controllerPrice.text),
                      remarks: controllerRemarks.text,
                      description: controllerDescription.text,
                      remarks2: controllerRemarks2.text,
                      menuId: widget.menuId,
                      imageUrl: await (await uploadTask).ref.getDownloadURL(),
                      lat: widget.lat,
                      long: widget.long,
                    );
                    createFood(user);
                    final snackBar = SnackBar(
                      backgroundColor: Colors.green,
                      content: Text(
                        'Added ${controllerFood.text} to Store!',
                        style: TextStyle(fontSize: 24),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    Navigator.pop(context);
                  } else {
                    final snackBar = SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                        'Please fill in all required fields!',
                        style: TextStyle(fontSize: 24),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
              ),
            ],
          ));

  Future<void> createFood(Shop user) async {
    final docUser = FirebaseFirestore.instance.collection('Shop').doc();
    user.id = docUser.id;
    final json = {
      ...user.toJson(),
      'menuId': user.menuId,
      'imageUrl': user.imageUrl,
      'isOpen': true,
    };
    await docUser.set(json);
  }
  bool areAllFieldsFilled() {
    return _image != null && controllerFood.text.isNotEmpty && controllerPrice.text.isNotEmpty;
  }

}
