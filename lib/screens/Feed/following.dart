import 'package:flutter/material.dart';
import 'package:skyscape/screens/loading/loading.dart';
import 'package:skyscape/services/database.dart';
import 'package:skyscape/services/auth.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({Key? key}) : super(key: key);

  @override
  _FollowingPageState createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  final _databaseService = DatabaseService();
  final AuthService _auth = AuthService();
  List<Map<String, dynamic>> _photos = [];
  List<String> _followingList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  Future<void> _fetchPhotos() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final followingList = await DatabaseService(uid: currentUser.uid).getFollowingList();
      final photos = await _databaseService.getFollowingPhotos(followingList);
      setState(() {
        _photos = photos;
        _followingList = followingList;
        _isLoading = false;
      });
    }
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
              : _followingList.isNotEmpty
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Following:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _followingList.length,
                              itemBuilder: (context, index) {
                                final username = _followingList[index];
                                return ListTile(
                                  title: Text(username),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Center(
                      child: Text('You are not following any users.'),
                    ),
    );
  }
}