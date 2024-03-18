import 'package:flutter/material.dart';
import 'dart:convert';
import 'dictionaries.dart';
import 'package:http/http.dart' as http;
import 'package:skyscape/services/auth.dart';

class ViewDetails extends StatefulWidget {
  final String location;

  State<ViewDetails> createState() => _ViewDetailsState();

  ViewDetails({required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details for $location'),
      ),
    );
  }
}

class _ViewDetailsState extends State<ViewDetails> {
  final AuthService _auth = AuthService();
  
  int currentIndex = 0;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skyscape'),
        backgroundColor: currentIndex == 3
            ? Color.fromARGB(255, 241, 255, 114)
            : Colors.amber[400],
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange[200]!, Colors.orange[300]!],
          ),
        ),
        child: IndexedStack(
          index: currentIndex,
          children: [
          buildlocation(),
          ],
        ),
        //   index: currentIndex,
        //   children: [
        //     buildHomeScreen()],
        // ),
      )
    );
  }

  Map<String, dynamic?> allValues = {};
  List<String> favouritedLocationNames = []; // default names
  bool isLoading = false;
  
  void getData(String date) async {
    setState(() {
      allValues.clear(); // Clear previous data
      isLoading = true; // Set loading state to true before fetching data
    });

    String url, longitude, latitude, sunSet;
    double sunsetQuality,
        humidityQuality,
        cloudCoverQuality,
        PSI,
        PSIQuality;

    for (var location in favouritedLocationNames) {
      latitude = locationToCoordinatesMapping[location][0].toString();
      longitude = locationToCoordinatesMapping[location][1].toString();

      // Get sunset timing first, the weather conditions will be forecasted based on this timing later on.
      url =
          'https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&daily=sunrise,sunset&timezone=Asia%2FSingapore&start_date=${date}&end_date=${date}';
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        sunSet = data["daily"]["sunset"][0].substring(
            11); // Use substring() to exclude the date from the string, only leaving with time

        // Now using the sunset timing, we find the weather conditions
        url =
            'https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&hourly=temperature_2m,relative_humidity_2m,cloud_cover&timezone=Asia%2FSingapore&start_hour=${date}T${sunSet}&end_hour=${date}T${sunSet}';
        response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          Map data = jsonDecode(response.body);
          Map<String, dynamic> currentConditions = data["hourly"];
          allValues[location] = [
            currentConditions["temperature_2m"][0],
            currentConditions["relative_humidity_2m"][0],
            currentConditions["cloud_cover"][0],
            sunSet
          ];
        } else {
          print('Failed to fetch data: ${response.statusCode}');
        }
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }

      // ======================== PSI ======================== 
      url = 'https://api.data.gov.sg/v1/environment/psi';
      response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        Map<String, dynamic> readings = data['items'][0]['readings'];
        String? region = locationToRegionMapping[location];
        allValues[location].add(readings['psi_twenty_four_hourly'][region]);
        // print(psiValues); ---> {west: 49, east: 61, central: 54, south: 51, north: 38}
        setState(() {});
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
      cloudCoverQuality = allValues[location][2] * 0.4;
      humidityQuality = allValues[location][1] * 0.3;
      PSI = allValues[location][4].toDouble();
      if (PSI <= 55) {
        PSIQuality = 80 + ((55 - PSI) / 55 * 20);
      } else {
        PSIQuality = 20 + ((250 - PSI) / 250 * 80);
      }
      PSIQuality = PSIQuality * 0.3;
      sunsetQuality = cloudCoverQuality + humidityQuality + PSIQuality;
      allValues[location].add(sunsetQuality.toStringAsFixed(2));
    }
}

  @override
  Widget buildlocation() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Testing to see if this works, if you see it, then it works'),
      ),
    );
  }
}
