import 'package:flutter/material.dart';
import 'package:fyp_final/Service/apiService.dart';
import 'package:fyp_final/SharedData/UserDetails.dart';

class Addfriendsindividual extends StatefulWidget {
  const Addfriendsindividual({super.key});

  @override
  State<Addfriendsindividual> createState() => _AddfriendsindividualState();
}

class _AddfriendsindividualState extends State<Addfriendsindividual> {
  final TextEditingController _controller = TextEditingController();
  final ApiService apiService = ApiService();
  bool isLoading = false;

  Future<void> _handleSubmit() async {
    String email = _controller.text.trim();
    print("Email: $email");

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter User Email.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String res = await apiService.addIndividualFriends(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${res}")),
      );
      _controller.clear(); // Optionally clear input
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Add Friends",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.25,
              child: Image.asset('assets/group.jpg', fit: BoxFit.contain),
            ),
            const SizedBox(height: 30),
            const Text(
              "Enter the user's email to send a friend request.",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "If You Don't Have One, Ask Your Friend!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF169A70),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                )
                    : const Text(
                  "Send Request",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
