// import 'package:flutter/material.dart';
// import 'package:fyp_final/Service/ble_connection_handler.dart';
// // import 'package:fyp_final/ble_manager.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // final BleManager bleManager = BleManager();
//   List<DiscoveredDevice> discoveredDevices = [];
//   bool isConnected = false;
//   String connectedDeviceDetails = "";

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("BLE Scanner")),
//       body: Column(
//         children: [
//           Center(
//             child: ElevatedButton(
//               onPressed: () {
//                 setState(() => discoveredDevices.clear());
//               },
//               child: const Text("Start Scan"),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(10),
//               itemCount: discoveredDevices.length,
//               itemBuilder: (context, index) {
//                 final device = discoveredDevices[index];
//                 return ListTile(
//                   title: Text(device.name),
//                   subtitle: Text(device.id),
//                   trailing: ElevatedButton(
//                     onPressed: () => {},
//                     child: Text(isConnected ? "Connected" : "Connect"),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Text(connectedDeviceDetails),
//           ),
//         ],
//       ),
//     );
//   }
// }
