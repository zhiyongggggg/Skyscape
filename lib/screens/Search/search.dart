import 'package:flutter/material.dart';
import 'package:skyscape/screens/home/home.dart';
import 'package:skyscape/services/database.dart';
import 'package:skyscape/services/auth.dart';
import 'package:skyscape/screens/home/dictionaries.dart';

class AddFavouriteLocation extends StatefulWidget {
  const AddFavouriteLocation({Key? key}) : super(key: key);

  @override
  _AddFavouriteLocationState createState() => _AddFavouriteLocationState();
}

class _AddFavouriteLocationState extends State<AddFavouriteLocation> {
  List<String> locationOptions = locationToCoordinatesMapping.keys.toList();
  List<String> selectedLocations = [];
  String searchQuery = '';

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    List<String> filteredLocations = locationOptions
        .where((location) =>
            location.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
        appBar: AppBar(
        title: Text('Search for estates'),
        backgroundColor: Colors.amber[400],
         
        elevation: 0.0,
      ),

      body: Container(
         decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange[300]!, Colors.orange[200]!],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search for an estate...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredLocations.length,
                  itemBuilder: (context, index) {
                    final location = filteredLocations[index];
                    return ListTile(
                      title: Text(location),
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          _saveFavouriteLocation(location);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    
          
    );
  }

  Future<void> _saveFavouriteLocation(String location) async {
    List<String> savedLocations = await DatabaseService(uid: _auth.currentUser!.uid).getFavouritedLocations();
    if (savedLocations.contains(location)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$location is already saved'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      await DatabaseService(uid: _auth.currentUser!.uid).saveFavouritedLocation(location);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$location added to favourites'),
          duration: Duration(seconds: 1),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
    
  } 
}