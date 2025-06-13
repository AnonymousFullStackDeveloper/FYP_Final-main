// import 'dart:async';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:permission_handler/permission_handler.dart';

// class BleManager {
//   final FlutterReactiveBle _ble = FlutterReactiveBle();
//   StreamSubscription<DiscoveredDevice>? _scanSubscription;
//   StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
//   bool _isScanning = false;

//   // Callback functions
//   Function(DiscoveredDevice)? onDeviceFound;
//   Function(bool)? onConnected;

//   Future<void> checkPermissions() async {
//   Map<Permission, PermissionStatus> statuses = await [
//     Permission.bluetoothScan,
//     Permission.bluetoothConnect,
//     Permission.locationWhenInUse,  // Required for scanning
//   ].request();

//   print("🛑 Permissions: $statuses");

//   if (statuses[Permission.bluetoothScan] != PermissionStatus.granted ||
//       statuses[Permission.bluetoothConnect] != PermissionStatus.granted ||
//       statuses[Permission.locationWhenInUse] != PermissionStatus.granted) {
//     print("❌ Bluetooth permissions not granted!");
//   }
// }


//   void startScan() {
//   print("🔍 Starting BLE scan...");

//   _scanSubscription = _ble.scanForDevices(withServices: []).listen(
//     (device) {
//       if (device.name.isNotEmpty) {
//         print("✅ Found Device: ${device.name} - ${device.id}");
//         onDeviceFound?.call(device);
//       }
//     },
//     onError: (e) {
//       print("❌ Scan error: $e");
//     },
//   );

//   // Stop scanning after 10 seconds
//   Future.delayed(Duration(seconds: 10), stopScan);
// }


//   void stopScan() {
//     _scanSubscription?.cancel();
//     _isScanning = false;
//   }

//   void connectToDevice(DiscoveredDevice device) {
//     stopScan(); // Stop scanning before connecting

//     _connectionSubscription = _ble.connectToDevice(id: device.id).listen(
//       (connectionState) {
//         print("🔗 Connection state: ${connectionState.connectionState}");
        
//         if (connectionState.connectionState == DeviceConnectionState.connected) {
//           onConnected?.call(true);
//         } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
//           onConnected?.call(false);
//         }
//       },
//       onError: (error) => print("❌ Connection error: $error"),
//     );
//   }

//   void disconnect() {
//     _connectionSubscription?.cancel();
//   }
// }
