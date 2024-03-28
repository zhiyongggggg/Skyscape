import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FollowedUser extends StatefulWidget {
  final String username;

  const FollowedUser({required this.username});

  @override
  _FollowedUserState createState() => _FollowedUserState();
}

class _FollowedUserState extends State<FollowedUser> {
  late Stream<DocumentSnapshot> _userStream;

  @override
  void initState() {
    super.initState();
    _userStream = FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: widget.username)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.amber[400],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            final profilePicture = userData?['profilePicture'] ?? '';

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 200,
                    color: Color.fromARGB(215, 248, 245, 90),
                    child: Center(
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: profilePicture.isNotEmpty
                            ? NetworkImage(profilePicture)
                            : AssetImage('assets/default_profile.jpg') as ImageProvider,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Images posted by ${widget.username}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        // Placeholder for images posted by the user
                        Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: Center(
                            child: Text(
                              'Image',
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}