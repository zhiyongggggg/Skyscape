import 'package:flutter/material.dart';
import 'package:skyscape/screens/loading/loading.dart';
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
  bool _isLoading = true;

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
    await _fetchPhotos();
    setState(() {
      _isLoading = false;
    });
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color.fromARGB(255, 255, 225, 181)!,
            Colors.orange[100]!,
            Color.fromARGB(255, 243, 213, 245)!,
            Color.fromARGB(255, 250, 217, 182)!,
          ],
          stops: [0.1, 0.3, 0.5, 0.8],
        ),
      ),
      child: _isLoading
          ? Loading()
          : _photos.isNotEmpty
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                    ),
                  ),
                )
              : const Center(
                  child: Text('No photos posted by followed users.'),
                ),
    );
  }
}