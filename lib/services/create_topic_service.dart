import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateTopicService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> createTopic({
    required String title,
    required String description,
    required String categoryId,
    required String categoryName,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;

    await _firestore.collection("topics").add({
      "title": title,
      "description": description,
      "categoryId": categoryId,
      "categoryName": categoryName,
      "createdBy": user.uid,
      "creatorName": user.displayName,
      "creatorEmail": user.email,
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
      "participantsCount": 0,
      "reportsCount": 0,
    });
  }
}