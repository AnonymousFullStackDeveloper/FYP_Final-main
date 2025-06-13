import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fyp_final/Pages/ShareGroupCode.dart';
import 'package:fyp_final/Service/apiService.dart';
import 'package:fyp_final/SharedData/UserDetails.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key});

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  ApiService apiService = new ApiService();
  String groupName = '';
  bool isPrivate = false; // Default to public

  String generateUniqueCode(int length) {
    const String letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    Random random = Random();

    List<String> availableLetters = letters.split(
      '',
    ); // Convert to list for easy removal
    availableLetters.shuffle(random); // Shuffle to randomize order

    return availableLetters.take(length).join(); // Pick first `length` letters
  }

  bool isLoading = true;
  Future<void> creategroupuser(String gname, bool isP, String gcode) async {
    try {
      setState(() => isLoading = true);
      String data = await apiService.createNewUserGroup(gname, isP, gcode);
      if (data.contains('Group and Member')) {
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (error, stackTrace) {
      print("Error fetching Creating Group: $error");
      print(stackTrace);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Creating Group"),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.check, color: Colors.green),
          //   onPressed: groupName.isNotEmpty
          //       ? () {
          //     // Handle save action
          //     print("Group Name: $groupName, Visibility: ${isPublic ? 'Public' : 'Private'}");
          //   }
          //       : null, // Disable when groupName is empty
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Group Name",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter group name",
              ),
              onChanged: (value) {
                setState(() {
                  groupName = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              "Privacy",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isPrivate = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPrivate ? Colors.white : Colors.blue,
                    ),
                    child: Text("Public"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isPrivate = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !isPrivate ? Colors.white : Colors.blue,
                    ),
                    child: Text("Private"),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed:
                        groupName.isNotEmpty
                            ? () {
                              // Navigator.pushReplacementNamed(
                              //   context,
                              //   '/groups',
                              // );

                              String code = generateUniqueCode(7);

                              creategroupuser(groupName, isPrivate, code);
                              print(
                                "Group Name : $groupName Group Code : $code IsPrivate : $isPrivate",
                              );
                              apiService.getGroupDetails();

                              setState(() {
                                UserData.GroupNameShare = groupName;
                                UserData.GroupShareCode = code;

                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InviteCodeScreen(),
                                ),
                              );

                              // Navigator.pop(context, 'reload');
                            }
                            : null, // Disable when groupName is empty
                    child: const Text('Create Group'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
