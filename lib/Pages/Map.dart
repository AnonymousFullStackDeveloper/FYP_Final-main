import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fyp_final/Service/LocationHistoryService.dart';
import 'package:fyp_final/SharedData/PreferencedVariable.dart';
import 'package:fyp_final/SharedData/UserDetails.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class LiveLocationApp2 extends StatelessWidget {
  const LiveLocationApp2({super.key});

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
  final GlobalKey<_LiveLocationScreenState> _mapKey =
      GlobalKey<_LiveLocationScreenState>(); // GlobalKey for the map

  // int user_id = 0;
  final int _updateDistance = 10;

  bool isLoading = false;

  get controller => null; // For loading state

  @override
  void initState() {
    super.initState();
    _initializeApp();
    if (UserData.userGroupFriendsLiveLocation.isEmpty) {
      _fetchFriendsData();
    } else {
      _addFriendMarkers(UserData.userGroupFriendsLiveLocation);
    }
    LocationSyncService().start();
  }

  Future<void> _initializeApp() async {
    try {
      await _checkLocationPermissions();
      final hasPermission = await Geolocator.checkPermission();
      if (hasPermission == LocationPermission.denied ||
          hasPermission == LocationPermission.deniedForever) {
        await Geolocator.requestPermission();
      }

      Position initialPosition = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      _lastPosition = initialPosition;
      _updateCurrentLocation(initialPosition);
      await _sendLocationToDatabase(initialPosition);
      _startLocationUpdates();
      await _fetchFriendsData(); // Fetch friends data on initialization
    } catch (e) {
      _showErrorDialog('Initialization Error', e.toString());
    }
  }

  Future<void> _fetchFriendsData() async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      print("User id In Live Location: ${UserData.selectedGroup}");

      final response = await http.get(
        Uri.parse(
          "$baseUrl/UserFriend/GetGroupFriendsLiveLocation/${UserData.selectedGroup}",
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> friendsData = json.decode(response.body);
        setState(() {
          UserData.userGroupFriendsLiveLocation = friendsData;
        });
        print("Group Friend Live Location : ${response.body}");

        if (friendsData.isEmpty) {
          print("No friends data found.");
        }
        _addFriendMarkers(UserData.userGroupFriendsLiveLocation);
      } else {
        throw Exception(
          'Failed to load friends data. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("Error fetching friends data: $e");
      _showErrorDialog('Fetch Error', e.toString());
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
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

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Future<void> _checkLocationPermissions() async {
    final status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      _showPermissionDeniedDialog();
      throw Exception('Location permission denied');
    }
  }

  void _startLocationUpdates() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: _updateDistance,
      ),
    ).listen(
      (position) => _checkAndUpdateLocation(position),
      onError: (e) => _showErrorDialog('Location Error', e.toString()),
    );
  }

  void _checkAndUpdateLocation(Position position) {
    if (_lastPosition == null) {
      _lastPosition = position;
    } else {
      double distanceInMeters = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      if (distanceInMeters >= _updateDistance) {
        _updateCurrentLocation(position);
        _sendLocationToDatabase(position);
        _lastPosition = position;
      }
    }
  }

  Future<void> _sendLocationToDatabase(Position position) async {
    try {
      final userId = UserData.UserId;
      if (userId == null) {
        throw Exception("User ID is null");
      }

      final response = await http.post(
        Uri.parse("$baseUrl/UserFriend/UpdateUserLiveLocation"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'Name': "name", // Replace with actual name if needed
          'LocationId': "1000", // Replace with actual locationId if needed
          'User_Id': userId,
          'Latitude': position.latitude,
          'Longitude': position.longitude,
          'time': DateTime.now().toString(),
        }),
      );

      print(
        "Lat: ${position.latitude}, Lon: ${position.longitude}, User: $userId",
      );

      if (response.statusCode == 200) {
        print("Location updated successfully.");
      } else {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception('Failed to update location in the database');
      }
    } catch (e) {
      _showErrorDialog('Database Error', e.toString());
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
    final mapState = _mapKey.currentState;
    if (mapState != null) {
      mapState.controller.move(
        LatLng(position.latitude, position.longitude),
        mapState.controller.zoom,
      );
    }
  }

  Widget _buildMap() {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body:
          _currentPosition == null
              ? Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  FlutterMap(
                    key: _mapKey,
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      initialZoom: 15,
                      onMapReady: () {
                        _centerMap(_currentPosition!);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.live_location',
                      ),
                      MarkerLayer(markers: _markers),
                    ],
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      onPressed: () {
                        if (_currentPosition != null) {
                          _centerMap(_currentPosition!);
                        }
                      },
                      child: Icon(Icons.my_location),
                    ),
                  ),
                ],
              ),
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
    return Scaffold(
      // appBar: AppBar(title: const Text('Live Location Tracker')),
      body: _buildMap(),
    );
  }
}
