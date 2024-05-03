import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import '../../components/curved-left-shadow.dart';
import '../../components/curved-left.dart';
import '../../components/curved-right-shadow.dart';
import '../../components/curved-right.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();
  bool _isObscure = true;
  bool _isObscure2 = true;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            //Positioned(top: 0, left: 0, child: CurvedLeftShadow()),
            // Positioned(top: 0, left: 0, child: CurvedLeft()),
            Positioned(bottom: 0, left: 0, child: CurvedRightShadow()),
            Positioned(bottom: 0, left: 0, child: CurvedRight()),
            SingleChildScrollView(
              child: Container(
                height: size.height,
                width: size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 20), // Increased top padding here
                      child: Text(
                        "Register",
                        style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 20), // Added padding to lift the form components
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            buildTextFormField(emailController, "Email", Icons.email),
                            SizedBox(height: 15),
                            buildTextFormField(passwordController, "Password", Icons.lock),
                            SizedBox(height: 15),
                            buildTextFormField(confirmpassController, "Confirm Password", Icons.lock),
                            SizedBox(height: 30),
                            GestureDetector(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  signUp(emailController.text, passwordController.text);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xFFF99417), // Light teal color #ECF8F6
                                      Color(0xFFF99417),
                                    ],
                                  ),
                                ),
                                child: Icon(Icons.arrow_forward, color: Colors.white, size: 30),
                              ),
                            ),
                            SizedBox(height: 10), // Added SizedBox for spacing
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                              },
                              child: Text("Already have an account? "),
                            ),
                          ],
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

  TextFormField buildTextFormField(TextEditingController controller, String hint, IconData icon) {
    return TextFormField(
      controller: controller,
      obscureText: hint.contains("Password"),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: hint,
        border: UnderlineInputBorder(),
      ),
      validator: (value) {
        if (value!.isEmpty) return "$hint cannot be empty";
        if (hint == "Email" && !RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return "Enter a valid email";
        }
        if (hint.contains("Password") && value.length < 6) {
          return "Password must be at least 6 characters";
        }
        if (hint == "Confirm Password" && value != passwordController.text) {
          return "Passwords do not match";
        }
        return null;
      },
    );
  }

  void signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      postDetailsToFirestore();
    } catch (e) {
      String errorMessage = 'An error occurred during registration';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'The password provided is too weak.';
            break;
          case 'email-already-in-use':
            errorMessage = 'The account already exists for that email.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
        // Handle other FirebaseAuthException codes as needed
          default:
            errorMessage = 'An error occurred during registration: ${e.code}';
            break;
        }
      } else {
        errorMessage = 'An unexpected error occurred: $e';
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

  postDetailsToFirestore() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    await firebaseFirestore.collection('users').doc(user!.uid).set({
      'email': user.email,
      'role': 'Student',
    });
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }
}
