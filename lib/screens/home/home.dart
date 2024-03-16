import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:skyscape/screens/Search/search.dart';
import 'package:skyscape/screens/home/viewdetails.dart';
import 'package:skyscape/screens/settings/profile.dart';
import 'dart:convert';
import 'package:skyscape/services/auth.dart';
import 'package:skyscape/services/database.dart';
import 'dictionaries.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  Map<String, dynamic?> allValues = {};
  Map<String, dynamic?> psiValues = {};
  Map<String, Map<String, dynamic>> filteredStations = {};
  List<String> favouritedLocationNames = ['Admiralty', 'Ang Mo Kio', 'Pasir Ris', 'Yew Tee']; // default names
  
  int currentIndex = 0;

  void getData(List<String> favouritedLocationNames) async {
    String url, longitude, latitude;

    for (var location in favouritedLocationNames) {
      latitude = locationToCoordinatesMapping[location][0].toString();
      longitude = locationToCoordinatesMapping[location][1].toString();

      url = 'https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current=temperature_2m,relative_humidity_2m,cloud_cover&daily=sunrise,sunset&timezone=Asia%2FSingapore&forecast_days=1';
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        Map<String, dynamic> currentConditions = data["current"];
        String sunSet = data["daily"]["sunset"][0].substring(11); // Use substring() to exclude the date from the string, only leaving with time
        allValues[location] = [currentConditions["temperature_2m"], currentConditions["relative_humidity_2m"], currentConditions["cloud_cover"], sunSet];
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }

      // ======================== PSI ======================== CHANGE
      url = 'https://api.data.gov.sg/v1/environment/psi';
      response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        Map<String, dynamic> readings = data['items'][0]['readings']; 
        String? region = locationToRegionMapping[location];
        print(region);
        psiValues[location] = readings['psi_twenty_four_hourly'][region]; // WORK HERE REQUIRED!!! need to map location to their respective regions
        // print(psiValues); ---> {west: 49, east: 61, central: 54, south: 51, north: 38}
        setState(() {});
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getData(favouritedLocationNames);
    _getFavouritedLocations();
    
  }
  Future<void> _getFavouritedLocations() async {
  List<String> locations = await DatabaseService(uid: _auth.currentUser!.uid).getFavouritedLocations();
  setState(() {
    favouritedLocationNames = locations;
  });
  getData(favouritedLocationNames);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      appBar: AppBar(
        title: const Text('Skyscape'),
        backgroundColor: currentIndex == 3 ? Color.fromARGB(255, 189, 235, 191) : Colors.amber[400],
        elevation: 0.0,
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.person),
            label: const Text('logout'),
            onPressed: () async {
              print("logout button is pressed");
              await _auth.signOut();
            },
          )
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          buildHomeScreen(),
          AddFavouriteLocation(),
          //Center(child: Text('Search', style: TextStyle(fontSize: 20))),
          Center(child: Text('Calendar', style: TextStyle(fontSize: 60))),
          ProfileMainWidget(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget buildHomeScreen() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              for (var location in favouritedLocationNames)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 191, 191, 22),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text('$location : Temp-${allValues[location]?[0]}, Humidity-${allValues[location]?[1]}%, CC-${allValues[location]?[2]}%, PSI-${psiValues[location]}%, Sunset: ${allValues[location]?[3]}'),                  ),
                  ],
                ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewDetailsPage()),
                );
              },
              child: Text('viewDetails'),
            ),
          ),
        ),
      ],
    );
  }
}