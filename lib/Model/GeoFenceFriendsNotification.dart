class Geofence {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius; // in meters
  final List<String> friendIds; // IDs of selected friends to monitor

  Geofence({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.friendIds,
  });
}


class Friend {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  Friend({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

