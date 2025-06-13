class GeofenceFriend {
  final int friendId;
  final bool arrive;
  final bool leave;

  GeofenceFriend({
    required this.friendId,
    required this.arrive,
    required this.leave,
  });

  factory GeofenceFriend.fromJson(Map<String, dynamic> json) {
    return GeofenceFriend(
      friendId: json['FriendId'] as int,
      arrive: json['Arrive'] as bool,
      leave: json['Leave'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'FriendId': friendId,
    'Arrive': arrive,
    'Leave': leave,
  };
}

class GeofenceEntity {
  late int GeofenceId;
  final int userId;
  final int groupId;
  final double latitude;
  final double longitude;
  final double radius;
  final String name;
  final List<GeofenceFriend> friends;

  GeofenceEntity({
    required this.GeofenceId,
    required this.userId,
    required this.groupId,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.name,
    required this.friends,
  });

  /// Parses a single JSON object into a GeofenceEntity
  factory GeofenceEntity.fromJson(Map<String, dynamic> json) {
    return GeofenceEntity(
      GeofenceId: json['Id'] as int,
      userId: json['UserId'] as int,
      groupId: json['GroupId'] as int,
      latitude: (json['Latitude'] as num).toDouble(),
      longitude: (json['Longitude'] as num).toDouble(),
      radius: (json['Radius'] as num).toDouble(),
      name: json['Name'] as String,
      friends: List<GeofenceFriend>.from(
        (json['Friends'] as List<dynamic>).map(
          (fJson) => GeofenceFriend.fromJson(fJson),
        ),
      ),
    );
  }

  /// Parses a JSON array into a list of GeofenceEntity
  static List<GeofenceEntity> parseGeofenceData(List<dynamic> jsonList) {
    return jsonList
        .map((item) => GeofenceEntity.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() => {
    'UserId': userId,
    'GroupId': groupId,
    'Latitude': latitude,
    'Longitude': longitude,
    'Radius': radius,
    'Name': name,
    'Friends': friends.map((f) => f.toJson()).toList(),
  };

  Map<String, dynamic> toJsonForShowData() => {
    'Id': GeofenceId,
    'UserId': userId,
    'GroupId': groupId,
    'Latitude': latitude,
    'Longitude': longitude,
    'Radius': radius,
    'Name': name,
    'Friends': friends.map((f) => f.toJson()).toList(),
  };
}
