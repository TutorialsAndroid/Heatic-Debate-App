import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:heatic/screens/create_topic_screen.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();

    await GoogleSignIn.instance.signOut();

    // Navigate to Login screen and remove all previous routes
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          AppStrings.appName,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            _signOut();
          },
          icon: Icon(Icons.exit_to_app_sharp, color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Open Create Topic Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTopicScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Column(),
    );
  }
}
