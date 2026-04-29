import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heatic/screens/home_screen.dart';
import 'package:heatic/screens/login_screen.dart';
import 'package:heatic/screens/login_screen2.dart';

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() =>
      _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {

  @override
  void initState() {
    super.initState();

    _handleRouting();
  }

  Future<void> _handleRouting() async {

    await Future.delayed(
        const Duration(milliseconds: 300));

    final user =
        FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user == null) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen2(),
        ),
      );

      return;
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );

  }
}