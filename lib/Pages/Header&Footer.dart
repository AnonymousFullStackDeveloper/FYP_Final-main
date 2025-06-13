import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as badges;
import 'package:fyp_final/Pages/AccountScreen.dart';
import 'package:fyp_final/Pages/HomeScreen.dart';
import 'package:fyp_final/Pages/IndividualScreen.dart';
import 'package:fyp_final/Pages/LocationsScreen.dart';
import 'package:fyp_final/Pages/NotificationScreen.dart';
import 'package:fyp_final/Pages/GroupPage.dart';
import 'package:fyp_final/Pages/SettingScreen.dart';
import 'package:fyp_final/Service/apiService.dart';
import 'package:fyp_final/SharedData/PreferencedVariable.dart';
import 'package:fyp_final/SharedData/UserDetails.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:badges/badges.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeaderAndFooter extends StatefulWidget {
  const HeaderAndFooter({super.key});

  @override
  State<HeaderAndFooter> createState() => _HeaderAndFooterState();
}

class _HeaderAndFooterState extends State<HeaderAndFooter> {
  StorageManager storageManager = new StorageManager();

  ApiService apiService = ApiService();
  List<Map<String, dynamic>> listGroup = [];
  int selectedIndex = 0;
  int selectedGroupId = 0;
  String? selectedValue;
  bool isLoading = true;
  int unReadCount = 10;
  bool Individualscreen = true;
  int one = 1;

  @override
  void initState() {
    super.initState();
    getGroups();
  }

  Future<void> getGroups() async {
    try {
      setState(() => isLoading = true);

      await apiService.getGroupDetails();

      List<Map<String, dynamic>> tempList =
          UserData.userGroupDetails.cast<Map<String, dynamic>>();

      String? savedGroupName;
      int? savedGroupId;

      if (tempList.isNotEmpty) {
        selectedGroupId = tempList.first['Group_Id'];
        storageManager.saveSelectedGroupId(
          selectedGroupId,
          tempList.first['GroupName'],
        );

        UserData.selectedGroup = selectedGroupId;

        // Fetch saved group details
        savedGroupName = await storageManager.getSelectedGroupName();
        savedGroupId = await storageManager.getSelectedGroupId();
      }

      // ✅ Update UI state synchronously after async operations
      setState(() {
        listGroup = tempList;
        if (savedGroupName != null && savedGroupId != null) {
          selectedValue = savedGroupName;
          selectedGroupId = savedGroupId;
          UserData.selectedGroup = savedGroupId;
        }
        if (mounted) {
          setState(() {});
        }
        isLoading = false;
      });
    } catch (error, stackTrace) {
      print("Error fetching groups: $error");
      print(stackTrace);
      setState(() => isLoading = false);
    }
  }

  Widget bodyFunction() {
    switch (selectedIndex) {
      case 0:
        setState(() {
          // Individualscreen = true;
        });
        return const DraggableScrollableSheetExample();
      case 1:
        setState(() {
          // Individualscreen = false;
        });
        return const IndividualScreen();
      case 2:
        setState(() {
          // Individualscreen = true;
        });
        return const LocationsScreen();
      case 3:
        setState(() {
          // Individualscreen = true;
        });
        return const Groups();
      case 4:
        setState(() {
          // Individualscreen = true;
        });
        return const AccountPage();
      case 6:
        return Container(color: const Color.fromARGB(255, 134, 135, 54));
      default:
        return Container(color: Colors.white);
    }
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTabletOrLarger = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        title: Container(
          width: isTabletOrLarger ? 350 : 250,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(500),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),

          child: RefreshIndicator(
            onRefresh: () async {
              await getGroups();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    (selectedIndex != 1) && (selectedIndex != 4)
                        ? DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: Text(
                              "Select Group",
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            items:
                                listGroup.map((group) {
                                  return DropdownMenuItem<String>(
                                    value: group['GroupName'].toString(),
                                    child: Text(
                                      group['GroupName'].toString(),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                            value:
                                listGroup.any(
                                      (group) =>
                                          group['GroupName'] == selectedValue,
                                    )
                                    ? selectedValue
                                    : null,
                            onChanged: (String? value) {
                              setState(() {
                                selectedValue = value;

                                String name = value ?? "Select Group";
                                var selectedGroup = listGroup.firstWhere(
                                  (group) => group['GroupName'] == value,
                                  orElse: () => {},
                                );

                                selectedGroupId = selectedGroup['Group_Id'];
                                print("Selected Group Id :${selectedGroupId}");
                                UserData.selectedGroup = selectedGroupId;

                                storageManager.saveSelectedGroupId(
                                  selectedGroupId,
                                  name,
                                );

                                print(
                                  'Selected Group ID: ${UserData.selectedGroup}',
                                );
                              });

                              fetchGroupFriends();
                            },
                            buttonStyleData: const ButtonStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              height: 25,
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                            ),
                          ),
                        )
                        : const SizedBox.shrink(),

                    if (isLoading)
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        centerTitle: true,
        // backgroundColor: Colors.white,
        backgroundColor: Colors.white.withAlpha(0),

        leading: IconButton(
          icon: Icon(
            // selectedIndex == 6 ? Icons.settings : Icons.settings_outlined,
            Icons.settings,
            size: 30,
          ),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingPage()),
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: Colors.black,
              // selectedIndex == 5
              //     ? Icons.notifications
              //     : Icons.notifications_outlined,
              size: 30,
            ),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationPage(),
                  ),
                ),
          ),
        ],
      ),
      body: bodyFunction(),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15.0),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.home_outlined, Icons.home, 0),
            _buildNavItem(Icons.person_outlined, Icons.person, 1),
            _buildNavItem(Icons.location_on_outlined, Icons.location_on, 2),
            _buildNavItem(Icons.group_outlined, Icons.group, 3),
            _buildNavItem(Icons.account_box_outlined, Icons.account_box, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData selectedIcon, int index) {
    return IconButton.filled(
      isSelected: selectedIndex == index,
      icon: Icon(icon, size: 30),
      selectedIcon: Icon(selectedIcon, color: Colors.white, size: 30),
      onPressed: () => onItemTapped(index),
    );
  }

  // Fetch group friends when a group is selected
  void fetchGroupFriends() async {
    print("Fetching group friends for: $selectedValue...");
    // await apiService.getGroupFriends();
    List<dynamic>? friends = await apiService.getGroupFriends();
    if (friends != null) {
      setState(() {
        UserData.userGroupFriends = friends;
      });
      print("Group friends fetched successfully.");
    }
    print("Group friends fetched successfully.");
  }
}
