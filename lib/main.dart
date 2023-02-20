//import 'package:firebase_auth_email/page/home_page.dart';
//import 'package:firebase_auth_email/widget/login_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vava/widget/auth_page.dart';
import 'package:vava/widget/constant.dart';
import 'package:vava/widget/homepage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class MessageArguments {
  final RemoteMessage message;
  MessageArguments(this.message);
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('A new onMessage event was published!');
    navigatorKey.currentState!.pushNamed('/message', arguments: MessageArguments(message));
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Firebase Messaging firebase is initialized");
  await Firebase.initializeApp();
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  static final String title = 'Vava Food App';

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: navigatorKey,
    debugShowCheckedModeBanner: false,
    title: title,
    theme: ThemeData.dark().copyWith(
      textTheme: defaultText,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal)
          .copyWith(secondary: Colors.tealAccent),
    ),
    home: MainPage(),
  );
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Something went wrong!'));
        } else if (snapshot.hasData) {
          return HomePage();
        } else {
          return AuthPage();
        }
      },
    ),
  );
}
