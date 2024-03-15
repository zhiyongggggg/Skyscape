import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // Collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future<void> updateUserData(String username) async {
    return await userCollection.doc(uid).set({
      'username': username,
    });
  }

  // Get user document stream
  Stream<QuerySnapshot> get users {
    return userCollection.snapshots();
  }
}