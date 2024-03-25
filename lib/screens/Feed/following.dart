import 'package:flutter/material.dart';
import 'package:skyscape/services/auth.dart';
import 'package:skyscape/services/database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({Key? key}) : super(key: key);

  @override
  _FollowingPageState createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  final AuthService _auth = AuthService();
  List<String> followingList = [];
  List<Map<String, dynamic>> _photos = [];
  final _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _getFollowingList();
  }

  Future<void> _getFollowingList() async {
    final uid = _auth.currentUser!.uid;
    final databaseService = DatabaseService(uid: uid);
    final following = await databaseService.getFollowingList();
    setState(() {
      followingList = following;
    });
    _fetchPhotos();
  }

  Future<void> _fetchPhotos() async {
    final storageRef = FirebaseStorage.instance.ref().child('photos');
    final listResult = await storageRef.listAll();

    final photos = await Future.wait(
      listResult.items.map((ref) async {
        final metadata = await ref.getMetadata();
        final username = metadata.customMetadata?['username'] ?? 'Anonymous';
        final url = await ref.getDownloadURL();
        return {
          'url': url,
          'username': username,
        };
      }),
    );

    final followingPhotos = photos.where((photo) {
      final username = photo['username'];
      return followingList.contains(username);
    }).toList();

    setState(() {
      _photos = followingPhotos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _photos.isNotEmpty
          ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final photo = _photos[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Posted by ${photo['username']}',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[800],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          image: DecorationImage(
                            image: NetworkImage(photo['url']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            )
          : const Center(
              child: Text('No photos posted by followed users.'),
            ),
    );
  }
}