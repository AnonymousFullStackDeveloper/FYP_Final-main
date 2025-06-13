import 'package:flutter/material.dart';
import 'package:fyp_final/Service/apiService.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController uname = TextEditingController();
  final TextEditingController emailPhone = TextEditingController();
  final TextEditingController passCode = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isTermsAccepted = false;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  void _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isTermsAccepted) {
      _showPopup("Error", "Please accept the terms and conditions");
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success = await _apiService.signup(
        uname.text.trim(),
        emailPhone.text.trim(),
        passCode.text.trim(),
      );

      if (success) {
        _showPopup("Success", "Sign up successful!", isSuccess: true);
      } else {
        _showPopup("Failed", "Signup failed, Please try again.");
      }
    } catch (e) {
      _showPopup("Error", "An error occurred: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showPopup(String title, String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (isSuccess) Navigator.pushNamed(context, '/login');
                },
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.17),
                  const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: screenHeight * 0.06),
                  TextFormField(
                    controller: uname,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'Please enter your username'
                                : null,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextFormField(
                    controller: emailPhone,
                    decoration: const InputDecoration(
                      labelText: 'Email or Phone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your email or phone';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value) &&
                          !RegExp(r'^\d{10}$').hasMatch(value)) {
                        return 'Enter a valid email or phone number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextFormField(
                    controller: passCode,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed:
                            () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible,
                            ),
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'Please enter a password'
                                : (value.length < 6)
                                ? 'Password must be at least 6 characters'
                                : null,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      Checkbox(
                        value: _isTermsAccepted,
                        onChanged:
                            (value) => setState(
                              () => _isTermsAccepted = value ?? false,
                            ),
                      ),
                      const Expanded(
                        child: Text(
                          'I agree to the Terms and Conditions',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "I have an account? ",
                          style: TextStyle(fontSize: 16),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.17),
                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.07,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF169A70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
