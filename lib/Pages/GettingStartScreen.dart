import 'package:flutter/material.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // 5% padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SizedBox(height: screenHeight * 0.1), // 10% of screen height

            // Title
            // const Text(
            //   "Get Start",
            //   textAlign: TextAlign.center,
            //   style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            // ),

            SizedBox(height: screenHeight * 0.2), // 5% of screen height

            // Image
            SizedBox(
              height: screenHeight * 0.5,
              width: screenWidth * 1,
              child: Image.asset(
                'assets/illustration.png',
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: screenHeight * 0.08), // 5% of screen height

            Text("Friend Locator With History",style: TextStyle(
              fontWeight: FontWeight.bold,fontSize: 25
            ),),

            // SizedBox(height: screenHeight * 0.01), // 5% of screen height

            // Spacer pushes button to bottom if space is available
            const Spacer(),

            // Button
            SizedBox(
              width: double.infinity, // Full width
              height: screenHeight * 0.07, // 7% of screen height
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF169A70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text(
                  "Get Started!",
                  style: TextStyle(
                    color: Colors.white,
                    // backgroundColor: Color.from(alpha: 1, red: 22, green: 154, blue: 112),
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                  ),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.05), // Bottom spacing
          ],
        ),
      ),
    );
  }
}
