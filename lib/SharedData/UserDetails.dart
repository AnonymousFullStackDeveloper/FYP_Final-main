import 'package:fyp_final/Model/GeofenceFriends.dart';

class UserData {
  static List<dynamic> userGroupFriends = [];

  static List<dynamic> userGroupDetails = [];

  static int selectedGroup = 0;

  static double sheetPosition = 0.35;

  static List<Map<String, dynamic>> userLocationDetails = [];
  static List<Map<String, dynamic>> userNotifications = [];
  static List<Map<String, dynamic>> userInidividualFriends = [];
  static List<dynamic> userInidividualFriendsLiveLocation = [];
  static List<dynamic> userGroupFriendsLiveLocation = [];

  static double latitudeGeofence = 0;
  static double longitudeGeofence = 0;

  static String GroupShareCode = "";
  static String GroupNameShare = "";

  static List<GeofenceEntity> UserGeofenceDetails = [];

  static List<GeofenceFriend> selectedFriends = [];
  static late GeofenceEntity SelectedGeofenceEntity;



  static String localGroupCode="";

  static bool isUpdateGeofenec = false;

  static String selectedTripUserName = "";
  static int selectedUserIdForLocationHistory = 0;

  static String getUrl() {
    return "http://192.168.1.19";
  }


  static int UserId = 0;

  // static String URL = "http://192.168.0.109";
}
