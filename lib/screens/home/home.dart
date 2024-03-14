import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, dynamic?> allValues = {};
  Map<String, dynamic?> psiValues = {};
  Map<String, Map<String, dynamic>> filteredStations = {};
  List<String> favouritedLocationNames = ['Admiralty', 'Ang Mo Kio', 'Pasir Ris', 'Yew Tee']; // Names for the favourited locations
  Map<String, dynamic> locationToRegionMapping = {'Admiralty': [1.436984, 103.786406], 'Aljunied': [1.316474, 103.882762], 'Ang Mo Kio': [1.370025, 103.849588], 'Bakau': [1.38804, 103.905412], 'Bangkit': [1.380281, 103.772576], 'Bartley': [1.342923, 103.87966], 'Bayfront': [1.281371, 103.858998], 'Beauty World': [1.341607, 103.775682], 'Bedok': [1.324043, 103.930205], 'Bedok North': [1.335268, 103.918054], 'Bedok Reservoir': [1.336595, 103.93307], 'Bencoolen': [1.298477, 103.849984], 'Bendemeer': [1.313674, 103.863098], 'Bishan': [1.35092, 103.848206], 'Boon Keng': [1.320091, 103.861655], 'Boon Lay': [1.33862, 103.705817], 'Botanic Gardens': [1.322387, 103.814905], 'Braddell': [1.34055, 103.847098], 'Bras Basah': [1.296978, 103.850715], 'Buangkok': [1.382991, 103.893347], 'Bugis': [1.300747, 103.855873], 'Bukit Batok': [1.349069, 103.749596], 'Bukit Gombak': [1.359043, 103.751863], 'Bukit Panjang': [1.37834, 103.762452], 'Buona Vista': [1.307337, 103.790046], 'Caldecott': [1.337649, 103.839627], 'Cashew': [1.369997, 103.764569], 'Changi Airport': [1.357622, 103.988487], 'Cheng Lim': [1.396332, 103.89379], 'Chinatown': [1.284566, 103.843626], 'Chinese Garden': [1.342436, 103.732582], 'Choa Chu Kang': [1.385417, 103.744316], 'City Hall': [1.293119, 103.852089], 'Clarke Quay': [1.288949, 103.847521], 'Clementi': [1.314925, 103.765341], 'Commonwealth': [1.302439, 103.798326], 'Compassvale': [1.394615, 103.900443], 'Coral Edge': [1.39392, 103.912633], 'Cove': [1.399534, 103.905792], 'Dakota': [1.308474, 103.888825], 'Damai': [1.405293, 103.908606], 'Dhoby Ghaut': [1.299169, 103.845799], 'Dover': [1.311414, 103.778596], 'Downtown': [1.27949, 103.852802], 'Esplanade': [1.293995, 103.855396], 'Eunos': [1.319809, 103.902888], 'Expo': [1.334479, 103.961459], 'Fajar': [1.384502, 103.770862], 'Farmway': [1.397178, 103.889168], 'Farrer Park': [1.312679, 103.854872], 'Farrer Road': [1.317606, 103.807711], 'Fernvale': [1.392033, 103.876256], 'Fort Canning': [1.291631, 103.844621], 'Geylang Bahru': [1.321479, 103.871457], 'Gul Circle': [1.319809, 103.66083], 'HarbourFront': [1.265453, 103.820514], 'Haw Par Villa': [1.283149, 103.781991], 'Hillview': [1.363185, 103.767371], 'Holland Village': [1.311189, 103.796119], 'Hougang': [1.371406, 103.892533], 'Jalan Besar': [1.305551, 103.855443], 'Jelapang': [1.386703, 103.764547], 'Joo Koon': [1.327826, 103.678318], 'Jurong East': [1.333207, 103.742308], 'Kadaloor': [1.399633, 103.916536], 'Kaki Bukit': [1.335076, 103.909057], 'Kallang': [1.311532, 103.871372], 'Kangkar': [1.383957, 103.90216], 'Keat Hong': [1.378604, 103.749058], 'Kembangan': [1.320998, 103.913433], 'Kent Ridge': [1.293629, 103.784441], 'Khatib': [1.417423, 103.832995], 'King Albert Park': [1.335721, 103.783203], 'Kovan': [1.360207, 103.885163], 'Kranji': [1.425302, 103.762049], 'Kupang': [1.398271, 103.881283], 'Labrador Park': [1.27218, 103.802557], 'Lakeside': [1.344264, 103.720797], 'Lavender': [1.307577, 103.863155], 'Layar': [1.392141, 103.880022], 'Little India': [1.306691, 103.849396], 'Lorong Chuan': [1.35153, 103.864957], 'MacPherson': [1.326769, 103.889901], 'Marina Bay': [1.276481, 103.854598], 'Marina South Pier': [1.271422, 103.863581], 'Marsiling': [1.432579, 103.77415], 'Marymount': [1.349089, 103.839116], 'Mattar': [1.326878, 103.883304], 'Meridian': [1.397002, 103.908884], 'Mountbatten': [1.306106, 103.883175], 'Newton': [1.31383, 103.838021], 'Nibong': [1.411865, 103.900321], 'Nicoll Highway': [1.300292, 103.863449], 'Novena': [1.320089, 103.843405], 'Oasis': [1.402304, 103.912736], 'Orchard': [1.304041, 103.831792], 'Outram Park': [1.280319, 103.839459], 'Pasir Panjang': [1.276111, 103.791893], 'Pasir Ris': [1.373234, 103.949343], 'Paya Lebar': [1.318214, 103.893133], 'Pending': [1.376223, 103.771277], 'Petir': [1.377828, 103.76655], 'Phoenix': [1.378798, 103.758021], 'Pioneer': [1.337645, 103.69742], 'Potong Pasir': [1.331316, 103.868779], 'Promenade': [1.294063, 103.860156], 'Punggol': [1.405191, 103.902367], 'Punggol Point': [1.416932, 103.90668], 'Queenstown': [1.294867, 103.805902], 'Raffles Place': [1.284001, 103.85155], 'Ranggung': [1.384116, 103.897386], 'Redhill': [1.289674, 103.816787], 'Renjong': [1.386827, 103.890541], 'Riviera': [1.39454, 103.916056], 'Rochor': [1.303601, 103.852581], 'Rumbia': [1.391553, 103.905947], 'Sam Kee': [1.409808, 103.90492], 'Samudera': [1.415955, 103.902185], 'Segar': [1.387713, 103.769599], 'Sembawang': [1.449133, 103.82006], 'Sengkang': [1.391682, 103.895475], 'Senja': [1.382852, 103.762312], 'Serangoon': [1.349862, 103.873635], 'Simei': [1.343237, 103.953343], 'Sixth Avenue': [1.331221, 103.79718], 'Somerset': [1.300508, 103.838428], 'Soo Teck': [1.405436, 103.897287], 'South View': [1.380299, 103.745286], 'Stadium': [1.302847, 103.875417], 'Stevens': [1.320012, 103.825964], 'Sumang': [1.408501, 103.898605], 'Tai Seng': [1.33594, 103.887706], 'Tampines': [1.354467, 103.943325], 'Tampines East': [1.35631, 103.955471], 'Tampines West': [1.345583, 103.938244], 'Tan Kah Kee': [1.325826, 103.807959], 'Tanah Merah': [1.327309, 103.946479], 'Tanjong Pagar': [1.276385, 103.846771], 'Teck Lee': [1.412783, 103.906565], 'Teck Whye': [1.376738, 103.753665], 'Telok Ayer': [1.282285, 103.848584], 'Telok Blangah': [1.270769, 103.809878], 'Thanggam': [1.397378, 103.87561], 'Tiong Bahru': [1.286555, 103.826956], 'Toa Payoh': [1.332405, 103.847436], 'Tongkang': [1.389519, 103.885829], 'Tuas Crescent': [1.321091, 103.649075], 'Tuas Link': [1.340371, 103.636866], 'Tuas West Road': [1.330075, 103.639636], 'Ubi': [1.330008, 103.898911], 'Upper Changi': [1.342218, 103.961505], 'Woodlands': [1.436984, 103.786406], 'Woodleigh': [1.339202, 103.870727], 'Yew Tee': [1.397383, 103.747523], 'Yio Chu Kang': [1.381765, 103.844923], 'Yishun': [1.429666, 103.835044], 'one-north': [1.299854, 103.787584]};
  int currentIndex = 0;

  void getData(List<String> favouritedLocationNames) async {
    String url, longitude, latitude;

    for (var location in favouritedLocationNames) {
      latitude = locationToRegionMapping[location][0].toString();
      longitude = locationToRegionMapping[location][1].toString();
      print(latitude);
      print(longitude);
      url = 'https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current=temperature_2m,relative_humidity_2m,cloud_cover&daily=sunrise,sunset&timezone=Asia%2FSingapore&forecast_days=1';
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        Map<String, dynamic> currentConditions = data["current"];
        String sunSet = data["daily"]["sunset"][0].substring(11);
        allValues[location] = [currentConditions["temperature_2m"], currentConditions["relative_humidity_2m"], currentConditions["cloud_cover"], sunSet];
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }

      // ======================== PSI ======================== 
      url = 'https://api.data.gov.sg/v1/environment/psi';
      response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        Map<String, dynamic> readings = data['items'][0]['readings']; 
        psiValues[location] = readings['psi_twenty_four_hourly']["west"]; // WORK HERE REQUIRED!!! need to map location to their respective regions
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
      body: Column(
        // Removed Center widget
        mainAxisAlignment: MainAxisAlignment.start, // Align to top

        children: [
          for (var location in favouritedLocationNames)
            Row(  // Wrap each container in a Row
              mainAxisAlignment: MainAxisAlignment.center, // Center horizontally
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8, // Set width to 80%
                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 191, 191, 22),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text('$location : Temp-${allValues[location]?[0]}, Humidity-${allValues[location]?[1]}%, CC-${allValues[location]?[2]}%, PSI-${psiValues[location]}%, Sunset: ${allValues[location]?[3]}'),
                ),
              ],
            ),
        ],
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