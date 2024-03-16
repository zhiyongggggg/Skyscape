import 'package:flutter/material.dart';

class NewDetailsPage extends StatefulWidget {
  @override
  _NewDetailsPageState createState() => _NewDetailsPageState();
}

class _NewDetailsPageState extends State<NewDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Details'),
      ),
      body: Center(
        child: Text('kieran this is for u'),
      ),
    );
  }
}