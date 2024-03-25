import 'package:flutter/material.dart';
import 'package:skyscape/screens/Feed/uploadpicture.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:skyscape/screens/loading/loading.dart';
import 'package:skyscape/services/database.dart';
import 'package:skyscape/screens/Feed/following.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with SingleTickerProviderStateMixin {
  final _databaseService = DatabaseService();
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

  Future<List<Map<String, dynamic>>> _fetchPhotos() async {
    final storageRef = FirebaseStorage.instance.ref().child('photos');
    final listResult = await storageRef.listAll();

    final photos = await Future.wait(
      listResult.items.take(20).map((ref) async {
        final metadata = await ref.getMetadata();
        final username = metadata.customMetadata?['username'] ?? 'Anonymous';
        final url = await ref.getDownloadURL();
        return {
          'url': url,
          'username': username,
        };
      }),
    );

    return photos;
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
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchPhotos(),
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
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Posted by ' + photo['username'],
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
                const FollowingPage(),
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