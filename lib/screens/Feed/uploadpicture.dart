import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:skyscape/services/database.dart';
import 'package:skyscape/services/auth.dart';

class UploadPicture extends StatefulWidget {
  const UploadPicture({super.key});

  @override
  State<UploadPicture> createState() => _UploadPictureState();
}

class _UploadPictureState extends State<UploadPicture> {
  File? _selectedImage;
  bool _isUploading = false;

  final AuthService _auth = AuthService();

  Future<void> _selectImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('user_photos/${_auth.currentUser!.uid}.jpg');
      final uploadTask = storageRef.putFile(_selectedImage!);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Save photo URL to user document in Firestore
      await DatabaseService(uid: _auth.currentUser!.uid).savePhotoUrl(downloadUrl);

      setState(() {
        _selectedImage = null;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Upload Picture'),
            GestureDetector(
              onTap: () => _selectImage(ImageSource.gallery),
              child: Container(
                alignment: Alignment.center,
                child: _selectedImage == null
                    ? Text(
                        'No Picture Uploaded Yet',
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      )
                    : Text("Picture is selected, upload button should work")
              ),
            ),
            SizedBox(height: 30),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectImage(ImageSource.camera),
              child: const Text('Take Picture'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _selectImage(ImageSource.gallery),
              child: const Text('Choose From Gallery'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadImage,
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}