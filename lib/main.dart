import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graid',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
      home: const MyHomePage(title: 'Graid Anasayfa'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  int _pageIndex = 0;
  bool isRealData = false;
  bool? serverStatus;
  bool loading = true;
  Map<String, String>? sensorData;
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
      lowerBound: 0.5,
      upperBound: 1.0,
    )..repeat(reverse: true);
    fetchSensorData();
  }

  Future<void> fetchSensorData() async {
    try {
      final response = await http
          .get(Uri.parse('http://your-esp-endpoint/sensor'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        setState(() {
          sensorData = Map<String, String>.from(json.decode(response.body));
          isRealData = true;
        });
        sendDataToServer();
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        sensorData = {
          'soilMoisture': '35%',
          'humidity': '41%',
          'temperature': '22°C',
          'ec': '1.2 mS/cm',
          'ph': '6.8',
          'nitrogen': '20 mg/kg',
          'phosphorous': '15 mg/kg',
          'potassium': '25 mg/kg',
        };
        isRealData = false;
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> sendDataToServer() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/myapp/start'),
      );
      if (response.statusCode == 200) {
        setState(() {
          serverStatus = true;
        });
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        serverStatus = false;
      });
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body:
          <Widget>[
            // Home page (Sensor page)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  AnimatedOpacity(
                    opacity: _blinkController.value,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isRealData ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        isRealData
                            ? "ESP'den Gerçek Veri Geldi!"
                            : "ESP'den Veri Gelmedi",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedOpacity(
                    opacity: _blinkController.value,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: serverStatus == true ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        serverStatus == true
                            ? "Sunucuya İstek Gönderildi!"
                            : "Sunucuya İstek Gönderilemedi!",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child:
                        loading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                              itemCount: sensorData?.keys.length ?? 0,
                              itemBuilder: (context, index) {
                                String key = sensorData!.keys.elementAt(index);
                                return Card(
                                  child: ListTile(
                                    title: Text(
                                      key,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(sensorData![key]!),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),

            // Settings page
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[const Text('Settings Page')],
              ),
            ),

            // Profile page
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[const Text('Profile Page')],
              ),
            ),
          ][_pageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _pageIndex = index;
          });
        },
        selectedIndex: _pageIndex,
        indicatorColor: Colors.deepPurple,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: "Anasayfa",
            selectedIcon: Icon(Icons.home, color: Colors.white),
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: "Ayarlar",
            selectedIcon: Icon(Icons.settings, color: Colors.white),
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: "Profil",
            selectedIcon: Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
