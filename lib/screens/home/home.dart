import 'package:skyscape/services/auth.dart';
import 'package:flutter/material.dart';


class Home extends StatelessWidget {

  // Home({super.key});

  final AuthService _auth = AuthService();

  Home({super.key}); //instance of this
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      appBar: AppBar(
        title: const Text('Skyscape'),
        backgroundColor: Colors.amber[400],
        elevation: 0.0,
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.person),
            label: const Text('logout'),
            onPressed: () async{
              print("logout button is pressed");
              await _auth.signOut();
            },
          )
        ],
      ),
    );          //can add appbar and everything
  }
}