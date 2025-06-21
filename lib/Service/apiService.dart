// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
//
// class api {
// static const String baseUrl = '192.168.0.117/APIFYP';
//
//
//   Future<List<dynamic>> Login(String username, String password) async {
//     final url = Uri.parse('http://192.168.0.117/APIFYP/User/Login'); // Adjust for emulator/device
//
//     final response = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//       body: jsonEncode({
//         'email': username,
//         'password': password,
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       print('Success: ${response.body}');
//
//       // Parse the response body as a List<dynamic>
//       return jsonDecode(response.body);
//     } else {
//       print('Error: ${response.statusCode}, ${response.body}');
//       return []; // Return an empty list in case of error
//     }
//   }
//
//
//   // POST request
//   Future<bool> Signup(String name, String email, String password) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/User/Signup'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({'name': name, 'email': email,'password':password}),
//     );
//
//     return response.statusCode == 200;
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fyp_final/Model/GeofenceFriends.dart';
import 'package:fyp_final/Model/UserGroupGeofence.dart';
import 'package:fyp_final/SharedData/PreferencedVariable.dart';
import 'package:fyp_final/SharedData/UserDetails.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  late SharedPreferences prefs;
  // static const String baseUrl = 'https://localhost:44350';
  static String baseUrl = UserData.getUrl();

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/User/Login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      print('Login Success: ${response.body}');

      // Decode JSON before returning
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      print('Login Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to login');
    }
  }

  // Future<Map<String, dynamic>?> getAllUserDetails() async {
  //   await init(); // Ensure prefs is initialized

  //   final url = Uri.parse(
  //     '${baseUrl}/User/GetAllDetails/${prefs.getInt('User_ID')}',
  //   );

  //   try {
  //     final response = await http.get(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     print('User Id : ${prefs.getInt('User_ID')}');
  //     print('Response Code: ${response.statusCode}');
  //     print('Response Body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> responseData = jsonDecode(response.body);

  //       // Extract user groups
  //       UserData.userGroups = List<Map<String, dynamic>>.from(
  //         responseData['UserDetails']['groupMembers'],
  //       );

  //       // Extract group IDs
  //       UserData.userGroupIds =
  //           UserData.userGroups.map((item) => item['GroupId'] as int).toList();

  //       print("User Group Ids: ${UserData.userGroupIds}");

  //       // ✅ Fetch group details using Future.wait()
  //       List<Map<String, dynamic>> userGroups = await Future.wait(
  //         UserData.userGroupIds.map((id) async {
  //           final url = Uri.parse('${baseUrl}/Group/GetById/$id');

  //           final response = await http.get(
  //             url,
  //             headers: {'Content-Type': 'application/json'},
  //           );

  //           if (response.statusCode == 200) {
  //             return jsonDecode(response.body) as Map<String, dynamic>;
  //           } else {
  //             print("Error fetching group $id: ${response.statusCode}");
  //             return {}; // Return empty object on failure
  //           }
  //         }),
  //       );

  //       // ✅ Assign the populated list correctly
  //       UserData.userGroupDetails = userGroups;

  //       print("User Group Details: ${UserData.userGroupDetails}");

  //       return responseData; // Return parsed JSON object
  //     } else {
  //       print('Error: ${response.statusCode}, ${response.body}');
  //       return null; // Handle API failure
  //     }
  //   } catch (e) {
  //     print('Exception: $e');
  //     return null;
  //   }
  // }

  // Future<void> addGeofenceEntry(GeofenceEntry entry) async {
  //   String apiUrl = '$baseUrl/GeoFence/AddGeofence';

  //   try {
  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(entry.toJson()),
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       print('✅ Geofence entry added successfully!');
  //     } else {
  //       print('❌ Failed to add geofence: ${response.statusCode}');
  //       print('Response: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('❌ Error while adding geofence: $e');
  //   }
  // }

  Future<List<dynamic>?> getGroupDetails() async {
    StorageManager storageManager = StorageManager();
    try {
      final userId = await storageManager.getUserId();
      print("User Id :  ${userId.toString()}");
      final url = Uri.parse(
        '$baseUrl/GroupMember/GetByUserId/${int.parse(userId.toString())}',
      );

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      print("Groups Details ${response.body}");

      if (response.statusCode == 200) {
        UserData.userGroupDetails = jsonDecode(response.body);

        return jsonDecode(response.body);
      } else {
        print("Error fetching groups: ${response.statusCode}");
        return null; // Return null on failure
      }
    } catch (e) {
      print("Exception occurred:While Getting Groups $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getGroupFriends() async {
    await init(); // Ensure prefs is initialized
    StorageManager storageManager = StorageManager();
    int? id = await storageManager.getSelectedGroupId();
    int uid = UserData.UserId;
    print("Selected Group In : ${id}");

    final url = Uri.parse('$baseUrl/GroupMember/GetByGroupId?gId=$id&uid=$uid');
    print(UserData.selectedGroup);

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('Response Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        // Ensure the response is a list of maps
        List<Map<String, dynamic>> groupFriends =
            responseData.cast<Map<String, dynamic>>();

        UserData.userGroupFriends = groupFriends;

        print("Group Friends Details: $groupFriends");

        return groupFriends;
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: While Getting Group Friends $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getUserLocations() async {
    await init(); // Ensure prefs is initialized
    StorageManager storageManager = StorageManager();

    final userId = await storageManager.getUserId();
    print("User Id Location  : $userId");

    if (userId == null) {
      print("Error: User ID is null or empty");
      return null;
    }

    final url = Uri.parse(
      '$baseUrl/Location/GetByUserId/${int.parse(userId.toString())}',
    );

    print("Selected Group: ${UserData.selectedGroup ?? "No Group Selected"}");

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print("Warning: Empty response body");
          return [];
        }

        final dynamic responseData = jsonDecode(response.body);

        if (responseData is! List) {
          print("Error: API response is not a List");
          return null;
        }

        List<Map<String, dynamic>> userLocation =
            responseData.cast<Map<String, dynamic>>();

        UserData.userLocationDetails = userLocation;

        print("User Location Details: $userLocation");

        return userLocation;
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: While Getting User Locations details $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getUserNotifications() async {
    await init(); // Ensure prefs is initialized
    StorageManager storageManager = StorageManager();
    final userId = await storageManager.getUserId();

    print("User Id  : ${userId}");

    final url = Uri.parse(
      '$baseUrl/Notification/GetByUserId/${int.parse(userId.toString())}',
    );
    print(UserData.selectedGroup);

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('Response Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        // Ensure the response is a list of maps
        List<Map<String, dynamic>> userNotification =
            responseData.cast<Map<String, dynamic>>();

        UserData.userNotifications = userNotification;

        print("User Notification Details: $userNotification");

        return userNotification;
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print(
        'Exception: While Getting User Notification details In ApiService $e',
      );
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getUserIndividualFriends() async {
    await init(); // Ensure prefs is initialized
    StorageManager storageManager = StorageManager();
    final userId = await storageManager.getUserId();

    print("User Id  : ${userId}");

    final url = Uri.parse(
      '$baseUrl/UserFriend/GetFriendsDetailByUserId/${int.parse(userId.toString())}',
    );
    print(UserData.selectedGroup);

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('Response Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        // Ensure the response is a list of maps
        List<Map<String, dynamic>> userfriends =
            responseData.cast<Map<String, dynamic>>();

        UserData.userNotifications = userfriends;

        print("User Individual Friends  Details: $userfriends");

        return userfriends;
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print(
        'Exception: While Getting User Individual Frinds details In ApiService $e',
      );
      return null;
    }
  }

  // Signup Method (Fixed)
  Future<bool> signup(String name, String email, String password) async {
    // final url = Uri.parse('$baseUrl/User/Signup');
    final url = Uri.parse('$baseUrl/User/Signup');

    final response = await http.post(
      url,

      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'email': email, 'password': password}),
    );
    String c = response.body.toString();
    // print();
    if (c.contains("True")) {
      return true;
    }

    return false;
  }

  Future<bool> addGroupMember({
    required int userId,
    required String groupCode,
    required String role,
  }) async {
    String apiUrl =
        "$baseUrl/GroupMember/AddGroupMember"; // Replace with your actual endpoint

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'User_Id': userId,
          'Group_Code': groupCode,
          'Role': role,
        }),
      );

      if (response.statusCode == 200) {
        print("Member added successfully.");
        return true;
      } else {
        print("Failed to add member. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error while adding member: $e");
      return false;
    }
  }

  Future<String> addUserLocation(String name, double lat, double long) async {
    StorageManager storageManager = StorageManager();
    final userId = await storageManager.getUserId();
    final url = Uri.parse('$baseUrl/Location/AddData');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'UserId': userId,
        'Name': name,
        'Latitude': lat,
        'Longitude': long,
        'Timestamp': "0",
      }),
    );
    print(response.body);

    if (response.statusCode == 200) {
      print('Data Success Added: ${response.body}');

      // Decode JSON before returning
      return jsonDecode(response.body.toString());
    } else {
      print(' Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to Add Data in Location Table ');
    }
  }

  Future<String> createNewUserGroup(
    String name,
    bool isPrivate,
    String groupCode,
  ) async {
    StorageManager storageManager = StorageManager();
    final userId = await storageManager.getUserId();
    final url = Uri.parse('$baseUrl/Group/CreateUserGroup');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'Group_Id': userId,
        'GroupName': name,
        'IsPrivate': isPrivate,
        'Group_Code': groupCode,
        'CreatedAt': "0",
      }),
    );
    print(response.body);

    if (response.statusCode == 200) {
      print('Data Success Added: ${response.body}');

      // Decode JSON before returning
      return response.body.toString();
    } else {
      print(' Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to Create Group in APiService ');
    }
  }

  Future<List<GeofenceEntity>> fetchGeofencesByUserId(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/GeoFence/GetAllByUser/$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      return GeofenceEntity.parseGeofenceData(data);
    } else {
      throw Exception('Failed to load geofences');
    }
  }

  Future<http.Response> deleteGeofenceById(int gId) async {
    final url = Uri.parse('$baseUrl/GeoFence/Delete/$gId');

    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print("Delted");
      return response;
    } else {
      print("${response.statusCode} ${response.body}");
      throw Exception('Failed to delete geofence with ID $gId');
    }
  }

  Future<int> addGeofenceEntity(GeofenceEntity geofence) async {
    final jsonBody = json.encode(geofence.toJson());

    final response = await http.post(
      Uri.parse('$baseUrl/GeoFence/AddData'),
      headers: {'Content-Type': 'application/json'},
      body: jsonBody,
    );

    if (response.statusCode == 200) {
      print('Geofence added successfully!');
      
      return response.statusCode;
    } else {
      print('Failed to add geofence. ${response.body}');
      return response.statusCode;
    }
  }



  Future<String> addIndividualFriends(
     String email
  ) async {
    final Map<String, dynamic> requestBody = {
      "email": email,
      "status": "Pending",
      "permission": "DisAllow",
      "userId": UserData.UserId,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/UserFriend/SendRequestUsingEmail'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      print('Friend request sent successfully!');
      return response.body.toString();
    } else {
      print('Failed to send friend request. ${response.body}');
      return response.body.toString();
    }
  }

}
