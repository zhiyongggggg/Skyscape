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
    listResult.items.take(10).map((ref) async {
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
    appBar: AppBar(
      title: const Text('Photos uploaded by other users'),
    ),
    body: _photos.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(30.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
              ),
              itemCount: _photos.length,
                itemBuilder: (context, index) {
                  final photo = _photos[index];
                  return Column(
                    children: [
                      Text(photo['username']),
                      Image.network(
                        photo['url'],
                        fit: BoxFit.cover,
                      ),
                    ],
                  );
                },
            ),
          )
        : const Center(child: CircularProgressIndicator()),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UploadPicture()),
        );
      },
      child: const Icon(Icons.camera),
    ),
  );
}
}