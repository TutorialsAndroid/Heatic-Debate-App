import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

class UrlLauncherHelper {
  static Future<void> openUrl(
      BuildContext context,
      String url,
      ) async {
    try {
      await launchUrl(
        Uri.parse(url),
        customTabsOptions: const CustomTabsOptions(
          showTitle: true,
        ),
      );
    } catch (e) {
      debugPrint("Could not launch $url");
    }
  }
}