import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fyp_final/Model/GeofenceFriends.dart';
import 'package:fyp_final/Model/UserGroupGeofence.dart';
import 'package:fyp_final/Pages/LocationsScreen.dart';
import 'package:fyp_final/Service/apiService.dart';
import 'package:fyp_final/SharedData/PreferencedVariable.dart';
import 'package:fyp_final/SharedData/UserDetails.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class AddGeofenceScreen extends StatefulWidget {
  const AddGeofenceScreen({super.key});

  @override
  _AddGeofenceScreenState createState() => _AddGeofenceScreenState();
}

class Friend {
  int id;
  final String name;
  bool notifyOnEnter;
  bool notifyOnExit;

  Friend({
    required this.id,
    required this.name,
    required this.notifyOnEnter,
    required this.notifyOnExit,
  });
}

class _AddGeofenceScreenState extends State<AddGeofenceScreen> {
  LatLng? centerPoint;
  double radius = 200;
  final double minRadius = 100;
  final double maxRadius = 2000;
  final TextEditingController nameController = TextEditingController();

  List<Friend> friends = [];
  final StorageManager storageManager = StorageManager();
  final ApiService apiService = ApiService();
  StreamSubscription<Position>? positionStream;

  bool wasInside = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    startLocationUpdates();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    nameController.dispose();
    super.dispose();
  }

  void _loadData() async {
    final userId = await storageManager.getUserId();

      centerPoint = LatLng(UserData.latitudeGeofence, UserData.longitudeGeofence);

      print(centerPoint);
      List<Friend> tempFriends = UserData.userGroupFriends
          .where((element) => element['User_Id'] != userId)
          .map((element) => Friend(
        id: element['User_Id'],
        name: element['Name'],
        notifyOnEnter: false,
        notifyOnExit: false,
      ))
          .toList();

      setState(() {
        friends = tempFriends;
      });
    // } else {
    //   for (var gf in UserData.UserGeofenceDetails) {
    //     nameController.text = gf.name;
    //     radius = gf.radius;
    //     centerPoint = LatLng(gf.latitude, gf.longitude);
    //
    //     friends = gf.friends
    //         .map((f) => Friend(
    //       id: f.friendId,
    //       name: "Name",
    //       notifyOnEnter: f.arrive,
    //       notifyOnExit: f.leave,
    //     ))
    //         .toList();
    //     break; // Assuming only one geofence is being edited
    //   }
    //
    //   setState(() {});
    // }
  }

  void startLocationUpdates() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    ).listen(checkGeofence);
  }

  void checkGeofence(Position position) {
    if (centerPoint == null) return;

    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      centerPoint!.latitude,
      centerPoint!.longitude,
    );

    final isInside = distance <= radius;

    if (isInside && !wasInside) {
      print("📍 Entered geofence!");
    } else if (!isInside && wasInside) {
      print("🚶‍♂️ Exited geofence!");
    }

    wasInside = isInside;
  }

  Future<void> saveGeofence() async {
    if (centerPoint == null || nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please name your geofence."),
          backgroundColor: Color.fromARGB(255, 21, 110, 40),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    List<GeofenceFriend> fr = friends
        .map((f) => GeofenceFriend(
      friendId: f.id,
      arrive: f.notifyOnEnter,
      leave: f.notifyOnExit,
    ))
        .toList();

    GeofenceEntity geofenceEntry = GeofenceEntity(
      GeofenceId: 0,
      groupId: UserData.selectedGroup,
      userId: UserData.UserId,
      name: nameController.text,
      latitude: centerPoint!.latitude,
      longitude: centerPoint!.longitude,
      radius: radius,
      friends: fr,
    );

    int res = await apiService.addGeofenceEntity(geofenceEntry);

    setState(() => isLoading = false);

    if (res == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geofence Added!')),
      );
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = screenHeight * 0.3;

    return Scaffold(
      appBar: AppBar(title: const Text("Set Geofence")),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: mapHeight,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(centerPoint!.latitude, centerPoint!.longitude) ,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                ),
                if (centerPoint != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: centerPoint!,
                        color: const Color.fromRGBO(134, 82, 255, 0.2),
                        borderColor: const Color.fromRGBO(134, 82, 255, 0.3),
                        borderStrokeWidth: 2,
                        radius: radius,
                        useRadiusInMeter: true,
                      ),
                    ],
                  ),
                if (centerPoint != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: centerPoint!,
                        width: 30,
                        height: 30,
                        child: const Icon(
                          Icons.location_on,
                          size: 30,
                          color: Color.fromRGBO(134, 82, 255, 1.0),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Positioned(
            top: mapHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: "Geofence Name",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.edit_location_alt),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  activeColor: const Color.fromRGBO(134, 82, 255, 0.7),
                                  inactiveColor: const Color.fromRGBO(134, 82, 255, 0.3),
                                  value: radius,
                                  min: minRadius,
                                  max: maxRadius,
                                  label: "${radius.toStringAsFixed(0)} meters",
                                  onChanged: (value) {
                                    setState(() => radius = value);
                                  },
                                ),
                              ),
                              Text("${radius.toStringAsFixed(0)} meter"),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Get notified When...",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.35,
                            child: ListView.builder(
                              itemCount: friends.length,
                              itemBuilder: (context, index) {
                                final friend = friends[index];
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            friend.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                const Text("Arrive", style: TextStyle(fontWeight: FontWeight.bold)),
                                                Switch(
                                                  value: friend.notifyOnEnter,
                                                  onChanged: (val) {
                                                    setState(() => friend.notifyOnEnter = val);
                                                  },
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Text("Leave", style: TextStyle(fontWeight: FontWeight.bold)),
                                                Switch(
                                                  value: friend.notifyOnExit,
                                                  onChanged: (val) {
                                                    setState(() => friend.notifyOnExit = val);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : saveGeofence,
                      child: isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text("Save Geofence"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
