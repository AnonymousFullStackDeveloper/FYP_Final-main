import 'dart:async';
import 'dart:convert';
import 'package:fyp_final/SharedData/UserDetails.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../SharedData/SqlfLite.dart';

class LocationSyncService {
  static final LocationSyncService _instance = LocationSyncService._internal();
  factory LocationSyncService() => _instance;
  LocationSyncService._internal();

  StreamSubscription<Position>? _positionSub;
  StreamSubscription<ConnectivityResult>? _connectivitySub;

  final String _apiUrl = '${UserData.getUrl()}/UserTripLog/Add';

  Position? _startPosition;
  DateTime? _startTime;
  DateTime? _lastMovedTime;

  Future<void> start() async {
    final hasPermission = await _checkPermission();
    if (!hasPermission) return;

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    ).listen((Position pos) async {
      final now = DateTime.now();
      final isOnline = await _isConnected();

      if (_startPosition == null) {
        _startPosition = pos;
        _startTime = now;
        _lastMovedTime = now;
        return;
      }

      final distance = Geolocator.distanceBetween(
        _startPosition!.latitude,
        _startPosition!.longitude,
        pos.latitude,
        pos.longitude,
      );

      if (distance >= 50) {
        // User moved 50 meters, update last moved time
        _lastMovedTime = now;
      }

      final timeSinceLastMove = now.difference(_lastMovedTime!).inMinutes;

      if (timeSinceLastMove >= 3) {
        // End current trip and start new one
        final trip = {
          'UserId': UserData.UserId,
          'StartLatitude': _startPosition!.latitude,
          'StartLongitude': _startPosition!.longitude,
          'StartTimestamp': _startTime!.toIso8601String(),
          'EndLatitude': pos.latitude,
          'EndLongitude': pos.longitude,
          'EndTimestamp': now.toIso8601String(),
        };

        if (isOnline) {
          await _sendTripToServer(trip);
          await _syncStoredTrips(); // Send all unsynced data if online
        } else {
          await DBHelper.insertTrip(trip);
        }

        // Reset for next trip
        _startPosition = pos;
        _startTime = now;
        _lastMovedTime = now;
      }
    });

    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        await _syncStoredTrips();
      }
    }) as StreamSubscription<ConnectivityResult>?;
  }

  Future<void> stop() async {
    await _positionSub?.cancel();
    await _connectivitySub?.cancel();
  }

  Future<void> _sendTripToServer(Map<String, dynamic> trip) async {
    try {
      final res = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(trip),
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('Failed to send trip: ${res.statusCode}');
      }
    } catch (e) {
      await DBHelper.insertTrip(trip); // store offline if sending fails
    }
  }

  Future<void> _syncStoredTrips() async {
    final unsyncedTrips = await DBHelper.getUnsyncedTrips();

    for (var trip in unsyncedTrips) {
      try {
        await _sendTripToServer(trip);
        await DBHelper.markTripAsSynced(trip['id']);
      } catch (_) {
        break; // stop on first failure to avoid rapid retries
      }
    }
  }

  Future<bool> _isConnected() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<bool> _checkPermission() async {
    final status = await Geolocator.requestPermission();
    return status == LocationPermission.always || status == LocationPermission.whileInUse;
  }
}
