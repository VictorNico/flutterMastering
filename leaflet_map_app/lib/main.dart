import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class TranslationService {
  Map<String, dynamic>? _translations;
  String _currentLanguage = 'en'; // Langue par défaut

  Future<void> loadTranslations() async {
    String jsonString = await rootBundle.loadString('assets/i18n.json');
    _translations = json.decode(jsonString);
  }

  void setLanguage(String language) {
    _currentLanguage = language;
  }

  String translate(String key, Map<String, String> params) {
    if (_translations == null) return key;

    String translated = _translations?[_currentLanguage]?[key] ?? key;
    // print(translated);
    params.forEach((key, value) {
      translated = translated.replaceAll('{$key}', value);
    });

    return translated;
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _locationMessage = "";
  bool? _serviceEnabled;
  LocationPermission? _permission;
  LatLng _location = const LatLng(3.86467, 11.49699);
  List<Marker> _markers = [];
  List<LatLng> _routePoints = [];
  FlutterTts flutterTts = FlutterTts();
  List<dynamic> steps = [];
  StreamSubscription<Position>? positionStream;
  MapController _mapController = MapController();
  final TranslationService _translationService = TranslationService();
  double _lastHeading = 0.0; // Dernier angle appliqué à la carte
  final double _headingThreshold = 5.0; // Seuil de tolérance en degrés

  Future<List<LatLng>> fetchRoute(LatLng start, LatLng end) async {
    final response = await http.get(Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&steps=true&alternatives=true'));
    // print(
    //     'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&steps=true&alternatives=true');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<LatLng> allPoints = [];

      // Parcourir toutes les étapes du trajet
      setState(() {
        steps = data['routes'][0]['legs'][0]['steps'];
      });
      for (var step in steps) {
        List<dynamic> stepCoordinates = step['geometry']['coordinates'];

        // Convertir les coordonnées de l'étape en LatLng
        List<LatLng> stepPoints = stepCoordinates
            .map((coord) =>
                LatLng(coord[1], coord[0])) // OSRM retourne [lng, lat]
            .toList();

        // Ajouter les points de l'étape à la liste globale
        allPoints.addAll(stepPoints);
      }
      return allPoints; // Liste complète de points
    } else {
      throw Exception('Failed to load route');
    }
  }

  void _checkProximityToSteps(
      Position currentPosition, List<dynamic> steps) async {
    for (var step in steps) {
      List<dynamic> stepLocation = step['maneuver']['location'];
      double stepLatitude = stepLocation[1];
      double stepLongitude = stepLocation[0];

      // Calculer la distance entre la position actuelle et l'étape
      double distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        stepLatitude,
        stepLongitude,
      );

      // Si la distance est inférieure à 50 mètres, lire l'instruction
      if (distance < 50) {
        // String instruction =
        //     "In ${step['distance'].toStringAsFixed(0)} meters, ";
        // instruction += "turn ${step['maneuver']['modifier'] ?? 'straight'} ";
        //
        // if (step['name'] != null && step['name'].isNotEmpty) {
        //   instruction += "onto ${step['name']}.";
        // } else {
        //   instruction += ".";
        // }
        //
        // // Lire l'instruction via la méthode _speak
        // await _speak(instruction);

        String modifier = step['maneuver']['modifier'] ?? 'straight';
        String key = (modifier == 'left')
            ? 'turn_left'
            : (modifier == 'right')
                ? 'turn_right'
                : 'go_straight';

        String street = step['name'] ?? '';
        String distanceText = step['distance'].toStringAsFixed(0);

        await _speakInstruction(key, {
          'street': street,
          'distance': distanceText,
        });

        // Sortir de la boucle pour éviter des déclenchements multiples
        break;
      }
    }
  }

  void _startListeningToPositionChanges() {
    positionStream = Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _location = LatLng(position.latitude, position.longitude);
        _mapController.move(_location,
            16.2); // Recentrer la carte// Ici, vous devez récupérer l'angle d'orientation de l'utilisateur
        // Récupérer l'angle d'orientation de l'utilisateur
        double heading = position.heading; // en degrés

        // Calculer la différence d'angle
        double angleDifference = (heading - _lastHeading).abs();

        // Vérifier si la différence d'angle est supérieure au seuil
        if (angleDifference > _headingThreshold) {
          _mapController.rotate(heading); // Appliquer la rotation
          _lastHeading = heading; // Mettre à jour l'angle appliqué
        }
      });
      // Appeler la fonction pour vérifier la proximité des étapes
      _checkProximityToSteps(position, steps);
    });
  }

  Future<void> _speak(String text) async {
    String currentLang = _translationService._currentLanguage;

    // print('$currentLang $text');
    // Configurer la langue du TTS
    if (currentLang == 'en') {
      await flutterTts.setLanguage('en-US');
    } else if (currentLang == 'fr') {
      await flutterTts.setLanguage('fr-FR');
    } else {
      await flutterTts.setLanguage('en-US'); // Langue par défaut
    }
    await flutterTts.speak(text);
  }

  // Avant de lire un texte, traduisez-le
  Future<void> _speakInstruction(String key, Map<String, String> params) async {
    await _translationService.loadTranslations();
    String text = _translationService.translate(key, params);
    await _speak(text);
  }

  void _addRoute(LatLng point) {
    setState(() {
      _routePoints.add(point);
    });
  }

  void _addMarker(LatLng position) {
    setState(() {
      _markers.add(
        Marker(
            point: position,
            child: const Icon(Icons.location_pin, size: 40, color: Colors.red)),
      );
    });
  }

  Future<void> _getMyLocation() async {
    // Si la permission est accordée, obtenir la position actuelle
    Position position = await Geolocator.getCurrentPosition();
    List<LatLng> route = await fetchRoute(
      LatLng(position.latitude, position.longitude),
      const LatLng(3.85200, 11.50020),
    );
    // _speak("take left");
    setState(() {
      _routePoints = route;
      _locationMessage =
          "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
      _location = LatLng(position.latitude, position.longitude);
    });
    _startListeningToPositionChanges();
    return;
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si les services de localisation sont activés
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    setState(() {
      _serviceEnabled = serviceEnabled;
    });
    if (!serviceEnabled) {
      // Si les services de localisation ne sont pas activés, vous pouvez avertir l'utilisateur
      setState(() {
        _locationMessage = "Les services de localisation sont désactivés.";
      });
      return;
    }

    // Demander la permission d'accéder à la localisation
    permission = await Geolocator.checkPermission();
    setState(() {
      _permission = permission;
    });
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Si la permission est refusée, gérer ce cas
        setState(() {
          _locationMessage = "Permission de localisation refusée.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Gérer le cas où la permission est refusée de manière permanente
      setState(() {
        _locationMessage =
            "Permission de localisation refusée de manière permanente.";
      });
      return;
    }

    _getMyLocation();
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

      setState(() {
        _locationMessage =
            "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  // LatLng getInitialCenter() {
  //   var center = _location != null
  //       ? LatLng(_location!.latitude, _location!.longitude)
  //       : const LatLng(37.785834, -122.406417);
  //   print(center);
  //   return center;
  // }

  void _detectDeviceLanguage() {
    Locale deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    setState(() {
      _translationService
          .setLanguage(deviceLocale.languageCode); // "en", "fr", etc.
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _detectDeviceLanguage();
  }

  @override
  void dispose() {
    positionStream?.cancel(); // Arrêter le stream quand le widget est détruit
    super.dispose();
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
      // appBar: AppBar(
      //   // TRY THIS: Try changing the color here to a specific color (to
      //   // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
      //   // change color while the other colors stay the same.
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text(widget.title),
      // ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _location, // Center the map over London
          initialZoom: 16.2,
          onMapReady: () {},
          onTap: (tapPosition, point) => _addMarker(point),
        ),
        children: [
          TileLayer(
            // Display map tiles from any source
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
            userAgentPackageName: 'com.example.app',
            // And many more recommended properties!
          ),
          RichAttributionWidget(
            // Include a stylish prebuilt attribution widget that meets all requirments
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () => launchUrl(Uri.parse(
                    'https://openstreetmap.org/copyright')), // (external)
              ),
              // Also add images...
            ],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
          MarkerLayer(
            markers: _markers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getMyLocation,
        tooltip: 'Center',
        child: const Icon(Icons.center_focus_weak_sharp),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
