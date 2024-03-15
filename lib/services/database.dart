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

  Future<void> saveFavouritedLocations(List<String> locations) async {
    DocumentReference documentReference = userCollection.doc(uid);
    DocumentSnapshot snapshot = await documentReference.get();
    
    if (snapshot.exists) {
      // Document exists, update it
      return await documentReference.update({
        'favouritedLocations': locations,
      });
    } else {
      // Document doesn't exist, create it
      return await documentReference.set({
        'favouritedLocations': locations,
      });
    }
  }

  Future<List<String>> getFavouritedLocations() async {
    DocumentSnapshot snapshot = await userCollection.doc(uid).get();
    if (snapshot.exists) {
      List<dynamic> locations = snapshot.get('favouritedLocations');
      return locations.map((location) => location.toString()).toList();
    }
    return [];
  }
}