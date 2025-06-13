// import 'package:flutter/material.dart';
// import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
//
// class MapSearchPage extends StatefulWidget {
//   @override
//   _MapSearchPageState createState() => _MapSearchPageState();
// }
//
// class _MapSearchPageState extends State<MapSearchPage> {
//   late MapController mapController;
//   GeoPoint? selectedLocation; // Stores the selected location
//
//   @override
//   void initState() {
//     super.initState();
//     mapController = MapController(
//       initPosition: GeoPoint(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Search & Save Location")),
//       body: Stack(
//         children: [
//           // Map Widget
//           OSMFlutter(
//             controller: mapController,
//             trackMyPosition: false,
//             initZoom: 12,
//             minZoomLevel: 3,
//             maxZoomLevel: 19,
//             userLocationMarker: UserLocationMaker(
//               personMarker: MarkerIcon(
//                 icon: Icon(Icons.location_pin, color: Colors.red, size: 48),
//               ),
//               directionArrowMarker: MarkerIcon(
//                 icon: Icon(Icons.navigation, size: 48),
//               ),
//             ),
//           ),
//
//           // Search & Save Buttons
//           Positioned(
//             top: 10,
//             right: 10,
//             left: 10,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Search Button
//                 ElevatedButton.icon(
//                   onPressed: () async {
//                     GeoPoint? location = await mapController.selectPosition(); // Search & Select
//
//                     if (location != null) {
//                       setState(() {
//                         selectedLocation = location;
//                       });
//                       await mapController.goToLocation(location);
//                     }
//                   },
//                   icon: const Icon(Icons.search),
//                   label: const Text("Search"),
//                 ),
//
//                 // Save Button
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     if (selectedLocation != null) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                               "Location Saved: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}"),
//                           duration: const Duration(seconds: 2),
//                         ),
//                       );
//                       // TODO: Save selectedLocation to a database or pass it to another screen
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("No location selected!")),
//                       );
//                     }
//                   },
//                   icon: const Icon(Icons.save),
//                   label: const Text("Save"),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:fyp_final/Pages/AddGeoFenceScreen.dart';
import 'package:fyp_final/Service/apiService.dart';
import 'package:fyp_final/SharedData/PreferencedVariable.dart';
import 'package:fyp_final/SharedData/UserDetails.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

class AddLocation extends StatelessWidget {
  const AddLocation({super.key});

  @override
  Widget build(BuildContext context) {
    ApiService apiService = new ApiService();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Location",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: FlutterLocationPicker(
        initPosition: LatLong(33.5651, 73.0169),
        initZoom: 11,
        minZoomLevel: 5,
        maxZoomLevel: 16,
        // trackMyPosition: true,
        selectLocationButtonText: "Next",
        searchBarBackgroundColor: Colors.white,
        searchbarBorderRadius: BorderRadius.circular(50),
        searchbarInputBorder: OutlineInputBorder(borderSide: BorderSide.none),
        selectedLocationButtonTextStyle: const TextStyle(fontSize: 18),
        mapLanguage: 'en',
        onError: (e) => print(e),
        selectLocationButtonLeadingIcon: const Icon(Icons.check),

        onPicked: (pickedData) {
          try {
            print("Pressed : ${pickedData.latLong.latitude}");
            print(pickedData.latLong.longitude);
            print(pickedData.address); // Likely causing error
            print(pickedData.addressData);

            // String address = pickedData.address.toString();
            // String name = address.split(',').first;
            // print("Place Name : $name");

              UserData.latitudeGeofence = pickedData.latLong.latitude;
              UserData.longitudeGeofence = pickedData.latLong.longitude;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddGeofenceScreen(),
              ),
            );
          } catch (e) {
            print("Error parsing picked data: $e");
          }
        },

        onChanged: (pickedData) {
          print(pickedData.latLong.latitude);
          print(pickedData.latLong.longitude);
          print(pickedData.address);
          print(pickedData.addressData);
        },

        showContributorBadgeForOSM: true,
      ),
    );
  }
}
