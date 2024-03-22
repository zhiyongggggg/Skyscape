import 'package:flutter/material.dart';
import 'dart:convert';
import 'dictionaries.dart';
import 'package:http/http.dart' as http;
import 'package:skyscape/services/auth.dart';

class ViewDetails extends StatefulWidget {
  final String location;

  ViewDetails({required this.location});

  @override
  State<ViewDetails> createState() => _ViewDetailsState();
}

class _ViewDetailsState extends State<ViewDetails> {
  final AuthService _auth = AuthService();

  int currentIndex = 0;

  Map<String, dynamic?> allValues = {};
  List<String> favouritedLocationNames = []; // default names
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData(DateTime.now().toString().substring(0, 10));
  }

  void getData(String date) async {
    setState(() {
      allValues.clear(); // Clear previous data
      isLoading = true; // Set loading state to true before fetching data
    });

    String url, longitude, latitude, sunSet;
    double sunsetQuality, humidityQuality, cloudCoverQuality, PSI, PSIQuality;

    latitude = locationToCoordinatesMapping[widget.location][0].toString();
    longitude = locationToCoordinatesMapping[widget.location][1].toString();

    // Get sunset timing first, the weather conditions will be forecasted based on this timing later on.
    url =
        'https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&daily=sunrise,sunset&timezone=Asia%2FSingapore&start_date=${date}&end_date=${date}';
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);
      sunSet = data["daily"]["sunset"][0].substring(11);

      // Now using the sunset timing, we find the weather conditions
      url =
          'https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&hourly=temperature_2m,relative_humidity_2m,cloud_cover&timezone=Asia%2FSingapore&start_hour=${date}T${sunSet}&end_hour=${date}T${sunSet}';
      response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        Map<String, dynamic> currentConditions = data["hourly"];
        allValues[widget.location] = [
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
      String? region = locationToRegionMapping[widget.location];
      allValues[widget.location].add(readings['psi_twenty_four_hourly'][region]);
      setState(() {});
    } else {
      print('Failed to fetch data: ${response.statusCode}');
    }
    cloudCoverQuality = allValues[widget.location][2] * 0.4;
    humidityQuality = allValues[widget.location][1] * 0.3;
    PSI = allValues[widget.location][4].toDouble();
    if (PSI <= 55) {
      PSIQuality = 80 + ((55 - PSI) / 55 * 20);
    } else {
      PSIQuality = 20 + ((250 - PSI) / 250 * 80);
    }
    PSIQuality = PSIQuality * 0.3;
    sunsetQuality = cloudCoverQuality + humidityQuality + PSIQuality;
    allValues[widget.location].add(sunsetQuality.toStringAsFixed(2));

    setState(() {
      isLoading = false; // Set loading state to false after fetching data
    });
  }
  String _calculateTimeDifference(String sunsetTime) {
    if (sunsetTime == "N/A") return "N/A";

    DateTime now = DateTime.now();
    DateTime sunset = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(sunsetTime.split(':')[0]),
      int.parse(sunsetTime.split(':')[1]),
    );

    Duration difference = sunset.difference(now);

    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);

    return '${hours}hr ${minutes}min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Details for ${widget.location}'),
        backgroundColor: currentIndex == 3
            ? Color.fromARGB(255, 241, 255, 114)
            : Colors.amber[400],
        elevation: 0.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange[200]!, Colors.orange[300]!],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 30),
            Text(
              widget.location,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Golden Hour Quality',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrangeAccent,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '${allValues[widget.location]?[5] ?? "N/A"}%',
              style: TextStyle(
                fontSize: 85,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            SizedBox(height:5),
            Text(
              'Sun sets in',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              ),
            SizedBox(height: 5),
            Text(
              _calculateTimeDifference(allValues[widget.location]?[3] ?? "N/A"),
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Align(
                  alignment: AlignmentDirectional(1.0, -1.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Opacity(
                            opacity: 0.5,
                            child: Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Container(
                                width: 352.0,
                                height: 283.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(30.0),
                                    bottomRight: Radius.circular(30.0),
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0),
                                  ),
                                  shape: BoxShape.rectangle,
                                ),
                                child: Container(
                                  width: 0.0,
                                  height: 0.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(30.0),
                                      bottomRight: Radius.circular(30.0),
                                      topLeft: Radius.circular(30.0),
                                      topRight: Radius.circular(30.0),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Align(
                                        alignment: AlignmentDirectional(0.0, 0.0),
                                        child: Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(
                                              0.0, 10.0, 0.0, 0.0),
                                          child: Container(
                                            width: 302.0,
                                            height: 129.0,
                                            decoration: BoxDecoration(
                                              color: Colors.deepOrange,
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(30.0),
                                                bottomRight: Radius.circular(30.0),
                                                topLeft: Radius.circular(30.0),
                                                topRight: Radius.circular(30.0),
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Align(
                                                  alignment: AlignmentDirectional(
                                                      0.0, -1.0),
                                                  child: Padding(
                                                    padding: EdgeInsetsDirectional
                                                        .fromSTEB(
                                                            0.0, 20.0, 0.0, 0.0),
                                                    child: Text(
                                                      'Prime Time',
                                                      style: TextStyle(
                                                        fontSize: 30,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: AlignmentDirectional(
                                                      0.0, 0.4),
                                                  child: Container(
                                                    width: 304.0,
                                                    height: 50.0,
                                                    decoration: BoxDecoration(
                                                      color: Colors.deepOrange,
                                                    ),
                                                    child: Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              0.0, -0.17),
                                                      child: Text(
                                                        '${allValues[widget.location]?[3] ?? "N/A"}',
                                                        style: TextStyle(
                                                          fontSize: 45,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 20.0, 0.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Container(
                                              width: 100.0,
                                              height: 100.0,
                                              decoration: BoxDecoration(
                                                color: Colors.orange,
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(30.0),
                                                  bottomRight: Radius.circular(30.0),
                                                  topLeft: Radius.circular(30.0),
                                                  topRight: Radius.circular(30.0),
                                                ),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, -1.0),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(0.0, 10.0,
                                                                  0.0, 0.0),
                                                      child: Text(
                                                        'Cloud Cover',
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.05, 0.35),
                                                    child: Container(
                                                      width: 80.0,
                                                      height: 48.0,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          '${allValues[widget.location]?[2] ?? "N/A"}%',
                                                          style: TextStyle(
                                                            fontSize: 25,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 100.0,
                                              height: 100.0,
                                              decoration: BoxDecoration(
                                                color: Colors.orange,
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(30.0),
                                                  bottomRight: Radius.circular(30.0),
                                                  topLeft: Radius.circular(30.0),
                                                  topRight: Radius.circular(30.0),
                                                ),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, -1.0),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(0.0, 10.0,
                                                                  0.0, 0.0),
                                                      child: Text(
                                                        'Air Quality',
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.05, 0.35),
                                                    child: Container(
                                                      width: 80.0,
                                                      height: 48.0,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          '${allValues[widget.location]?[4] ?? "N/A"}',
                                                          style: TextStyle(
                                                            fontSize: 25,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 100.0,
                                              height: 100.0,
                                              decoration: BoxDecoration(
                                                color: Colors.orange,
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(30.0),
                                                  bottomRight: Radius.circular(30.0),
                                                  topLeft: Radius.circular(30.0),
                                                  topRight: Radius.circular(30.0),
                                                ),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, -1.0),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(0.0, 10.0,
                                                                0.0, 0.0),
                                                    child: Text(
                                                      'Humidity',
                                                      style:
                                                          TextStyle(
                          fontSize: 17, // Adjust the font size as needed
                          fontWeight: FontWeight.normal, // Adjust the font weight as needed
                          color: Colors.white,
                                                              ),
                                                    ),
                                                    
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.05, 0.35),
                                                  child: Container(
                                                    width: 80.0,
                                                    height: 48.0,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                    ),
                                                        child: Center(
                                                          child: Text(
                                                            '${allValues[widget.location]?[1] ?? "N/A"}%',
                                                            style: TextStyle(
                                                              fontSize: 25,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          ]
        ),
    //     ),
    // ),
      )
    );
  }
}


