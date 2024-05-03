import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import'studentmessage.dart';

class StudentSubscriptionPage extends StatefulWidget {
  @override
  _StudentSubscriptionPageState createState() => _StudentSubscriptionPageState();
}

class _StudentSubscriptionPageState extends State<StudentSubscriptionPage> {
  late User? _currentUser ;
  late List<DocumentSnapshot> _categories = [];

  late List<String> _subscribedCategories = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();

    _fetchCategories();



  }

  Future<void> _fetchCategories() async {
    final categories = await FirebaseFirestore.instance.collection('categories').get();
    setState(() {

      _categories = categories.docs;

    });
  }
  Future<void> _getCurrentUser() async {
    final currentUser =   FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      setState(() {
        _currentUser = currentUser;
        _subscribedCategories = List<String>.from(userDoc.get('categories') ?? []);
      });

    }
  }



  void _toggleSubscription(String categoryId) {
    setState(() {
      if (_isSubscribed(categoryId)) {
        _subscribedCategories.remove(categoryId);
      } else {
        _subscribedCategories.add(categoryId);
      }
    });

    _updateUserCategories(_subscribedCategories);
  }

  Future<void> _updateUserCategories(List<String> categories) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid);
    await userDoc.update({'categories': categories});
  }

  bool _isSubscribed(String categoryId) {
    return _subscribedCategories.contains(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription'),
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
                      '${_currentUser!.email}',
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
                title: Text('Student Messages', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StudentMessagesPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final categoryId = category.id;
          final categoryName = category.get('name');
          final isSubscribed = _isSubscribed(categoryId);

          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white, // Background color of the card
              border: Border.all(color: isSubscribed ? Color(0xFFF99417) : Color(0xFF4D4C7D)), // Border color
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              title: Text(
                categoryName,
                style: TextStyle(color: Colors.black), // Text color of the category name
              ),
              trailing: SizedBox(
                width: 130, // Adjust the width as needed
                child: ElevatedButton(
                  onPressed: () => _toggleSubscription(categoryId),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: isSubscribed ? Color(0xFFF99417) : Color(0xFF4D4C7D),
                  ),
                  child: Text(isSubscribed ? 'Unsubscribe' : 'Subscribe'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
