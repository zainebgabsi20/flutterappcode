import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import fluttertoast package

import 'categories.dart';
import 'login.dart';
import 'studentmessage.dart';
import '../Services/catgory_service.dart';
import '../modals/category.dart';
import '../../components/curved-left-shadow.dart';
import '../../components/curved-left.dart';
import '../../components/curved-right-shadow.dart';
import '../../components/curved-right.dart';
import 'CreateMessagePage.dart';
import 'message.dart';
import 'message1.dart';

class AddCategoryPage extends StatefulWidget {
  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  late User _currentUser;
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _categoryNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUser = currentUser!;
    });
  }

  Future<void> _addCategory() async {
    final categoryName = _categoryNameController.text.trim();
    if (categoryName.isNotEmpty) {
      final newCategory = Category(id: 'temp_id', name: categoryName);
      await _categoryService.addCategory(newCategory);
      _categoryNameController.clear();
      _showToast('Category added successfully'); // Show toast message

    }
  }

  // Method to show toast message
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Category'),
      ),
      drawer: Drawer(
        child: Container(
          color: Color(0xFF363062), // Background color of the sidebar
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/logo.png', // Path to your logo image
                      width: 100, // Adjust width as needed
                      height: 100, // Adjust height as needed
                    ),
                    Text(
                      _currentUser != null ? _currentUser.email! : '',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF363062),
                ),
              ),

              ListTile(
                leading: Icon(Icons.logout, color: Colors.white),
                title: Text('Logout', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.message, color: Colors.white),
                title: Text('Messages', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MessageListPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.category, color: Colors.white),
                title: Text('Categories', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoriesPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.add_box, color: Colors.white),
                title: Text('Add categories', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddCategoryPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.add_circle, color: Colors.white),
                title: Text('Add messages', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MessagePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(bottom: 0, left: 0, child: CurvedRightShadow()),
          Positioned(bottom: 0, left: 0, child: CurvedRight()),
          Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 20), // Adjust this value to lift the components up
                    child: TextField(
                      controller: _categoryNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter category name',
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 20), // Adjust this value to lift the components up
                    child: ElevatedButton(
                      onPressed: _addCategory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF99417), // Button color
                      ),
                      child: Text(
                        'Add Category',
                        style: TextStyle(
                          color: Colors.white, // Text color
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
