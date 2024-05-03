import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'AddCategoryPage.dart';
import 'CreateMessagePage.dart';
import 'student.dart';

import 'register.dart';

import '../../components/curved-left-shadow.dart';
import '../../components/curved-left.dart';
import '../../components/curved-right-shadow.dart';
import '../../components/curved-right.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  bool _isObscure = true;
  bool visible = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  late AnimationController _animationController;
  late Animation<double> _buttonAnimation;
  late Animation<double> _textFieldAnimation;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.6, 1.0, curve: Curves.easeInOut),
    ));

    _textFieldAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.3, 0.8, curve: Curves.easeInOut),
    ));

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            Positioned(top: 0, left: 0, child: CurvedLeftShadow()),
            Positioned(top: 0, left: 0, child: CurvedLeft()),
            Positioned(bottom: 0, left: 0, child: CurvedRightShadow()),
            Positioned(bottom: 0, left: 0, child: CurvedRight()),
            SingleChildScrollView(
              child: Container(
                height: size.height,
                width: size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FadeTransition(
                      opacity: _logoAnimation,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50.0),
                        child: Text(
                          "Login",
                          style: TextStyle(fontSize: 37.0, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(_textFieldAnimation),
                      child: Stack(
                        children: <Widget>[
                          Container(
                            height: 150.0,
                            padding: EdgeInsets.only(left: 10.0),
                            margin: EdgeInsets.only(right: 40.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 20.0,
                                )
                              ],
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(90.0),
                                bottomRight: Radius.circular(90.0),
                              ),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  TextFormField(
                                    controller: emailController,
                                    style: TextStyle(fontSize: 18.0),  // Reduced font size
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 15.0,
                                      ),
                                      icon: Icon(
                                        Icons.person_outline,
                                        size: 24.0,
                                      ),
                                      hintText: "Email",
                                      border: InputBorder.none,
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) return "Email cannot be empty";
                                      if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
                                        return "Please enter a valid email";
                                      }
                                      return null;
                                    },
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[200] ?? Colors.grey,
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: passwordController,
                                    obscureText: _isObscure,
                                    style: TextStyle(fontSize: 18.0),  // Reduced font size
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 15.0,
                                      ),
                                      icon: Icon(
                                        Icons.lock_outline,
                                        size: 24.0,
                                      ),
                                      hintText: "Password",
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 40,
                            right: 10,
                            child: FadeTransition(
                              opacity: _buttonAnimation,
                              child: GestureDetector(
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    signIn(emailController.text, passwordController.text);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(15.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xFFF99417), // Light teal color #ECF8F6
                                        Color(0xFFF99417)
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10.0,
                                      )
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    size: 40.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FadeTransition(
                      opacity: _buttonAnimation,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "Register");
                        },
                        child: Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF99417),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent, // Remove shadow
                          elevation: 0, // No elevation for a flat appearance
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      route();
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else {
        errorMessage = 'An error occurred: ${e.message}';
      }
      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print(errorMessage);
    }
  }

  void route() {
    User? user = _auth.currentUser;
    FirebaseFirestore.instance.collection('users').doc(user!.uid).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('role') == "Admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AddCategoryPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StudentSubscriptionPage()),
          );
        }
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
