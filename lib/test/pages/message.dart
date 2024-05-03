import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'categories.dart';
import '../modals/message.dart';
import '../Services/message_service.dart';
import '../modals/category.dart';
import '../Services/catgory_service.dart';
import 'message1.dart';
import 'AddCategoryPage.dart';
import 'login.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _objectController = TextEditingController();
  Uint8List? _imageData;
  late User _currentUser;
  final MessageService _messageService = MessageService();
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];
  List<Category> _selectedCategories = [];

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
    try {
      final categories = await _categoryService.getCategories().first;
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> _addMessage() async {
    final body = _bodyController.text.trim();
    final object = _objectController.text.trim();

    if (_selectedCategories.isEmpty || body.isEmpty || object.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please fill in all fields',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    final newMessage = Message(
      id: '',
      categories: _selectedCategories.map((category) => category.id).toList(),
      body: body,
      object: object,
      imageData: _imageData,
      createdAt: DateTime.now(),
    );

    try {
      await _messageService.addMessage(newMessage);
      _bodyController.clear();
      _objectController.clear();
      setState(() {
        _imageData = null;
        _selectedCategories.clear();
      });
      Fluttertoast.showToast(
        msg: 'Message added',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      print('Error adding message: $e');
    }
  }

  Future<void> _getImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageData = Uint8List.fromList(bytes);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Message'),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20, // Add the desired height for the space at the top
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5), // Background color
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.all(10.0),
                child: ExpansionTile(
                  title: Text(
                    'Categories',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF363062)), // Text color
                  ),
                  children: [
                    SizedBox(height: 6),
                    Wrap(
                      children: _categories.map((category) {
                        return CheckboxListTile(
                          title: Text(category.name, style: TextStyle(color: Color(0xFF363062))), // Text color
                          value: _selectedCategories.contains(category),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value != null && value) {
                                _selectedCategories.add(category);
                              } else {
                                _selectedCategories.remove(category);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5), // Background color
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.all(10.0),
                child: TextField(
                  controller: _bodyController,
                  style: TextStyle(color: Color(0xFF363062)), // Text color
                  decoration: InputDecoration(
                    labelText: 'Body',
                    labelStyle: TextStyle(color: Color(0xFF363062)), // Label text color
                    hintText: 'Enter message body',
                    hintStyle: TextStyle(color: Color(0xFF363062)), // Hint text color
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF363062))), // Border color
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5), // Background color
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.all(10.0),
                child: TextField(
                  controller: _objectController,
                  style: TextStyle(color: Color(0xFF363062)), // Text color
                  decoration: InputDecoration(
                    labelText: 'Object',
                    labelStyle: TextStyle(color: Color(0xFF363062)), // Label text color
                    hintText: 'Enter message object',
                    hintStyle: TextStyle(color: Color(0xFF363062)), // Hint text color
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF363062))), // Border color
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: _imageData != null
                  ? Image.memory(
                _imageData!,
                height: 200,
              )
                  : Container(),
            ),
            SizedBox(height: 20),
            Center(
              child: Wrap(
                spacing: 15, // increased space between buttons
                runSpacing: 30, // increased space between rows
                alignment: WrapAlignment.spaceEvenly, // evenly distribute the available horizontal space
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.image, color: Colors.white),
                    label: Text('Pick Image', style: TextStyle(color: Colors.white)),
                    onPressed: _getImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF99417), // Button color
                      minimumSize: Size(150, 40), // maintain button size
                      // wider padding
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.send, color: Colors.white),
                    label: Text('Add Message', style: TextStyle(color: Colors.white)),
                    onPressed: _addMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF99417), // Button color
                      minimumSize: Size(150, 40), // maintain button size
                      // wider padding
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
