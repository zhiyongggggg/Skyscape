import 'package:flutter/material.dart';

class FollowedUser extends StatelessWidget {
  final String username;

  const FollowedUser({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
      ),
      body: Center(
        child: Text('This is the page for user: $username'),
      ),
    );
  }
}