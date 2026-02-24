import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_shop_app/customer/customer_home_screen.dart';
import 'package:grocery_shop_app/dash_board_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;

  bool _isObscure = true;

  Future<void> authenticate() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        (!isLogin && nameController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential userCredential;

      if (isLogin) {
        // 🔥 LOGIN
        userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        // 🔥 REGISTER
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // 🔥 Save user data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': nameController.text.trim(), // ✅ SAVE NAME
          'email': emailController.text.trim(),
          'role': 'customer',
          'phone': '',
          'address': '',
          'createdAt': Timestamp.now(),
        });
      }

      // 🔥 Fetch role
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      String role = userDoc.data()?['role'] ?? 'customer';
      if (role == 'customer' && !kIsWeb) {
        await saveUserToken();
      }

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Authentication Error")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> saveUserToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? token = await FirebaseMessaging.instance.getToken();

    print("🔥 FCM TOKEN: $token");

    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'fcmToken': token},
        SetOptions(merge: true), // 🔥 THIS IS IMPORTANT
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Stack(children: [
      Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body:
            // body: Center(
            //   child: Padding(
            //     padding: const EdgeInsets.all(20),
            //     child: SingleChildScrollView(
            //       child: Column(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           const Text(
            //             "Grocery App",
            //             style: TextStyle(
            //               fontSize: 30,
            //               fontWeight: FontWeight.bold,
            //               color: Colors.green,
            //             ),
            //           ),
            //           const SizedBox(height: 30),

            //           // 🔥 SHOW NAME FIELD ONLY IN REGISTER
            //           if (!isLogin) ...[
            //             TextField(
            //               controller: nameController,
            //               decoration: const InputDecoration(
            //                 labelText: "Full Name",
            //                 border: OutlineInputBorder(),
            //               ),
            //             ),
            //             const SizedBox(height: 15),
            //           ],

            //           TextField(
            //             controller: emailController,
            //             decoration: const InputDecoration(
            //               labelText: "Email",
            //               border: OutlineInputBorder(),
            //             ),
            //           ),
            //           const SizedBox(height: 15),

            //           TextField(
            //             controller: passwordController,
            //             // obscureText: true,
            //             obscureText: _isObscure,
            //             decoration: InputDecoration(
            //               labelText: "Password",
            //               border: const OutlineInputBorder(),
            //               suffixIcon: IconButton(
            //                 icon: Icon(
            //                   _isObscure
            //                       ? Icons.visibility_off
            //                       : Icons.visibility,
            //                 ),
            //                 onPressed: () {
            //                   setState(() {
            //                     _isObscure = !_isObscure;
            //                   });
            //                 },
            //               ),
            //             ),
            //           ),
            //           const SizedBox(height: 20),

            //           ElevatedButton(
            //             onPressed: isLoading ? null : authenticate,
            //             style: ElevatedButton.styleFrom(
            //               backgroundColor: Colors.green,
            //               minimumSize: const Size(double.infinity, 50),
            //             ),
            //             child: Text(isLogin ? "Login" : "Register"),
            //           ),

            //           const SizedBox(height: 10),

            //           TextButton(
            //             onPressed: isLoading
            //                 ? null
            //                 : () {
            //                     setState(() {
            //                       isLogin = !isLogin;
            //                     });
            //                   },
            //             child: Text(
            //               isLogin
            //                   ? "Don't have account? Register"
            //                   : "Already have account? Login",
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),

            width > 900
                ? Row(
                    children: [
                      /// 🔥 LEFT SIDE (WEB ONLY)
                      Expanded(
                        child: Container(
                          color: Colors.green,
                          child: const Center(
                            child: Text(
                              "Grocery App 🛒",
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      /// 🔥 RIGHT SIDE FORM
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            width: 400,
                            child: _buildAuthCard(),
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: 400,
                        child: _buildAuthCard(),
                      ),
                    ),
                  ),
      ),
      if (isLoading)
        Container(
          color: Colors.black.withOpacity(0.4),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
    ]);
  }

  Widget _buildAuthCard() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Grocery App",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 30),
            if (!isLogin) ...[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
            ],
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                labelText: "Password",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : authenticate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(isLogin ? "Login" : "Register"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(
                isLogin
                    ? "Don't have account? Register"
                    : "Already have account? Login",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
