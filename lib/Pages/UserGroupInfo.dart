import 'package:flutter/material.dart';
import 'package:fyp_final/SharedData/UserDetails.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  List<dynamic> groupList = [];

  @override
  void initState() {
    super.initState();
    fetchGroupList(); // Load data on page load
  }

  void fetchGroupList() {
    setState(() {
      groupList = UserData.userGroupDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Groups"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child:
            groupList.isEmpty
                ? const Center(child: Text("No groups found."))
                : ListView.builder(
                  itemCount: groupList.length,
                  itemBuilder: (context, index) {
                    return GroupTile(
                      name: groupList[index]['GroupName'],
                      code: groupList[index]['Group_Code'],
                    );
                  },
                ),
      ),
    );
  }
}

class GroupTile extends StatelessWidget {
  final String name;
  final String code;

  const GroupTile({super.key, required this.name, required this.code});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            const Icon(Icons.group, color: Colors.green, size: 40),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Name : $name",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Code: $code",
                    style: TextStyle(
                      fontSize: 15,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
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
