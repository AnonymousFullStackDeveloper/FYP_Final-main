import 'package:flutter/material.dart';
import 'package:fyp_final/SharedData/PreferencedVariable.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late String userName;
  late String email;
  late String password;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    getUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> getUserData() async {
    try {
      String fetchedUserName =
          await StorageManager().getUserName() ?? "User Name";
      String fetchedEmail = await StorageManager().getUserEmail() ?? "Email";
      String fetchedPassword =
          await StorageManager().getUserPassword() ?? "Password";

      setState(() {
        userName = fetchedUserName;
        email = fetchedEmail;
        password = fetchedPassword;

        _nameController.text = userName;
        _emailController.text = email;
        _passwordController.text = password;

        isLoading = false; // Data loaded, stop loading
      });
    } catch (error, stackTrace) {
      print("Error fetching User Details in Account Screen: $error");
      print(stackTrace);
      setState(() {
        isLoading = false; // Stop loading even if an error occurs
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Show loading indicator
              : SingleChildScrollView(
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: [
                    Container(
                      height: 200,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -70),
                      child: const CircleAvatar(
                        radius: 71,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.black,
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -60),
                      child: Text(
                        userName, // Updated dynamically
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    buildTextField("Full Name", _nameController),
                    buildTextField("Email", _emailController),
                    buildTextField("Password", _passwordController),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        String name = _nameController.text;
                        String email = _emailController.text;
                        String password = _passwordController.text;

                        print("Updated Name: $name");
                        print("Updated Email: $email");
                        print("Updated Password: $password");
                      },
                      child: const Text(
                        "Update",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
