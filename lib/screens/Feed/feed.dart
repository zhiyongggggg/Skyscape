import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:skyscape/screens/Feed/uploadpicture.dart';


class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
      ),
      body: Center(
        child: Text('gonna implement sth like ig home page,things to implement \n1. View folliwing users \n2. view photos posted by them and by user \n3. button to upload photos for user \n but maybe instead of following users the feeed can jsut be about looking at what other users posted'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UploadPicture()),
              );
            },
            child: const Text('Upload Picture'),
          ),
        ),
      ),
    );
  }
}