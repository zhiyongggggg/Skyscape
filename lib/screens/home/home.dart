import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, double?> locationValues = {};
  List<String> favouritedLocationNames = ['Nanyang Avenue', 'Clementi Road', 'Kim Chuan Road']; // Names for the favourited locations
  int currentIndex = 0;

  void getData(List<String> favouritedLocationNames) async {
    String url = 'https://api.data.gov.sg/v1/environment/air-temperature';

    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> stations = data['metadata']['stations'];
      Map<String, Map<String, dynamic>> filteredStations = {};

      // Build filteredStations map
      for (var station in stations) {
        if (favouritedLocationNames.contains(station['name'])) {
          filteredStations[station['name']] = station;
        }
      }

      // Clear previous values
      locationValues.clear();

      List<dynamic> items = data['items'];
      for (var item in items) {
        List<dynamic> readings = item['readings'];
        for (var reading in readings) {
          String stationName = filteredStations.keys.firstWhere((key) => filteredStations[key]!['id'] == reading['station_id'], orElse: () => '');
          double value = (reading['value'] as num).toDouble();
          if (stationName.isNotEmpty) {
            locationValues[stationName] = value;
          }
        }
      }
      setState(() {});
    } else {
      print('Failed to fetch data: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    getData(favouritedLocationNames);
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () async {
              print("logout button is pressed");
              // Add your logout functionality here
            },
          )
        ],
      ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var location in favouritedLocationNames)
            if (locationValues.containsKey(location))
              Container(
                margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 191, 191, 22),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text('$location : ${locationValues[location]}'),
              ),
        ],
      ),
    ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
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
}