import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Services/message_service.dart';
import '../Services/catgory_service.dart';
import '../modals/message.dart';
import '../modals/category.dart';
import 'login.dart';
import 'categories.dart';
import 'message.dart';
import 'AddCategoryPage.dart';
import 'package:image/image.dart' as imagelib;
import 'pop.dart';
class MessageListPage extends StatefulWidget {
  @override
  _MessageListPageState createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  final MessageService messageService = MessageService();
  final CategoryService categoryService = CategoryService();
  Uint8List? _imageData;
  late User _currentUser;
  String? _currentUserEmail;

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
  void initState() {
    _getCurrentUser();
    super.initState();
  }

  Future<void> _getCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUser = currentUser!;
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
      body: StreamBuilder<List<Message>>(
        stream: messageService.getMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final messages = snapshot.data ?? [];
          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return FutureBuilder<List<String>>(
                future: Future.wait(message.categories.map((categoryId) => categoryService.getCategoryName(categoryId))),
                builder: (context, categorySnapshot) {
                  if (categorySnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (categorySnapshot.hasError) {
                    return Text('Error: ${categorySnapshot.error}');
                  }
                  final categoryNames = categorySnapshot.data ?? [];
                  final categoryName = categoryNames.join(', ');
                  return InkWell(
                    onTap: () => _showDeleteConfirmation(context, message),
                    child: Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF363062), width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ExpansionTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(message.object),
                                Text(categoryName),
                                Text(
                                  '${message.createdAt.day}/${message.createdAt.month}/${message.createdAt.year} ${message.createdAt.hour}:${message.createdAt.minute}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () => _showUpdateDialog(context, message),
                              child: Text('Update', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF363062)),
                            ),
                          ],
                        ),
                        children: [
                          if (message.body.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                              child: Text(message.body, style: TextStyle(fontSize: 16)),
                            ),
                          if (message.imageData != null)
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.scaleDown,
                                  image: MemoryImage(message.imageData!),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MessagePage())),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Message message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this message?'),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Cancel button
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFFF99417)),
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Confirm button
                  messageService.deleteMessage(message.id);
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Color(0xFFF99417)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  Widget _buildImageWidget(Uint8List? imageData) {
    if (imageData != null && imageData.isNotEmpty) {
      return Align(
        alignment: Alignment.centerLeft,

        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: MemoryImage(imageData),
            ),
          ),
        ),

      );
    } else {
      return SizedBox.shrink(); // Use SizedBox.shrink() as fallback when imageData is null or empty
    }
  }
  void _showUpdateDialog(BuildContext context, Message message) {
    TextEditingController objectController = TextEditingController(text: message.object);
    TextEditingController bodyController = TextEditingController(text: message.body);

    // Initialize selected categories from the message
    List<String> selectedCategoryIds = List.from(message.categories);
    List<Category> selectedCategories = [];

    final CategoryService categoryService = CategoryService();

    // Fetch categories once and use them for display and selection
    Future<List<Category>> categoriesFuture = categoryService.getCategoriesF();

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<Category>>(
          future: categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(content: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return AlertDialog(content: Text('Error loading categories: ${snapshot.error.toString()}'));
            }

            // Once categories are fetched, filter out the selected ones
            List<Category> allCategories = snapshot.data ?? [];
            selectedCategories = allCategories.where((cat) => selectedCategoryIds.contains(cat.id)).toList();

            return AlertDialog(
              title: Text('Update Message'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: objectController,
                      decoration: InputDecoration(labelText: 'Object'),
                    ),
                    TextField(
                      controller: bodyController,
                      decoration: InputDecoration(labelText: 'Body'),
                    ),
                    _buildImageWidget(message.imageData),
                    Center(
                      child: ElevatedButton(
                        onPressed: _getImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF99417), // Button color
                          fixedSize: Size(180, 40), // Smaller button size
                        ),
                        child: Text('Choose Image'),
                      ),
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          final List<Category>? updatedCategories = await showMultiSelectPopup(context, allCategories, selectedCategories);
                          if (updatedCategories != null) {
                            setState(() {
                              selectedCategories = updatedCategories;
                              selectedCategoryIds = updatedCategories.map((c) => c.id).toList();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF99417),
                          fixedSize: Size(180, 40),
                        ),
                        child: Text('Select Categories'),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF99417),
                        fixedSize: Size(100, 40), // Smaller 'Cancel' button size
                      ),
                      child: Text('Cancel'),
                    ),
                    SizedBox(width: 10), // Smaller spacing between buttons
                    ElevatedButton(
                      onPressed: () {
                        Message updatedMessage = Message(
                          id: message.id,
                          categories: selectedCategoryIds,
                          object: objectController.text,
                          body: bodyController.text,
                          imageData: _imageData ?? message.imageData,
                          createdAt: message.createdAt,
                        );
                        messageService.updateMessage(updatedMessage);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF99417),
                        fixedSize: Size(100, 40), // Smaller 'Update' button size
                      ),
                      child: Text('Update'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<Category>?> showMultiSelectPopup(BuildContext context, List<Category> options, List<Category> selectedCategories) {
    return Navigator.of(context).push(MultiSelectPopup<Category>(
      options: options,
      initialValue: List.from(selectedCategories),
      itemBuilder: (BuildContext context, Category category, bool isSelected) {
        return ListTile(
          title: Text(category.name),
          trailing: Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank),
          onTap: () {
            if (isSelected) {
              selectedCategories.remove(category);
            } else {
              selectedCategories.add(category);
            }
            Navigator.of(context).pop(selectedCategories);
          },
        );
      },
    ));
  }
}
