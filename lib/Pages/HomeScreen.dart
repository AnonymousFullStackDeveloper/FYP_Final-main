import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fyp_final/Pages/Map.dart';
import 'package:fyp_final/Pages/Testing.dart';
import 'package:fyp_final/Pages/UserLocationHistory.dart';
import 'package:fyp_final/Service/apiService.dart';
import 'package:fyp_final/SharedData/PreferencedVariable.dart';
import 'package:fyp_final/SharedData/UserDetails.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class DraggableScrollableSheetExampleApp extends StatelessWidget {
  const DraggableScrollableSheetExampleApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade100),
      ),

      home: const DraggableScrollableSheetExample(),
    );
  }
}

class DraggableScrollableSheetExample extends StatefulWidget {
  const DraggableScrollableSheetExample({super.key});

  @override
  State<DraggableScrollableSheetExample> createState() =>
      _DraggableScrollableSheetExampleState();
}

class _DraggableScrollableSheetExampleState
    extends State<DraggableScrollableSheetExample> {
  ApiService apiService = ApiService();
  bool isLoading = true;
  final double _dragSensitivity = 600;
  bool isTrackingAllowed1 = true;
  StorageManager storageManager = StorageManager();
  int? currentUserId = UserData.UserId; // Stores the logged-in user ID
  bool onceLoad = true;
  List<dynamic> friendList = [];
  @override
  void initState() {
    super.initState();
    if (UserData.userGroupFriends.isEmpty) {
      setState(() {
        _loadUserId();
        getUserFriendsInGroup();
      });
    } else {
      setState(() {
        isLoading = false;
        friendList = UserData.userGroupFriends;
      });
    }
  }

  Future<void> _loadUserId() async {
    currentUserId = await storageManager.getUserId();
    UserData.UserId = currentUserId!;
    setState(() {}); // Refresh UI after getting user ID
  }

  Future<void> hasInternetAccess() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        print("✅ Internet Access");
      } else {
        print("⚠️ Response but not 200: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ No Internet: $e");
    }
  }

  Future<void> getUserFriendsInGroup() async {
    setState(() => isLoading = true);

    try {
      final List<dynamic>? friends = await apiService.getGroupFriends();
      setState(() {
        UserData.userGroupFriends = friends ?? [];
        friendList = UserData.userGroupFriends;
      });
    } catch (error, stackTrace) {
      print("Error fetching group friends: $error");
      print(stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch friends. Please try again.")),
      );

      // You could optionally show a snackbar or toast here
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double maxSheetSize = screenHeight / screenHeight; // Typically 1.0

    return Scaffold(
      body: Stack(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: UserData.sheetPosition > 0.9 ? 1.0 : 1.0,
            child: Center(
              child: Column(
                children: [
                  Container(
                    height: 650.0,
                    alignment: Alignment.center,
                    child: LiveLocationApp2(),
                  ),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: UserData.sheetPosition,
            minChildSize: 0.3,
            maxChildSize: maxSheetSize,
            builder: (context, scrollController) {
              return GestureDetector(
                onVerticalDragUpdate: (details) {
                  setState(() {
                    UserData.sheetPosition -=
                        details.delta.dy / _dragSensitivity;
                    UserData.sheetPosition = UserData.sheetPosition.clamp(
                      0.3,
                      maxSheetSize,
                    );
                  });
                },
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: RefreshIndicator(
                    onRefresh: getUserFriendsInGroup,
                    child: CustomScrollView(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: <Widget>[
                        // Header section
                        SliverToBoxAdapter(
                          child: Column(
                            children: <Widget>[
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
                                        setState(() {
                                          isTrackingAllowed1 = value;
                                          // hasInternetAccess();
                                          print(
                                            "Home Screen Me Tracking : $isTrackingAllowed1",
                                          );
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(color: Colors.black),
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
                                      "Names",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Group Friends",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
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

                        // Content section
                        if (isLoading)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else
                          Builder(
                            builder: (context) {
                              // Filter the list outside of the builder
                              List<dynamic> filteredFriends =
                                  UserData.userGroupFriends
                                      .where(
                                        (friend) =>
                                            friend["User_Id"] !=
                                            UserData.UserId,
                                      )
                                      .toList();

                              if (filteredFriends.isEmpty) {
                                return const SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Center(
                                    child: Text("No friends found."),
                                  ),
                                );
                              }

                              return SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  var friend = filteredFriends[index];
                                  String id = friend["User_Id"].toString();
                                  String friendName =
                                      friend["Name"]?.toString() ?? "Unknown";
                                  Color friendColor =
                                      Colors.primaries[friendName.hashCode %
                                          Colors.primaries.length];

                                  return FriendTile(
                                    id: id,
                                    friendName: friendName,
                                    friendColor: friendColor,
                                    friendEmail: friend["Email"] ?? "No email",
                                  );
                                }, childCount: filteredFriends.length),
                              );
                            },
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

  bool get _isOnDesktopAndWeb {
    return kIsWeb ||
        {
          TargetPlatform.macOS,
          TargetPlatform.linux,
          TargetPlatform.windows,
        }.contains(defaultTargetPlatform);
  }
}

class FriendTile extends StatefulWidget {
  final String id;
  final String friendName;
  final Color friendColor;
  final String friendEmail;

  const FriendTile({
    super.key,
    required this.id,
    required this.friendName,
    required this.friendColor,
    required this.friendEmail,
  });

  @override
  State<FriendTile> createState() => _FriendTileState();
}

class _FriendTileState extends State<FriendTile> {
  bool isTrackingAllowed = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: widget.friendColor,
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
            onChanged: (value) => setState(() => isTrackingAllowed = value),
          ),
          onTap: () {
            // Handle your tap event here
            print('User Timeline Clicked! ${widget.id}');
            setState(() {
              UserData.selectedTripUserName = widget.friendName;
              UserData.selectedUserIdForLocationHistory = int.parse(
                widget.id.toString(),
              );
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TripsListPage()),
            );
            // You can also call a function or navigate somewhere
          },
        ),
        const Divider(color: Colors.black),
      ],
    );
  }
}
