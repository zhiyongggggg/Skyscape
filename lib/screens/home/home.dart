import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
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
  List<String> favouritedLocationNames = [
    'Admiralty',
    'Ang Mo Kio',
    'Pasir Ris',
    'Yew Tee'
  ]; // default names

  int currentIndex = 0;
  DateTime _selectedDate = DateTime.now();

  bool isLoading = false; // Flag for loading state

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
        PSIRating,
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

      // ======================== PSI ======================== CHANGE
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
      sunsetQuality = PSIQuality + humidityQuality + PSIQuality;
      allValues[location].add(sunsetQuality.toStringAsFixed(2));
    }

    setState(() {
      isLoading = false; // Set loading state to false after fetching data
    });
  }

  String _getCurrentDateInSingapore() {
    DateTime now = DateTime.now().toUtc(); // Getting current time in UTC
    DateTime singaporeTime = now.add(const Duration(
        hours: 8)); // Adding 8 hours to convert to Singapore time
    String formattedDate =
        '${singaporeTime.year}-${_formatDateComponent(singaporeTime.month)}-${_formatDateComponent(singaporeTime.day)}';
    return formattedDate;
  }

  String _formatDateComponent(int component) {
    return component < 10 ? '0$component' : '$component';
  }

  @override
  void initState() {
    super.initState();
    _getFavouritedLocations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getFavouritedLocations();
  }

  Future<void> _getFavouritedLocations() async {
    List<String> locations = await DatabaseService(uid: _auth.currentUser!.uid)
        .getFavouritedLocations();
    setState(() {
      favouritedLocationNames = locations;
    });
    String currentDate =
        _getCurrentDateInSingapore(); // TODO: Date change according to calendar
    getData(currentDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skyscape'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange[200]!, // Lighter shade of orange at the top
              Colors.orange[300]!, // Medium shade of orange in the middle
              Colors.orange[400]!, // Darker shade of orange at the bottom
            ],
          ),
        ),
        child: Column(
          children: [
            // Single row calendar
            TableCalendar(
              calendarFormat: CalendarFormat.week,
              focusedDay: _selectedDate,
              firstDay: DateTime.now().subtract(Duration(days: 365)),
              lastDay: DateTime.now().add(Duration(days: 7)), // Max 7 days ahead
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
              ),
              selectedDayPredicate: (DateTime date) {
                return isSameDay(date, _selectedDate); // Highlight selected date
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay; // Highlight selected date
                  String selectedDateString = DateFormat('yyyy-MM-dd').format(selectedDay);
                  getData(selectedDateString); // Fetch data for selected date
                });
              },
            ),

            // Existing content
            Expanded(
              child: isLoading ? _buildLoadingWidget() : _buildLocationWidgets(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to view details page
                  },
                  child: Text('viewDetails'),
                ),
              ),
            ),
          ],
        ),
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

  // Function to build loading widget
  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(), // Display loading indicator
    );
  }

  // Function to build location widgets after data fetch
  Widget _buildLocationWidgets() {
    return ListView(
      children: [
        for (int i = 0; i < favouritedLocationNames.length; i++)
          Column(
            children: [
              // Thin white line between locations
              Divider(color: Colors.white),
              _buildLocationWidget(favouritedLocationNames[i]),
            ],
          ),
      ],
    );
  }

  // Function to build individual location widget
  Widget _buildLocationWidget(String location) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${allValues[location]?[5]}%',
                  style: TextStyle(
                    fontSize: 38, // Adjust the font size as needed
                    fontWeight: FontWeight.bold, // Adjust the font weight as needed
                    color: Colors.white,
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Icon(Icons.sunny), // Sunset icon
          ),
        ],
      ),
    );
  }
}
