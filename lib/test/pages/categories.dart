import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'AddCategoryPage.dart';
import 'login.dart';
import '../Services/catgory_service.dart';
import 'message.dart';
import 'message1.dart';
import '../modals/category.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final CategoryService _categoryService = CategoryService();
  late List<Category> _categories = [];
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUser = currentUser!;
    });
  }

  Future<void> _fetchCategories() async {
    final categories = await _categoryService.getCategories().first;
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _deleteCategory(Category category) async {
    await _categoryService.deleteCategory(category.id);
    _fetchCategories(); // Refresh categories after deletion
  }

  Widget _buildCategoriesTable() {
    return ListView.separated(
      padding: EdgeInsets.all(8),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: ListTile(
            title: Text(category.name),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Color(0xFFF99417)),
              onPressed: () => _deleteCategory(category),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => SizedBox(height: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
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
      body: Container(
        color: Color(0xFFF5F5F5),
        child: _buildCategoriesTable(),
      ),
    );
  }
}
