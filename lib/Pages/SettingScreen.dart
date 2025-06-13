import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp_final/Pages/BluetoothScreen.dart';
import 'package:fyp_final/Pages/UserGroupInfo.dart';
import 'package:fyp_final/SharedData/PreferencedVariable.dart';
import 'package:fyp_final/SharedData/UserDetails.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  StorageManager storageManager = StorageManager();
  late SharedPreferences prefs;
  bool isBluetooth = false; // Default value to avoid null issues

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    bool bluetoothState = await storageManager.getBluetoothState() ?? false;

    setState(() {
      isBluetooth = bluetoothState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(.94),
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            _buildSettingsGroup("General Settings", [
              _buildSettingsItem(
                icon: CupertinoIcons.pencil_outline,
                title: 'Appearance',
                subtitle: "Customize the app theme",
                onTap: () {},
              ),
              _buildSettingsItem(
                icon: Icons.fingerprint,
                title: 'Privacy',
                subtitle: "Enhance security settings",
                iconColor: Colors.white,
                iconBackground: Colors.red,
                onTap: () {},
              ),
              // _buildSettingsItem(
              //   icon: Icons.group,
              //   title: 'Group Management',
              //   subtitle: "Group Settings",
              //   iconColor: Colors.white,
              //   iconBackground: Colors.green,
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => GroupListPage()),
              //     );
              //   },
              // ),
              _buildSettingsItem(
                icon: Icons.bluetooth,
                title: 'Bluetooth',
                subtitle: "Automatic",
                iconColor: Colors.white,
                iconBackground: Colors.blue,
                trailing: Switch.adaptive(
                  value: isBluetooth,
                  onChanged: (bool value) async {
                    setState(() {
                      isBluetooth = value;
                    });
                    await storageManager.saveBluetoothState(isBluetooth);
                  },
                ),
                onTap: () {
                  print("Bluetooth setting clicked!");
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => HomeScreen(),
                  //   ),
                  // );
                },
              ),
              _buildSettingsItem(
                icon: CupertinoIcons.arrow_left_square,
                iconColor: Colors.white,
                iconBackground: Colors.black,
                title: 'Logout',
                subtitle: "Logout From this Device",
                onTap: () async {
                  await prefs.setBool('isLogin', false);
                  StorageManager storageManager = new StorageManager();
                  storageManager.saveUserSession(0, "", "", "");
                  storageManager.saveSelectedGroupId(0, "");
                  UserData.UserId = 0;
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? iconBackground,
    Widget? trailing,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconBackground ?? Colors.grey.shade200,
        child: Icon(icon, color: iconColor ?? Colors.black),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
