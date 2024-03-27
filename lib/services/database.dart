import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // Collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future<void> updateUserData(String username) async {
    return await userCollection.doc(uid).set({
      'username': username,
      'favouritedLocations': [],
      'followingList': [],
      'profilePicture': "",
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

  Future<String> findUsername(String username) async {
    try {
      var snapshot = await userCollection.where('username', isEqualTo: username).get();
      
      // Check if any documents were found with the provided username
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['username'];
      } else {
        return "No user found.";
      }
    } catch (e) {
      print('getUsers: Error retrieving user data: $e');
      return "Error retrieving user data.";
    }
  }

  Future<void> followUser(String username) async {
    DocumentReference documentReference = userCollection.doc(uid);
    DocumentSnapshot snapshot = await documentReference.get();
    
    if (snapshot.exists) {
      // Document exists, update it
      return await documentReference.update({
        'followingList': FieldValue.arrayUnion([username]),
      });
    } else {
      // Document doesn't exist, create it
      return await documentReference.set({
        'followingList': [username],
      });
    }
  }

  Future<void> unfollowUser(String username) async {
    return await userCollection.doc(uid).update({
      'followingList': FieldValue.arrayRemove([username]),
    });
  }

  Future<List<String>> getFollowingList() async {
    DocumentSnapshot snapshot = await userCollection.doc(uid).get();
    if (snapshot.exists) {
      List<dynamic> following = snapshot.get('followingList');
      return following.map((user) => user.toString()).toList();
    }
    return [];
  }

  Future<void> removeFavouritedLocation(String location) async {
    return await userCollection.doc(uid).update({
      'favouritedLocations': FieldValue.arrayRemove([location]),
    });
  }

  Future<void> saveFavouritedLocation(String location) async {
    return await userCollection.doc(uid).set({
      'favouritedLocations': FieldValue.arrayUnion([location]),
    }, SetOptions(merge: true));
  }

Future<void> savePhotoUrl(String photoUrl, String userId) async {
  final timestamp = DateTime.now().millisecondsSinceEpoch;

  final photoData = {
    'url': photoUrl,
    'timestamp': timestamp,
    'userId': userId,
  };

  return await userCollection.doc(uid).update({
    'photos': FieldValue.arrayUnion([photoData]),
  });
}



  // Add a method to get the photo data for the current user
  Stream<List<Map<String, dynamic>>> get userPhotos {
    return userCollection.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      final photos = data?['photos'] as List<dynamic>? ?? [];
      return photos.cast<Map<String, dynamic>>();
    });
  }
  Future<Map<String, dynamic>> getUserData(String uid) async {
    DocumentSnapshot snapshot = await userCollection.doc(uid).get();
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    }
    return {'username': 'Anonymous'}; // Return a default value if the user document doesn't exist
  }

}