import 'package:cloud_firestore/cloud_firestore.dart';
import '../modals/category.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _categoriesCollection =
  FirebaseFirestore.instance.collection('categories');

  Stream<List<Category>> getCategories() {
    return _categoriesCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Category(
      id: doc.id,
      name: doc['name'],
    ))
        .toList());
  }
  Future<List<Category>> getCategoriesF() async {
    var snapshot = await _categoriesCollection.get();
    return snapshot.docs.map((doc) => Category(
      id: doc.id,
      name: doc['name'],
    )).toList();
  }

  Future<void> addCategory(Category category) async {
    await _categoriesCollection.add({
      'name': category.name,
    });
  }

  Future<void> updateCategory(Category category) async {
    await _categoriesCollection.doc(category.id).update({
      'name': category.name,
    });
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categoriesCollection.doc(categoryId).delete();
  }

  Future<String> getCategoryName(String categoryId) async {
    try {
      final doc = await _categoriesCollection.doc(categoryId).get();
      if (doc.exists) {
        return doc['name'];
      } else {
        return 'Unknown'; // Provide a default name if category does not exist
      }
    } catch (e) {
      print('Error fetching category: $e');
      throw e;
    }
  }

  Future<void> subscribeToCategory(String categoryId, String userId) async {
    final DocumentReference userRef =
    FirebaseFirestore.instance.collection('users').doc(userId);

    await userRef.update({
      'subscribedCategories': FieldValue.arrayUnion([categoryId])
    });
  }

  Future<void> unsubscribeFromCategory(
      String categoryId, String userId) async {
    final DocumentReference userRef =
    FirebaseFirestore.instance.collection('users').doc(userId);

    await userRef.update({
      'subscribedCategories': FieldValue.arrayRemove([categoryId])
    });
  }
}
