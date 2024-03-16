import 'package:flutter/material.dart';

class ViewDetails extends StatelessWidget {
  final String location;

  ViewDetails({required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details for $location'),
      ),
      body: Center(
        child: Text(
          'KIERAN work here',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
