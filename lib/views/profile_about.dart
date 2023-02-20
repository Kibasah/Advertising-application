import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final _nameController = TextEditingController();

  Future<void> _saveProfileData(String name, String uid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('profile').doc(uid).set({
        'name': name,
        'uid': uid,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile saved'),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error saving profile'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String uid = user!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About this app',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'This mobile application uses geofencing as a way to filter nearby restaurants within Bangi and provide a reservation interface for users can reserve their food that is chosen',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 32.0),
            Text(
              'What should we call you?',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your name',
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    final String name = _nameController.text.trim();
                    if (name.isNotEmpty) {
                      _saveProfileData(name, uid);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Please enter your name'),
                        duration: Duration(seconds: 2),
                      ));
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              'Your uid is: $uid',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}
