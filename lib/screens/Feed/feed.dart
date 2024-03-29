import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skyscape/screens/Feed/uploadpicture.dart';
import 'package:skyscape/screens/loading/loading.dart';
import 'package:skyscape/services/database.dart';
import 'package:skyscape/screens/Feed/following.dart';
import 'package:skyscape/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skyscape/screens/Search/followedusers.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with SingleTickerProviderStateMixin {
  final _databaseService = DatabaseService();
  final AuthService _auth = AuthService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<List<Map<String, dynamic>>> _fetchPhotos() {
    return _databaseService.userCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        final photos = data?['photoURLs'] as List<dynamic>? ?? [];
        final username = data?['username'] as String? ?? 'Anonymous';
        final userId = doc.id;
        return photos.map((photo) {
          return {
            'url': photo['url'],
            'username': username,
            'userId': userId,
            'timestamp': photo['timestamp'],
          };
        }).toList();
      }).expand((element) => element).toList()
        ..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    });
  }

  void _navigateToFollowedUser(String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowedUser(username: username),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[200],
      body: Column(
        children: [
          Container(
            color: Colors.orange[200],
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'For you'),
                Tab(text: 'Following'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Container(
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
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _fetchPhotos(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Loading();
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        final photos = snapshot.data!;
                        return photos.isNotEmpty
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
                                    itemCount: photos.length,
                                    itemBuilder: (context, index) {
                                      final photo = photos[index];
                                      final timestamp = photo['timestamp'] as int?;
                                      final formattedTime = timestamp != null
                                          ? DateFormat('yyyy-MM-dd HH:mm').format(
                                              DateTime.fromMillisecondsSinceEpoch(timestamp),
                                            )
                                          : '';
                                      final userId = photo['userId'];
                                      final username = photo['username'];
                                      return StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(userId)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            final userData = snapshot.data!.data() as Map<String, dynamic>?;
                                            final profilePicture = userData?['profilePicture'] ?? '';
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                ListTile(
                                                  leading: GestureDetector(
                                                    onTap: () => _navigateToFollowedUser(username),
                                                    child: CircleAvatar(
                                                      backgroundImage: profilePicture.isNotEmpty
                                                          ? NetworkImage(profilePicture)
                                                          : AssetImage('assets/default_profile.jpg') as ImageProvider,
                                                    ),
                                                  ),
                                                  title: GestureDetector(
                                                    onTap: () => _navigateToFollowedUser(username),
                                                    child: Text(username),
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
                                                const SizedBox(height: 8),
                                                Text(
                                                  formattedTime,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            );
                                          } else if (snapshot.hasError) {
                                            return Center(
                                              child: Text('Error loading user data'),
                                            );
                                          } else {
                                            return Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              )
                            : const Center(
                                child: Text('No photos available.'),
                              );
                      } else {
                        return const Center(
                          child: Text('No data available.'),
                        );
                      }
                    },
                  ),
                ),
                FollowingPage(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UploadPicture()),
          );
        },
        child: const Icon(Icons.camera, size: 30),
        backgroundColor: Color.fromARGB(255, 255, 178, 83),
      ),
    );
  }
}