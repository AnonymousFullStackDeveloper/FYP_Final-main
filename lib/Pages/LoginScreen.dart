import 'package:flutter/material.dart';
import 'package:fyp_final/SharedData/PreferencedVariable.dart';
import 'package:fyp_final/SharedData/UserDetails.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../Service/apiService.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isTermsChecked = false;
  bool isPasswordVisible = false;
  bool isLoading = false;
  final StorageManager storageManager = StorageManager();
  final ApiService apiService = ApiService();
  // late List<dynamic> data = [];
  late Map<String, dynamic> data;

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    try {
      var result = await apiService.login(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );

      print("API Response: $result"); // Debugging

      setState(() {
        data = result; // No need to decode again

        int userId = data['User_Id'] ?? 0;
        UserData.UserId = userId;
        String userName = data['Name'] ?? "Unknown";
        String email = data['Email'] ?? "Unknown";
        String password = data['Password'] ?? "Unknown";

        print("User Name: $userName");

        if (userId != 0) {
          storageManager.saveUserSession(userId, userName, email, password);
          Navigator.pushNamed(context, '/layout');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Welcome! $userName')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid login credentials.')),
          );
        }
      });
    } catch (e) {
      print("Error: $e"); // Debugging
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Scaffold(
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: screenHeight * 0.2,
                        ), // 15% of screen height

                        const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * 0.08,
                        ), // 8% of screen height
                        // Username Field
                        TextField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),

                        // Password Field
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(
                                  () => isPasswordVisible = !isPasswordVisible,
                                );
                              },
                            ),
                          ),
                          obscureText: !isPasswordVisible,
                        ),
                        SizedBox(height: screenHeight * 0.01),

                        // Terms Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: isTermsChecked,
                              onChanged: (bool? newValue) {
                                setState(
                                  () => isTermsChecked = newValue ?? false,
                                );
                              },
                            ),
                            const Flexible(
                              child: Text(
                                'I agree to the terms and conditions',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Sign Up Text
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.left,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              GestureDetector(
                                onTap:
                                    () =>
                                        Navigator.pushNamed(context, '/signup'),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.20),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: screenHeight * 0.07, // 7% of screen height
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF169A70),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed:
                                isLoading
                                    ? null
                                    : () {
                                      if (usernameController.text.isEmpty ||
                                          passwordController.text.isEmpty ||
                                          !isTermsChecked) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Please fill in all fields and accept terms',
                                            ),
                                          ),
                                        );
                                      } else {
                                        fetchData();
                                        // Navigator.pushNamed(context, '/layout');
                                      }
                                    },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.05),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Loading Overlay
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: LoadingAnimationWidget.twistingDots(
                leftDotColor: const Color(0xFF1A1A3F),
                rightDotColor: const Color(0xFFEA3799),
                size: 100,
              ),
            ),
          ),
      ],
    );
  }
}
