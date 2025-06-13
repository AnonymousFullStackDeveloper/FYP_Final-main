import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fyp_final/Model/UserTripHistory.dart';
import 'package:fyp_final/SharedData/UserDetails.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TripsListPage extends StatefulWidget {
  @override
  State<TripsListPage> createState() => _TripsListPageState();
}

class _TripsListPageState extends State<TripsListPage> {
  List<TripEntry> trips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTripHistory();
  }

  Future<void> fetchTripHistory() async {
    try {
      setState(() => isLoading = true);
      final userId = UserData.selectedUserIdForLocationHistory;
      final url = Uri.parse(
        '${UserData.getUrl()}/UserTripLog/GetByUserId/$userId',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          trips = data.map((item) => TripEntry.fromJson(item)).toList();
        });
      } else {
        print('Failed to load trips: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching trips: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${UserData.selectedTripUserName} Trips'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchTripHistory,
        child:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : trips.isEmpty
                ? ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 100),
                    Center(
                      child: Text(
                        'No trips found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  ],
                )
                : ListView.builder(
                  itemCount: trips.length,
                  itemBuilder: (_, i) => TripCard(trip: trips[i]),
                ),
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  final TripEntry trip;
  const TripCard({required this.trip});

  @override
  Widget build(BuildContext ctx) {
    // centre the mini-map halfway between start & end:
    final centre = LatLng(
      (trip.startLoc.latitude + trip.endLoc.latitude) / 2,
      (trip.startLoc.longitude + trip.endLoc.longitude) / 2,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Header ───────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.directions_car, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${trip.timeRange} (${trip.duration})',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Mini-map preview ─────────────────
          SizedBox(
            height: 140,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: centre,
                initialZoom: 14,
                // interactiveFlags:
                // InteractiveFlag.none, // disable pan/zoom on the preview
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [trip.startLoc, trip.endLoc],
                      strokeWidth: 3,
                      color: Colors.green,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: trip.startLoc,
                      width: 24,
                      height: 24,
                      child: Icon(Icons.circle, color: Colors.red, size: 16),
                    ),
                    Marker(
                      point: trip.endLoc,
                      width: 24,
                      height: 24,
                      child: Icon(Icons.flag, color: Colors.green, size: 36),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── Footer ───────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.place, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text(trip.address)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0XFF8652FF),
                    shape: StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () {
                    // handle “Add to Places”
                    print("Click Favorite");
                  },
                  child: Text(
                    'Add to Favorite',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TripEntry {
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String address;
  final LatLng startLoc;
  final LatLng endLoc;

  TripEntry({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.address,
    required this.startLoc,
    required this.endLoc,
  });
  factory TripEntry.fromJson(Map<String, dynamic> json) {
    return TripEntry(
      title: 'Trip', // default title
      startTime: DateTime.parse(json['StartTimestamp']),
      endTime: DateTime.parse(json['EndTimestamp']),
      address: 'Unknown Location', // or fetch it from another source if needed
      startLoc: LatLng(
        (json['StartLatitude'] as num).toDouble(),
        (json['StartLongitude'] as num).toDouble(),
      ),
      endLoc: LatLng(
        (json['EndLatitude'] as num).toDouble(),
        (json['EndLongitude'] as num).toDouble(),
      ),
    );
  }

  String get duration {
    final diff = endTime.difference(startTime);
    final m = diff.inMinutes;
    if (m < 60) return '$m min';
    final h = diff.inHours;
    final mm = m % 60;
    return '${h}h ${mm}m';
  }

  String get timeRange => '${_fmt(startTime)} – ${_fmt(endTime)}';

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
