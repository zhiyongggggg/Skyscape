import 'package:flutter/material.dart';
import 'package:skyscape/screens/Feed/uploadpicture.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:skyscape/services/database.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<Map<String, dynamic>> _photos = [];
  final _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  Future<void> _fetchPhotos() async {
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

    setState(() {
      _photos = photos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //  appBar: AppBar(
        //title: const Text('Photos uploaded by other users'),
        //centerTitle: true,
        //backgroundColor: Colors.OR[200],
     // ),
      body: Container(
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
        child: _photos.isNotEmpty
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
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 255, 177, 67)),
                ),
              ),
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