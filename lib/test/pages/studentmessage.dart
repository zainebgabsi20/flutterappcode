import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as imagelib;
import '../Services/message_service.dart';
import '../Services/catgory_service.dart';
import 'login.dart';
import'student.dart';
class StudentMessagesPage extends StatefulWidget {
  @override
  _StudentMessagesPageState createState() => _StudentMessagesPageState();
}

class _StudentMessagesPageState extends State<StudentMessagesPage> {
  late User? _currentUser;
  late List<String> _subscribedCategories = [];
  late List<String> _filteredMessageIds = [];
  final CategoryService categoryService = CategoryService();

  @override
  void initState() {
    _getCurrentUser();
    super.initState();




  }

  Future<void> _getCurrentUser() async {
    final currentUser =  FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      setState(() {
        _currentUser = currentUser;
        _subscribedCategories = List<String>.from(userDoc.get('categories') ?? []);
      });
      _filterMessagesByCategories();
    }
  }

  Future<void> _filterMessagesByCategories() async {
    final allMessages = await FirebaseFirestore.instance.collection('messages').get().then((snapshot) => snapshot.docs);
    final filteredMessages = allMessages.where((message) {
      final List<dynamic> categories = message.get('categories') ?? [];
      return categories.any((category) => _subscribedCategories.contains(category));
    }).toList();
    setState(() {

      _filteredMessageIds = filteredMessages.map((message) => message.id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
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
                      '${_currentUser!.email!}',
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
                leading: Icon(Icons.category_outlined, color: Colors.white),
                title: Text('View categories', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StudentSubscriptionPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('messages').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final messages = snapshot.data!.docs;
          final filteredMessages = messages.where((message) => _filteredMessageIds.contains(message.id)).toList();
          return ListView.builder(
            itemCount: filteredMessages.length,
            itemBuilder: (context, index) {
              final message = filteredMessages[index];
              final DateTime createdAt = (message.get('createdAt') as Timestamp).toDate();
              final String body = message.get('body');
              final String object = message.get('object');
              Uint8List? imageData;
              try {
                imageData = message.get('imageData') != null ? base64Decode(message.get('imageData')) : null;
                // Decode using the image library
                if (imageData != null) {
                  imagelib.Image decodedImage = imagelib.decodeImage(imageData)!;
                  imageData = imagelib.encodeJpg(decodedImage); // Re-encode as JPEG
                }
              } catch (e) {
                print('Error decoding image for message ${message.id}');
                imageData = null;
              }


              return Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF363062), width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ExpansionTile(
                  leading: _buildLeadingWidget(),
                  title: Text(object),
                  subtitle: Text('${DateFormat('dd/MM/yyyy hh:mm').format(createdAt)}'),
                  children: [
                    if (imageData != null)
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.scaleDown,
                            image: MemoryImage(imageData),
                          ),
                        ),
                      ),
                    ListTile(
                      title: Text(body),
                    ),
                    // Add more ListTile widgets for other information like image, etc.
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLeadingWidget() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Color(0xFF363062), width: 2),
        color: Color(0xFF363062),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/logo.png'),
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }

}
