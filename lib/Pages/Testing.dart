import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fyp_final/SharedData/PreferencedVariable.dart';
import 'package:fyp_final/SharedData/UserDetails.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class LiveLocationApp extends StatelessWidget {
  const LiveLocationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Location Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LiveLocationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LiveLocationScreen extends StatefulWidget {
  const LiveLocationScreen({super.key});

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  StreamSubscription<Position>? _positionStream;
  Position? _currentPosition;
  Position? _lastPosition;
  static String baseUrl = UserData.getUrl();

  int user_id = 0;

  final int _updateDistance = 10;
  List<dynamic> friendsList = [];

  bool onceLoad = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();

    if (UserData.userInidividualFriendsLiveLocation.isEmpty) {
      _fetchFriendLocation();
    } else {
      _addFriendMarkers(UserData.userInidividualFriendsLiveLocation);
    }
  }

  Future<void> _initializeApp() async {
    try {
      await _checkLocationPermissions();
      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );
      _updateCurrentLocation(initialPosition);
      // _addInitialMarkers();
      // _startLocationUpdates();
    } catch (e) {
      _showErrorDialog('Initialization Error', e.toString());
    }
  }

  Future<void> _fetchFriendLocation() async {
    try {
      final url = Uri.parse(
        "$baseUrl/UserFriend/GetUserFriendsLiveLocation/${UserData.UserId}",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> friendsData = json.decode(response.body);
        print("User Friend Live Loction : ${response.body}");

        setState(() {
          UserData.userInidividualFriendsLiveLocation = friendsData;
        });
      } else {
        print("Failed to load live location for user ${UserData.UserId}");
      }
      _addFriendMarkers(UserData.userInidividualFriendsLiveLocation);
    } catch (e) {
      print("Error fetching friend location Testing Screen: $e");
    }
  }

  Future<void> _checkLocationPermissions() async {
    final status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      _showPermissionDeniedDialog();
      throw Exception('Location permission denied');
    }
  }

  Position? _lastUpdatedPosition;

  void _updateCurrentLocation(Position position) {
    // Only update if moved more than 50 meters
    if (_lastUpdatedPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastUpdatedPosition!.latitude,
        _lastUpdatedPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      if (distance < 50) return; // Don't update if less than 50 meters
    }

    _lastUpdatedPosition = position;
    _currentPosition = position;
    _centerMap(position);

    // Remove previous "Me" marker
    _markers.removeWhere((m) => m.key == const ValueKey("MeMarker"));
    _markers.add(_createMarker("Me", position.latitude, position.longitude));

    // Add new "Me" marker
    // _markers.add(
    //   Marker(
    //     key: const ValueKey("MeMarker"),
    //     point: LatLng(position.latitude, position.longitude),
    //     width: 40,
    //     height: 40,
    //     child: const Icon(
    //       Icons.person_pin_circle,
    //       color: Colors.blue,
    //       size: 40,
    //     ),
    //   ),
    // );

    if (mounted) setState(() {});
  }

  void _addFriendMarkers(List<dynamic> friendsData) {
    for (var friend in friendsData) {
      if (friend['User_Id'] != UserData.UserId) {
        final double lat = (friend['latitude'] as num).toDouble();
        final double lng = (friend['longitude'] as num).toDouble();
        final String name = friend['name']?.toString() ?? 'F';

        _markers.add(_createMarker(name, lat, lng));
      }

      if (mounted) {
        setState(() {});
      }
    }
  }

  Marker _createMarker(String name, double lat, double lng) {
    return Marker(
      point: LatLng(lat, lng),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () {
          // Handle tap event here
          print('Marker for $name tapped!');
          _mapController.moveAndRotate(
            LatLng(lat, lng),
            15.0,
            0.0,
          ); // Change zoom level as needed
          // You can also open a dialog, navigate, or show a bottom sheet
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: getColorFromName(name),
          ),
          alignment: Alignment.center,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _centerMap(Position position) {
    _mapController.move(
      LatLng(position.latitude, position.longitude),
      _mapController.camera.zoom,
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        onMapReady: () {
          if (_currentPosition != null) {
            _centerMap(_currentPosition!);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.live_location',
        ),
        MarkerLayer(markers: _markers),
      ],
    );
  }

  Color getColorFromName(String name) {
    int hash = name.codeUnits.fold(0, (prev, char) => prev + char);
    int red = (hash * 37) % 255;
    int green = (hash * 67) % 255;
    int blue = (hash * 97) % 255;
    return Color.fromARGB(255, red, green, blue);
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showPermissionDeniedDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Location Required'),
            content: const Text(
              'This app needs location permissions to function',
            ),
            actions: [
              TextButton(
                onPressed: () => openAppSettings(),
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildMap());
  }
}
