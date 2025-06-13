import 'package:flutter/material.dart';
import 'package:fyp_final/Service/apiService.dart';
import 'package:fyp_final/SharedData/UserDetails.dart';
import 'package:intl/intl.dart'; // ✅ Required for DateFormat

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    getNotifications();
  }

  bool isLoading = true;
  ApiService apiService = ApiService();
  List<Map<String, dynamic>> listNotification = [];

  Future<void> getNotifications() async {
    try {
      setState(() => isLoading = true);
      await apiService.getUserNotifications();

      setState(() {
        listNotification =
            UserData.userNotifications.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (error, stackTrace) {
      print("Error fetching notifications: $error");
      print(stackTrace);
      setState(() => isLoading = false);
    }
  }

  void toggleReadStatus(int index) {
    setState(() {
      listNotification[index]['Status'] =
          listNotification[index]['Status'] == "unread" ? "read" : "unread";
    });
  }

  String getDate(String d) {
    // Parse to DateTime object
    DateTime dateTime = DateTime.parse(d);

    // Extract date and time separately
    String formattedDate = DateFormat(
      'yyyy-MM-dd',
    ).format(dateTime); // 2025-05-01
    String formattedTime = DateFormat('HH:mm').format(dateTime); // 11:46:31
    return "Date : " + formattedDate + "  " + formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator()) // Show loader
              : listNotification.isEmpty
              ? const Center(child: Text("No notifications found."))
              : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: listNotification.length,
                itemBuilder: (context, index) {
                  final notification = listNotification[index];

                  bool isRead =
                      notification.containsKey('Status') &&
                      notification['Status'] == "read";

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Notification index
                        SizedBox(
                          width: 30,
                          child: Center(
                            child: Icon(
                              Icons.person_2,
                              size: 36,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Notification details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${notification['Type']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),

                              Text(
                                // '${notification['CreatedAt']}',
                                '${getDate(notification['CreatedAt'])}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Read/Unread Icon
                        IconButton(
                          icon: Icon(
                            isRead
                                ? Icons.mark_email_read
                                : Icons.mark_email_unread,
                            color: isRead ? Colors.green : Colors.red,
                          ),
                          onPressed: () => toggleReadStatus(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
