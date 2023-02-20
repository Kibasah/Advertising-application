import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vava/main.dart';
import 'package:vava/widget/utils.dart';
import '../model/TwilioConfig.dart';
import 'package:twilio/twilio.dart';

class SignUpWidget extends StatefulWidget {
  final Function() onClickedSignIn;

  const SignUpWidget({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final fullNameController = TextEditingController();

  final items = ['Seller', 'User'];
  String? valu;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60),
              FlutterLogo(size: 120),
              SizedBox(height: 20),
              Text(
                'Hey There,\n Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              TextFormField(
                controller: emailController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: 'Email'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) =>
                    email != null && !EmailValidator.validate(email)
                        ? 'Enter a valid email'
                        : null,
              ),
              SizedBox(height: 4),
              TextFormField(
                controller: passwordController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 6
                    ? 'Enter min. 6 characters'
                    : null,
              ),
              SizedBox(height: 4),
              TextFormField(
                controller: confirmPasswordController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) =>
                    passwordController.text != confirmPasswordController.text
                        ? 'Passwords do not match'
                        : null,
              ),

              SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50),
                ),
                icon: Icon(Icons.arrow_forward, size: 32),
                label: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: signUp,
              ),
              SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  text: 'Already have an account?  ',
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickedSignIn,
                      text: 'Log In',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Future signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      print(e);

      Utils.showSnackBar(e.message);
    }

    // Navigator.of(context) not working!
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      );
}
