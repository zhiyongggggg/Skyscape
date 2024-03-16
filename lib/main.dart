import 'package:flutter/material.dart';
import 'package:skyscape/models/newuser.dart';
import 'package:skyscape/screens/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:skyscape/services/auth.dart';
import 'package:skyscape/screens/home/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: const FirebaseOptions(
    //   apiKey: "AIzaSyCAXx9i-CR4HocmI6JVjWIQyEZSktKSQyo",
    //   appId: "1:193819026704:android:662e53c9dc00f464733195",
    //   messagingSenderId: "193819026704",
    //   projectId: "ninja-brew-b1a36",
    // ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<Newuser?>.value(
      initialData: null,
      value: AuthService().user,
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => const Wrapper(),
          '/home': (context) => const Home(),
        },
      ),
    );
  }
}