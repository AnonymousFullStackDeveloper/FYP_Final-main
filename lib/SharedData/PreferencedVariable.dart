import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  Future<void> saveUserSession(
    int userId,
    String name,
    String email,
    password,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('User_ID', userId);
    await prefs.setBool('isLogin', true);
    await prefs.setString('Name', name);
    await prefs.setString('Email', email);
    await prefs.setString('Password', password);
  }

  Future<void> saveSelectedGroupId(int id, String gname) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('GroupId', id);
    await prefs.setString('GroupName', gname);
  }

  Future<bool?> saveBluetoothState(bool isBluetooth) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool('isBluetooth', isBluetooth);
  }

  Future<bool?> getBluetoothState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isBluetooth');
  }

  Future<int?> getSelectedGroupId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('GroupId');
  }

  Future<String?> getSelectedGroupName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('GroupName');
  }

  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLogin') ?? false;
  }

  Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('User_ID');
  }

  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('Name');
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('Email');
  }

  Future<String?> getUserPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('Password');
  }
}
