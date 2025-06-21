// Full corrected version of LiveLocationScreen.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fyp_final/Model/GeoFenceFriendsNotification.dart';
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
  bool _isMapReady = false;
  final int _updateDistance = 10;
  bool isLoading = false;
  Map<String, bool> _geofenceEntryState = {};
  Position? _lastUpdatedPosition;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    LocationSyncService().start();
  }

  Future<void> _initializeApp() async {
    try {
      await _checkLocationPermissions();
      Position initialPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
      _lastPosition = initialPosition;
      _updateCurrentLocation(initialPosition);
      await _sendLocationToDatabase(initialPosition);
      _startLocationUpdates();
      await _fetchFriendsData();
    } catch (e) {
      _showErrorDialog('Initialization Error', e.toString());
    }
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
      locationSettings: LocationSettings(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: _updateDistance),
    ).listen(
          (position) => _checkAndUpdateLocation(position),
      onError: (e) => _showErrorDialog('Location Error', e.toString()),
    );
  }

  void _checkAndUpdateLocation(Position position) {
    if (_lastPosition == null ||
        Geolocator.distanceBetween(_lastPosition!.latitude, _lastPosition!.longitude, position.latitude, position.longitude) >= _updateDistance) {
      _updateCurrentLocation(position);
      _sendLocationToDatabase(position);
      _lastPosition = position;
    }
  }

  void _updateCurrentLocation(Position position) {
    if (_lastUpdatedPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastUpdatedPosition!.latitude,
        _lastUpdatedPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      if (distance < 50) return;
    }
    _lastUpdatedPosition = position;
    _currentPosition = position;
    _markers.removeWhere((m) => m.key == const ValueKey("MeMarker"));
    _markers.add(_createMarker("Me", position.latitude, position.longitude));
    if (mounted) setState(() {});
  }

  Future<void> _sendLocationToDatabase(Position position) async {
    try {
      final userId = UserData.UserId;
      if (userId == null) throw Exception("User ID is null");
      await http.post(
        Uri.parse("$baseUrl/UserFriend/UpdateUserLiveLocation"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'Name': "name",
          'LocationId': "1000",
          'User_Id': userId,
          'Latitude': position.latitude,
          'Longitude': position.longitude,
          'time': DateTime.now().toString(),
        }),
      );
    } catch (e) {
      _showErrorDialog('Database Error', e.toString());
    }
  }

  Future<void> _fetchFriendsData() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("$baseUrl/UserFriend/GetGroupFriendsLiveLocation/${UserData.selectedGroup}"));
      if (response.statusCode == 200) {
        final friendsData = json.decode(response.body);
        setState(() => UserData.userGroupFriendsLiveLocation = friendsData);
        _addFriendMarkers(friendsData);
      }
    } catch (e) {
      _showErrorDialog('Fetch Error', e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _addFriendMarkers(List<dynamic> friendsData) {
    _markers.removeWhere((m) => m.key != const ValueKey("MeMarker"));
    _markers.add(_createMarker("Me", _currentPosition!.latitude, _currentPosition!.longitude));

    for (var friend in friendsData) {
      if (friend['User_Id'] != UserData.UserId) {
        final lat = (friend['latitude'] as num).toDouble();
        final lng = (friend['longitude'] as num).toDouble();
        final name = friend['name']?.toString() ?? 'F';
        _markers.add(_createMarker(name, lat, lng));
      }
      // else{
      //   _markers.add(_createMarker('Me', _currentPosition!.latitude, _currentPosition!.longitude));
      // }
    }
    if (mounted) setState(() {});
  }

  Marker _createMarker(String name, double lat, double lng) {
    return Marker(
      point: LatLng(lat, lng),
      width: 80,
      height: 80,
      child: GestureDetector(
        onTap: () => _mapController.moveAndRotate(LatLng(lat, lng), 15.0, 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(4)),
              child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 12), overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 4),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: getColorFromName(name)),
              alignment: Alignment.center,
              child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  bool _isInView(LatLng point) {
    if (!_isMapReady) return true;
    final bounds = _mapController.camera.visibleBounds;
    if (bounds == null) return false;
    const margin = 0.001;
    final south = bounds.south - margin;
    final north = bounds.north + margin;
    final west = bounds.west - margin;
    final east = bounds.east + margin;
    return point.latitude >= south && point.latitude <= north && point.longitude >= west && point.longitude <= east;
  }

  Offset _getEdgePosition(LatLng point, BuildContext context) {
    final mapCenter = _mapController.camera.center;
    final size = MediaQuery.of(context).size;
    final dx = point.longitude - mapCenter.longitude;
    final dy = point.latitude - mapCenter.latitude;
    const edgeOffset = 20.0;
    const indicatorSize = 60.0;
    if (dx.abs() > dy.abs()) {
      return Offset(dx > 0 ? size.width - edgeOffset - indicatorSize : edgeOffset, size.height / 2 - indicatorSize / 2);
    } else {
      return Offset(size.width / 2 - indicatorSize / 2, dy > 0 ? edgeOffset : size.height - edgeOffset - indicatorSize);
    }
  }

  List<Widget> _buildOffScreenFriendIndicators(BuildContext context) {
    if (!_isMapReady) return [];
    return UserData.userGroupFriendsLiveLocation.map<Widget>((friend) {
      if (friend['User_Id'] == UserData.UserId) return const SizedBox();
      final lat = (friend['latitude'] as num).toDouble();
      final lng = (friend['longitude'] as num).toDouble();
      final point = LatLng(lat, lng);
      if (_isInView(point)) return const SizedBox();
      final pos = _getEdgePosition(point, context);
      final name = friend['name']?.toString() ?? 'F';
      return Positioned(
        left: pos.dx,
        top: pos.dy,
        child: GestureDetector(
          onTap: () => _mapController.move(point, 15.0),
          child: Column(
            children: [
              const Icon(Icons.arrow_drop_up, color: Colors.red),
              CircleAvatar(radius: 18, backgroundColor: getColorFromName(name), child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white))),
              Text(name, style: const TextStyle(fontSize: 10, color: Colors.black)),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildMap() {
    if (_currentPosition == null) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              initialZoom: 15,
              onMapReady: () => Future.delayed(const Duration(milliseconds: 100), () => setState(() => _isMapReady = true)),
              onPositionChanged: (pos, _) => setState(() {}),
            ),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.live_location'),
              MarkerLayer(markers: _markers),
            ],
          ),
          ..._buildOffScreenFriendIndicators(context),
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
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text(title), content: Text(message), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))]));
  }

  void _showPermissionDeniedDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Location Required'),
        content: const Text('This app needs location permissions to function'),
        actions: [TextButton(onPressed: () => openAppSettings(), child: const Text('Open Settings'))],
      ),
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: _buildMap());
}
