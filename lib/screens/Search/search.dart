import 'package:flutter/material.dart';
import 'package:skyscape/screens/home/home.dart';
import 'package:skyscape/services/database.dart';
import 'package:skyscape/services/auth.dart';

//import 'package:skyscape/screens/home.dart';
class AddFavouriteLocation extends StatefulWidget {
  const AddFavouriteLocation({Key? key}) : super(key: key);

  @override
  _AddFavouriteLocationState createState() => _AddFavouriteLocationState();
}

class _AddFavouriteLocationState extends State<AddFavouriteLocation> {
  List<String> locationOptions = ['Admiralty', 'Bishan', 'Toa Payoh', 'Woodlands'];
  List<String> selectedLocations = [];

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Favourite Locations'),
      ),
      body: ListView.builder(
        itemCount: locationOptions.length,
        itemBuilder: (context, index) {
          final location = locationOptions[index];
          return CheckboxListTile(
            title: Text(location),
            value: selectedLocations.contains(location),
            onChanged: (value) {
              setState(() {
                if (value != null && value) {
                  selectedLocations.add(location);
                } else {
                  selectedLocations.remove(location);
                }
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveFavouriteLocations,
        child: const Icon(Icons.save),
      ),
    );
  }

  Future<void> _saveFavouriteLocations() async {
    await DatabaseService(uid: _auth.currentUser!.uid).saveFavouritedLocations(selectedLocations);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );
  }
}