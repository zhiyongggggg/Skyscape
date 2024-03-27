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
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  String _profilePicture = '';

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
        final newPassword = _passwordController.text.trim();
        final confirmPassword = _confirmPasswordController.text.trim();

        final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
        final userData = await userRef.get();
        final oldUsername = userData.data()?['username'] ?? '';

        final updateData = <String, dynamic>{};

        if (newUsername != oldUsername) {
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

          updateData['username'] = newUsername;
        }

        if (_profilePicture.isNotEmpty) {
          updateData['profilePicture'] = _profilePicture;
        }

        if (newPassword.isNotEmpty) {
          if (newPassword == confirmPassword) {
            await currentUser.updatePassword(newPassword);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Passwords do not match')),
            );
            return;
          }
        }

        if (updateData.isNotEmpty) {
          await userRef.update(updateData);
        }

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _uploadProfilePicture,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _profilePicture.isNotEmpty
                            ? NetworkImage(_profilePicture)
                            : const AssetImage('assets/default_profile.jpg') as ImageProvider,
                        backgroundColor: Colors.grey[200],
                      ),
                      const SizedBox(height: 8),
                      const Text('Choose a new profile picture'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm New Password'),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}