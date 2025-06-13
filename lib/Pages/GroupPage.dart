import 'package:flutter/material.dart';
import 'package:fyp_final/Pages/AddInGroup.dart';
import 'package:fyp_final/Pages/ShareGroupCode.dart';
import 'package:fyp_final/Service/apiService.dart';
import 'package:fyp_final/SharedData/UserDetails.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:fyp_final/Pages/CreateGroup.dart';

class Groups extends StatefulWidget {
  const Groups({super.key});

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  List<Map<String, dynamic>> groups = [];
  ApiService apiService = ApiService();
  bool isLoading = false;
  bool onceLoad = true;
  @override
  void initState() {
    super.initState();
    if (UserData.userGroupDetails.isEmpty) {
      setState(() {
        onceLoad = false;

        fetchGroupDetails();
      });
    } else {
      setState(() {
        groups = UserData.userGroupDetails.cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> fetchGroupDetails() async {
    setState(() => isLoading = true);
    try {
      List<dynamic> groupData = await apiService.getGroupDetails() ?? [];
      if (mounted) {
        setState(() {
          UserData.userGroupDetails = groupData;
          groups = groupData.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      print("Error fetching group details: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Your Groups",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchGroupDetails,
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : groups.isEmpty
                ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 200),
                    const Center(child: Text("No groups found.")),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddInGroup(),
                                ),
                              );
                            },
                            child: const Text('Add Group'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              var result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateGroup(),
                                ),
                              );
                              if (result == 'reload' && mounted) {
                                fetchGroupDetails();
                              }
                            },
                            child: const Text('Create Group'),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                : Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: SearchableList<Map<String, dynamic>>(
                          initialList: groups,
                          lazyLoadingEnabled: false,
                          sortPredicate:
                              (a, b) => a['Group_Id'].compareTo(b['Group_Id']),
                          itemBuilder: (item) => _buildGroupItem(item),
                          filter:
                              (query) =>
                                  groups.where((group) {
                                    return group['GroupName']
                                            .toLowerCase()
                                            .contains(query.toLowerCase()) ||
                                        group['CreatedAt']
                                            .toLowerCase()
                                            .contains(query.toLowerCase());
                                  }).toList(),
                          inputDecoration: InputDecoration(
                            labelText: "Search Group",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 20,
                        left: 40,
                        right: 40,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddInGroup(),
                                ),
                              );
                            },
                            child: const Text('Add Group'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              var result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateGroup(),
                                ),
                              );
                              if (result == 'reload' && mounted) {
                                fetchGroupDetails();
                              }
                            },
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

  Widget _buildGroupItem(Map<String, dynamic> group) {
    return GestureDetector(
      onTap: () {
        print("${group['Group_Code']}");

        print("${group['GroupName']}");
        setState(() {
          UserData.GroupNameShare = group['GroupName'];
          UserData.GroupShareCode = group['Group_Code'];
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InviteCodeScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.group, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${group['GroupName']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${group['CreatedAt']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
