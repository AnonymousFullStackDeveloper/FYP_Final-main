import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fyp_final/Model/GeofenceFriends.dart';
import 'package:fyp_final/Model/UserGroupGeofence.dart';
import 'package:fyp_final/Pages/AddGeoFenceScreen.dart';
import 'package:fyp_final/Pages/AddLocation.dart';
import 'package:fyp_final/Service/apiService.dart';
import 'package:fyp_final/SharedData/UserDetails.dart';
import 'package:http/src/response.dart';
import 'package:searchable_listview/searchable_listview.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationsScreen> {
  bool isLoading = true;
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> listGeofenceDetails = [];

  @override
  void initState() {
    super.initState();

    if (UserData.UserGeofenceDetails.isEmpty) {
      loadGeofences(); // This will manage isLoading internally
    } else {
      listGeofenceDetails =
          UserData.UserGeofenceDetails.map(
            (e) => e.toJsonForShowData(),
          ).toList();
      isLoading = false;
    }
  }

  Future<void> loadGeofences() async {
    setState(() => isLoading = true);

    try {
      List<GeofenceEntity> entries = await apiService.fetchGeofencesByUserId(
        UserData.UserId,
      );

      setState(() {
        UserData.UserGeofenceDetails = entries;
        listGeofenceDetails =
            entries.map((e) => e.toJsonForShowData()).toList();
        isLoading = false;
      });

      for (var gf in entries) {
        print("object Id${gf.GeofenceId}");
        print('--- Geofence: ${gf.name} ');
        print('UserId:   ${gf.userId}');
        print('GroupId:  ${gf.groupId}');
        print('Location: (${gf.latitude}, ${gf.longitude})');
        print('Radius:   ${gf.radius}');
        print('Friends:');
        for (var f in gf.friends) {
          print(
            '  • FriendId: ${f.friendId} | Arrive: ${f.arrive} | Leave: ${f.leave}',
          );
        }
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Your Geofences",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: loadGeofences,
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : listGeofenceDetails.isEmpty
                ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 200),
                    const Center(child: Text("No locations found.")),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddLocation(),
                            ),
                          );
                          if (result == 'reload' && mounted) {
                            await loadGeofences();
                          }
                        },
                        child: const Text('Add Geofence'),
                      ),
                    ),
                  ],
                )
                : Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SearchableList<Map<String, dynamic>>(
                          initialList: listGeofenceDetails,
                          lazyLoadingEnabled: false,
                          sortPredicate:
                              (a, b) => a['Name'].compareTo(b['Name']),
                          itemBuilder: (item) => _buildLocationItem(item),
                          filter:
                              (query) =>
                                  listGeofenceDetails
                                      .where(
                                        (location) => location['Name']
                                            .toString()
                                            .toLowerCase()
                                            .contains(query.toLowerCase()),
                                      )
                                      .toList(),
                          physics:
                              const AlwaysScrollableScrollPhysics(), // <-- Add this
                          inputDecoration: InputDecoration(
                            labelText: "Search Geofences",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        onPressed: () async {
                          UserData.isUpdateGeofenec = true;

                          var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddLocation(),
                            ),
                          );
                          if (result == 'reload' && mounted) {
                            await loadGeofences();
                          }
                        },
                        child: const Text('Add Geofence'),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildLocationItem(Map<String, dynamic> location) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.fence_outlined,
            color: Colors.green,
            size: MediaQuery.of(context).size.width * 0.08,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                print("Clicked Geofence${location['Id']}");
                UserData.isUpdateGeofenec = false;
                await apiService.deleteGeofenceById(location['Id']);
                // loadGeofences();

                // UserData.SelectedGeofenceEntity =
                // print('--- Geofence: ${gf.name} ');
                // print('UserId:   ${gf.userId}');
                // print('GroupId:  ${gf.groupId}');
                // print('Location: (${gf.latitude}, ${gf.longitude})');
                // print('Radius:   ${gf.radius}');
                // print('Friends:');
                // for (var f in gf.friends) {
                //   print(
                //     '  • FriendId: ${f.friendId} | Arrive: ${f.arrive} | Leave: ${f.leave}',
                //   );
                // }

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const AddGeofenceScreen(),
                //   ),
                // );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${location['Name'] ?? ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: MediaQuery.of(context).size.width * 0.07,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  print("Delete button pressed!${location['Id']}");
                  Future<Response> r = apiService.deleteGeofenceById(
                    location['Id'],
                  );
                  // ignore: unrelated_type_equality_checks
                  if (r == 200) {
                    loadGeofences();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Geofence Deleted Sucessfully!')),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
