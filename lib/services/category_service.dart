import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> categoriesStream() {
    return _firestore
        .collection("categories")
        .where("approved", isEqualTo: true)
        .snapshots();
  }

  Future<void> submitCategoryRequest(String name) async {
    final user = FirebaseAuth.instance.currentUser!;

    await _firestore.collection("categories").add({
      "name": name.trim(),
      "createdBy": user.uid,
      "createdByName": user.displayName,
      "createdByEmail": user.email,
      "approved": false,
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
      "reviewedBy": null,
      "reviewedAt": null,
    });
  }
}
