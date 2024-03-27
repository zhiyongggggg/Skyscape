import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skyscape/services/storage.dart';

class EditAccount extends StatefulWidget {
  @override
  _EditAccountState createState() => _EditAccountState();
}

class _EditAccountState extends State<EditAccount> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  String _profilePicture = '';

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final userData = snapshot.data() as Map<String, dynamic>?;
      _usernameController.text = userData?['username'] ?? '';
      setState(() {
        _profilePicture = userData?['profilePicture'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _uploadProfilePicture() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final downloadURL = await StorageService().uploadProfilePicture(
          currentUser.uid,
          pickedFile.path,
        );
        setState(() {
          _profilePicture = downloadURL;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final newUsername = _usernameController.text.trim();

        // Check if the new username already exists in the database
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: newUsername)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Username already exists
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Username already taken')),
          );
          return;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'username': newUsername,
          'profilePicture': _profilePicture,
        });
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _uploadProfilePicture,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profilePicture.isNotEmpty
                        ? NetworkImage(_profilePicture)
                        : AssetImage('assets/default_profile.png') as ImageProvider,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}