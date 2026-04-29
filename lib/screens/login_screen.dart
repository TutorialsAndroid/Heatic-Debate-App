import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:heatic/constants/app_colors.dart';
import 'package:heatic/constants/app_constants.dart';
import 'package:heatic/constants/app_strings.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../utils/url_launcher_helper.dart';
import 'home_screen.dart';

// Author: Akshay
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, .2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showLoadingDialog() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: AppStrings.loadingDialogTitle,
      text: AppStrings.loadingDialogMessage,
      barrierDismissible: false,
    );
  }

  void _showConsentDialog() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: AppStrings.consentDialogTitle,
      text: AppStrings.consentDialogMessage,
      confirmBtnText: AppStrings.consentDialogConfirmBtn,
      cancelBtnText: AppStrings.consentDialogCancelBtn,
      onConfirmBtnTap: () {
        Navigator.pop(context);
        _showLoadingDialog();
        _signInWithGoogle();
      },
      widget: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                UrlLauncherHelper.openUrl(
                    context,
                    AppConstants.termsUrl);
              },
              child: const Text(
                "Terms & Conditions",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            const Text("  &  "),
            GestureDetector(
              onTap: () {
                UrlLauncherHelper.openUrl(
                    context,
                    AppConstants.privacyUrl);
              },
              child: const Text(
                "Privacy Policy",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: AppConstants.serverClientId,
      );

      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      Navigator.pop(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );

    } catch (e) {

      if (!mounted) return;

      Navigator.pop(context);

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: AppStrings.signInFailedMessage,
      );

      debugPrint("Google sign-in error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [

          /// Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff020617),
                  Color(0xff0F172A),
                  Color(0xff1E293B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 70),

                  /// Animated headline
                  FadeTransition(
                    opacity: fadeAnimation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: const Text(
                        "Every opinion\nhas power.",
                        style: TextStyle(
                          fontSize: 44,
                          height: 1.2,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// Animated subtitle
                  FadeTransition(
                    opacity: fadeAnimation,
                    child: const Text(
                      "Join real conversations.\nChallenge ideas. Share perspectives.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const Spacer(),

                  /// Floating logo animation
                  Center(
                    child: TweenAnimationBuilder(
                      tween: Tween(begin: -6.0, end: 6.0),
                      duration: const Duration(seconds: 2),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, value),
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.05),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Image.asset(
                          AppConstants.logoPath,
                          width: 70,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  /// Animated button
                  SlideTransition(
                    position: slideAnimation,
                    child: FadeTransition(
                      opacity: fadeAnimation,
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 8,
                          ),
                          onPressed: _showConsentDialog,
                          child: const Text(
                            "Enter the discussion",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Legal links
                  Center(
                    child: Wrap(
                      children: [
                        GestureDetector(
                          onTap: () {
                            UrlLauncherHelper.openUrl(
                              context,
                              AppConstants.termsUrl,
                            );
                          },
                          child: const Text(
                            "Terms",
                            style: TextStyle(
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                        const Text(
                          "  •  ",
                          style: TextStyle(color: Colors.white54),
                        ),
                        GestureDetector(
                          onTap: () {
                            UrlLauncherHelper.openUrl(
                              context,
                              AppConstants.privacyUrl,
                            );
                          },
                          child: const Text(
                            "Privacy",
                            style: TextStyle(
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}