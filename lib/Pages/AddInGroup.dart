import 'package:flutter/material.dart';
import 'package:fyp_final/Service/apiService.dart';
import 'package:fyp_final/SharedData/UserDetails.dart';

class AddInGroup extends StatefulWidget {
  const AddInGroup({super.key});

  @override
  State<AddInGroup> createState() => _AddInGroupState();
}

class _AddInGroupState extends State<AddInGroup> {
  final TextEditingController _controller = TextEditingController();
  final ApiService apiService = ApiService();
  bool isLoading = false;

  Future<void> _handleSubmit() async {
    String groupCode = _controller.text.trim();

    if (groupCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a group code.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    bool success = await apiService.addGroupMember(
      userId: UserData.UserId,
      groupCode: groupCode,
      role: "Member",
    );

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Successfully joined the group!"
              : "Failed to join group. Please check the code.",
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      Navigator.pop(context); // Optionally go back or redirect
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Add In Group",
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
              "Enter Your Group Joining Code",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Group Code",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "If You Don't Have One, Ask Your Group Admin!",
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
                child:
                    isLoading
                        ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                        : const Text(
                          "Join Group",
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

// import 'package:flutter/material.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';

// class JoinCircleScreen extends StatefulWidget {
//   @override
//   _JoinCircleScreenState createState() => _JoinCircleScreenState();
// }

// class _JoinCircleScreenState extends State<JoinCircleScreen> {
//   String part1 = '';
//   String part2 = '';
//   bool get isCodeComplete => part1.length == 3 && part2.length == 3;

//   void _submitCode() {
//     if (isCodeComplete) {
//       String fullCode = '$part1-$part2';
//       print('Submitted code: $fullCode');
//       // Add your join logic here
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Join a Circle"),
//         leading: BackButton(),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(25.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),
//             const Text(
//               "Enter the invite code",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 Expanded(
//                   child: PinCodeTextField(
//                     appContext: context,
//                     length: 3,
//                     autoFocus: true,
//                     keyboardType: TextInputType.text,
//                     animationType: AnimationType.fade,
//                     pinTheme: PinTheme(
//                       shape: PinCodeFieldShape.box,
//                       borderRadius: BorderRadius.circular(8),
//                       fieldHeight: 50,
//                       fieldWidth: 50,
//                       activeFillColor: Colors.purple.shade100,
//                       selectedFillColor: Colors.white,
//                       inactiveFillColor: Colors.white,
//                       inactiveColor: Colors.grey.shade400,
//                       activeColor: Colors.purple,
//                       selectedColor: Colors.purple,
//                     ),
//                     animationDuration: Duration(milliseconds: 300),
//                     enableActiveFill: true,
//                     onChanged: (value) {
//                       setState(() {
//                         part1 = value;
//                       });
//                     },
//                   ),
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 4),
//                   child: Text('-', style: TextStyle(fontSize: 24)),
//                 ),
//                 Expanded(
//                   child: PinCodeTextField(
//                     appContext: context,
//                     length: 3,
//                     keyboardType: TextInputType.text,
//                     animationType: AnimationType.fade,
//                     pinTheme: PinTheme(
//                       shape: PinCodeFieldShape.box,
//                       borderRadius: BorderRadius.circular(8),
//                       fieldHeight: 50,
//                       fieldWidth: 50,
//                       activeFillColor: Colors.purple.shade100,
//                       selectedFillColor: Colors.white,
//                       inactiveFillColor: Colors.white,
//                       inactiveColor: Colors.grey.shade400,
//                       activeColor: Colors.purple,
//                       selectedColor: Colors.purple,
//                     ),
//                     animationDuration: Duration(milliseconds: 300),
//                     enableActiveFill: true,
//                     onChanged: (value) {
//                       setState(() {
//                         part2 = value;
//                       });
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             const Text(
//               "Get the code from the person\nsetting up your family’s Circle",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 14, color: Colors.grey),
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: isCodeComplete ? _submitCode : null,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isCodeComplete ? Colors.purple : Colors.purple.shade100,
//                 padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               child: const Text(
//                 'Submit',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
