import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fyp_final/Pages/AddFriendsIndividual.dart';
import 'package:fyp_final/Pages/AddInGroup.dart';
import 'package:fyp_final/Pages/Map.dart';
import 'package:fyp_final/Pages/UserLocationHistory.dart';
import 'package:fyp_final/Service/apiService.dart';
import 'package:fyp_final/SharedData/PreferencedVariable.dart';
import 'package:fyp_final/SharedData/UserDetails.dart';
import 'package:fyp_final/Pages/Testing.dart'; // Contains LiveLocationScreen

class IndividualScreen extends StatefulWidget {
  const IndividualScreen({super.key});

  @override
  State<IndividualScreen> createState() => _IndividualScreenState();
}

class _IndividualScreenState extends State<IndividualScreen> {
  double _sheetPosition = 0.35;
  final double _dragSensitivity = 600;
  bool isTrackingAllowed1 = true;
  ApiService apiService = ApiService();
  bool isLoading = true;
  final String targetUserId = "123"; // User ID to exclude
  bool onceload = true;
  List<Map<String, dynamic>> friendList = [];
  @override
  void initState() {
    super.initState();
    if (UserData.userInidividualFriends.isEmpty) {
      getUserFriends();
    } else {
      setState(() {
        isLoading = false;
        friendList = UserData.userInidividualFriends;
      });
    }
  }

  Future<List<Map<String, dynamic>>> getUserFriends() async {
    StorageManager manager = StorageManager();
    List<Map<String, dynamic>> result = [];

    try {
      setState(() => isLoading = true);

      int? userId = await manager.getUserId(); // await if it's async
      List<Map<String, dynamic>>? friends =
          await apiService.getUserIndividualFriends();

      if (friends != null) {
        result =
            friends.where((friend) => friend["User_Id"] != userId).toList();

        setState(() {
          UserData.userInidividualFriends = result;
          friendList = UserData.userInidividualFriends;

          isLoading = false;
        });

        print("User Individual Friends : $result");
      } else {
        setState(() => isLoading = false);
      }
    } catch (error, stackTrace) {
      print("Error fetching User friends: $error");
      print(stackTrace);
      setState(() => isLoading = false);
    }

    return result;
  }

  Future<void> _refreshFriends() async {
    await getUserFriends();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double appBarHeight = kToolbarHeight; // Default AppBar height
    // maxSheetSize is set to ensure the sheet doesn't exceed available space
    final double maxSheetSize = screenHeight / screenHeight;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background Live Location Map
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _sheetPosition > 0.9 ? 1.0 : 1.0,
            child: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: LiveLocationApp(),
            ),
          ),
          // Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: _sheetPosition,
            minChildSize: 0.3,
            maxChildSize: maxSheetSize,
            builder: (context, scrollController) {
              return GestureDetector(
                onVerticalDragUpdate: (details) {
                  setState(() {
                    _sheetPosition -= details.delta.dy / _dragSensitivity;
                    _sheetPosition = _sheetPosition.clamp(0.3, maxSheetSize);
                  });
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await getUserFriends();
                    },
                    child: CustomScrollView(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: <Widget>[
                        // Header Section
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              // User Info & Toggle Tracking
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.person_2,
                                          size: 36,
                                          color: Colors.black,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Me",
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Switch(
                                      value: isTrackingAllowed1,
                                      onChanged: (value) {
                                        setState(
                                          () => isTrackingAllowed1 = value,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(color: Colors.black),

                              // Column Titles
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text(
                                      "Name",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Tracking",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(color: Colors.black),
                            ],
                          ),
                        ),

                        // Friends List Section
                        if (isLoading)
                          SliverFillRemaining(
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (friendList.isEmpty)
                          SliverFillRemaining(
                            child: Center(
                              child: ElevatedButton(
                                onPressed: () async {
                                  var result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const Addfriendsindividual(),
                                    ),
                                  );
                                },
                                child: const Text('Add Friend'),
                              ),
                            ),
                          )
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                var friend = friendList[index];

                                int uid = friend['id'];
                                String friendName = friend["name"];
                                bool isFriendTrackingAllowed =
                                    friend["Permission"] == "Allow";
                                return FriendTile(
                                  id: uid,
                                  friendName: friendName,
                                  isTrackingAllowed: isFriendTrackingAllowed,
                                );
                              },
                              childCount:
                                  UserData.userInidividualFriends.length,
                            ),
                          ),

                        // Bottom Button wrapped in SliverToBoxAdapter
                        SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  var result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const Addfriendsindividual(),
                                    ),
                                  );
                                },
                                child: const Text('Add Friend'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool get _isOnDesktopAndWeb =>
      kIsWeb ||
      {
        TargetPlatform.macOS,
        TargetPlatform.linux,
        TargetPlatform.windows,
      }.contains(defaultTargetPlatform);
}

// Friend Tile Widget
class FriendTile extends StatefulWidget {
  final int id;
  final String friendName;
  final bool isTrackingAllowed;

  const FriendTile({
    super.key,
    required this.id,
    required this.friendName,
    required this.isTrackingAllowed,
  });

  @override
  State<FriendTile> createState() => _FriendTileState();
}

class _FriendTileState extends State<FriendTile> {
  late bool isTrackingAllowed;

  @override
  void initState() {
    super.initState();
    isTrackingAllowed = widget.isTrackingAllowed;
  }

  @override
  Widget build(BuildContext context) {
    Color friendColor =
        Colors.primaries[widget.friendName.hashCode.abs() %
            Colors.primaries.length];

    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: friendColor,
            child: Text(
              widget.friendName.isNotEmpty
                  ? widget.friendName[0].toUpperCase()
                  : "?",
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          title: Text(widget.friendName, style: const TextStyle(fontSize: 18)),
          trailing: Switch(
            value: isTrackingAllowed,
            onChanged: (value) {
              setState(() {
                isTrackingAllowed = value;
              });
            },
          ),
          onTap: () {
            print('User Timeline Clicked!${widget.id}');
            setState(() {
              // Uncomment and modify as needed:
              UserData.selectedTripUserName = widget.friendName;
              UserData.selectedUserIdForLocationHistory = int.parse(
                widget.id.toString(),
              );
            });

            // Uncomment if you want to navigate
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TripsListPage()),
            );
          },
        ),
        const Divider(color: Colors.black),
      ],
    );
  }
}
