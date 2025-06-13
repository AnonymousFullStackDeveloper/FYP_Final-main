// import 'dart:convert';
// import 'dart:math';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:fyp_final/Service/ble_connection_handler.dart';

// class CommunicationHandler {
//   late final BleConnectionHandler bleConnectionHandler;
//   String deviceId = "";

//   CommunicationHandler() {
//     bleConnectionHandler = BleConnectionHandler();
//   }

//   void startScan(Function(DiscoveredDevice) scanDevice) {
//     bleConnectionHandler.startBluetoothScan(scanDevice);
//   }

//   Future<void> stopScan() async {
//     await bleConnectionHandler.stopScan();
//   }

//   void connectToDevice(
//     DiscoveredDevice discoveredDevice,
//     Function(bool) connectionStatus,
//   ) {
//     bleConnectionHandler.connectToDevice(discoveredDevice, (isConnected) {
//       deviceId = discoveredDevice.id;
//       connectionStatus(isConnected);
//       if (isConnected) {
//         readDeviceInformation(Uuid.parse("180a"), Uuid.parse("2a24"));
//       }
//     });
//   }

//   Future<void> readDeviceInformation(Uuid service, Uuid characteristic) async {
//     final characteristicInfo = QualifiedCharacteristic(
//       serviceId: service,
//       characteristicId: characteristic,
//       deviceId: deviceId,
//     );

//     try {
//       final response = await bleConnectionHandler.flutterReactiveBle
//           .readCharacteristic(characteristicInfo);
//       receivedCharacteristicValue(
//         characteristic: characteristicInfo,
//         values: response,
//       );
//     } catch (e) {
//       print("Error reading characteristic: $e");
//     }
//   }

//   void receivedCharacteristicValue({
//     required QualifiedCharacteristic characteristic,
//     required List<int> values,
//   }) {
//     String value = utf8.decode(values);
//     print("Received value from ${characteristic.characteristicId}: $value");
//   }
// }
