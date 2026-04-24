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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

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
      text:
      AppStrings.consentDialogMessage,
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
                UrlLauncherHelper.openUrl(context, AppConstants.termsUrl);
              },
              child: const Text(
                "Terms & Conditions",
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.none,
                ),
              ),
            ),

            const Text("  &  "),

            GestureDetector(
              onTap: () {
                UrlLauncherHelper.openUrl(context, AppConstants.privacyUrl);
              },
              child: const Text(
                "Privacy Policy",
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sign in With Google
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

      Navigator.pop(context); // closes loading dialog

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
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: GestureDetector(
              child: Card(
                elevation: 6.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(AppConstants.logoPath, width: 34),
                ),
              ),
              onTap: () {
                _showConsentDialog();
              },
            ),
          ),
        ],
      ),
    );
  }
}
