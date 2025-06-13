// location_history_model.dart
class LocationHistory {
  int? id;
  int userId;
  double startLat;
  double startLng;
  DateTime startTimestamp;
  double endLat;
  double endLng;
  DateTime endTimestamp;
  bool isSynced;

  LocationHistory({
    this.id,
    required this.userId,
    required this.startLat,
    required this.startLng,
    required this.startTimestamp,
    required this.endLat,
    required this.endLng,
    required this.endTimestamp,
    this.isSynced = false,
  });

  factory LocationHistory.fromJson(Map<String, dynamic> json) {
    return LocationHistory(
      id: json['LocationHistoryId'],
      userId: json['UserId'],
      startLat: json['StartLatitude'],
      startLng: json['StartLongitude'],
      startTimestamp: DateTime.parse(json['StartTimestamp']),
      endLat: json['EndLatitude'],
      endLng: json['EndLongitude'],
      endTimestamp: DateTime.parse(json['EndTimestamp']),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'startLat': startLat,
    'startLng': startLng,
    'startTimestamp': startTimestamp.toIso8601String(),
    'endLat': endLat,
    'endLng': endLng,
    'endTimestamp': endTimestamp.toIso8601String(),
    'isSynced': isSynced ? 1 : 0,
  };

  static LocationHistory fromMap(Map<String, dynamic> map) => LocationHistory(
    id: map['id'],
    userId: map['userId'],
    startLat: map['startLat'],
    startLng: map['startLng'],
    startTimestamp: DateTime.parse(map['startTimestamp']),
    endLat: map['endLat'],
    endLng: map['endLng'],
    endTimestamp: DateTime.parse(map['endTimestamp']),
    isSynced: map['isSynced'] == 1,
  );
}
