// class GeofenceEntry {
//   final int userId;
//   final int groupId;
//   final String geofenceName;
//   final bool arrive;
//   final bool leave;
//   final double latitude;
//   final double longitude;
//   final double radius;

//   GeofenceEntry({
//     required this.userId,
//     required this.groupId,
//     required this.geofenceName,
//     required this.arrive,
//     required this.leave,
//     required this.latitude,
//     required this.longitude,
//     required this.radius,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'UserId': userId,
//       'GroupId': groupId,
//       'GeofenceName': geofenceName,
//       'Arrive': arrive,
//       'Leave': leave,
//       'Latitude': latitude,
//       'Longitude': longitude,
//       'Radius': radius,
//     };
//   }

//   @override
//   String toString() {
//     return '{UserID: $userId, GroupId: $groupId, Arrive: $arrive, Leave: $leave, '
//         'Latitude: $latitude, Longitude: $longitude, Radius: $radius, Name: $geofenceName}';
//   }

//   factory GeofenceEntry.fromJson(Map<String, dynamic> json) {
//     return GeofenceEntry(
//       userId: json['UserId'],
//       groupId: json['GroupId'],
//       geofenceName: json['GeofenceName'],
//       arrive: json['Arrive'],
//       leave: json['Leave'],
//       latitude: json['Latitude'],
//       longitude: json['Longitude'],
//       radius: json['Radius'],
//     );
//   }
//   static List<GeofenceEntry> parseGeofenceData(List<dynamic> rawList) {
//     List<GeofenceEntry> entries = [];

//     for (var geo in rawList) {
//       final map = geo as Map<String, dynamic>;
//       final int groupId = map['GroupId'];
//       final String name = map['Name'];
//       final double lat = map['Latitude'].toDouble();
//       final double lng = map['Longitude'].toDouble();
//       final double radius = map['Radius'].toDouble();

//       for (var friend in map['Friends']) {
//         final friendMap = friend as Map<String, dynamic>;
//         entries.add(
//           GeofenceEntry(
//             userId: friendMap['UserId'],
//             groupId: groupId,
//             geofenceName: name,
//             arrive: friendMap['Arrive'],
//             leave: friendMap['Leave'],
//             latitude: lat,
//             longitude: lng,
//             radius: radius,
//           ),
//         );
//       }
//     }

//     return entries;
//   }
// }
