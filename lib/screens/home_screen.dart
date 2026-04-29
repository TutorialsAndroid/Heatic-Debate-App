import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:heatic/screens/create_topic_screen.dart';
import 'package:heatic/screens/create_topic_screen2.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

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

  Future showReportDialog(String topicId) async {
    String? selectedReason;
    final TextEditingController otherController = TextEditingController();

    List<String> reasons = [
      "Spam or promotional content",
      "Off-topic discussion",
      "Hate speech or discrimination",
      "Harassment or bullying",
      "Misleading or false information",
      "Duplicate topic",
      "Low-quality or meaningless topic",
      "Violates community guidelines",
      "Political manipulation / propaganda",
      "Sensitive or disturbing content",
      "Copyright violation",
      "Religious or cultural disrespect",
      "Personal attack on individuals",
      "Adult or inappropriate content",
      "Other"
    ];

    QuickAlert.show(
      context: context,
      type: QuickAlertType.custom,
      showConfirmBtn: false,
      widget: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              const Text('Report Topic', style: TextStyle(fontSize: 18, fontFamily: 'Poppins', fontWeight: FontWeight.w600),),
              const SizedBox(height: 8,),
              DropdownMenu<String>(
                width: MediaQuery.of(context).size.width * 0.7,

                hintText: "Select report reason",

                menuStyle: MenuStyle(
                  maximumSize: const WidgetStatePropertyAll(
                    Size.fromHeight(250),
                  ),

                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                onSelected: (value) {
                  setState(() {
                    selectedReason = value;
                  });
                },

                dropdownMenuEntries: reasons.map((reason) {
                  return DropdownMenuEntry(
                    value: reason,
                    label: reason,
                  );
                }).toList(),
              ),

              if (selectedReason == "Other")
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TextField(
                    controller: otherController,
                    decoration: const InputDecoration(
                      hintText: "Enter custom reason",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (selectedReason == null) return;

                  if (selectedReason == "Other" &&
                      otherController.text.isEmpty) {
                    return;
                  }

                  await submitReport(
                    topicId,
                    selectedReason == "Other"
                        ? otherController.text
                        : selectedReason!,
                  );
                },

                child: const Text("Submit Report"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future submitReport(String topicId, String reason) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userName = FirebaseAuth.instance.currentUser!.displayName;
    final userEmail = FirebaseAuth.instance.currentUser!.email;

    final reportRef = FirebaseFirestore.instance
        .collection("topics")
        .doc(topicId)
        .collection("reports")
        .doc(userId);

    final existingReport = await reportRef.get();

    if (!mounted) return;

    if (existingReport.exists) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        text: "You already reported this topic",
      );

      return;
    }

    await reportRef.set({
      "userId": userId,
      "userName": userName,
      "userEmail": userEmail,
      "reason": reason,
      "createdAt": Timestamp.now(),
    });

    await FirebaseFirestore.instance.collection("topics").doc(topicId).update({
      "reportsCount": FieldValue.increment(1),
    });

    if (!mounted) return;

    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: "Report submitted successfully",
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
            MaterialPageRoute(builder: (context) => const CreateTopicScreen2()),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("topics")
            .where("status", isEqualTo: "approved")
            .where("reportsCount", isLessThan: 5)
            .orderBy("reportsCount")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No approved topics available",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final topic = snapshot.data!.docs[index];

              return GestureDetector(
                onLongPress: () {
                  showReportDialog(topic.id);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// CATEGORY BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          topic["categoryName"],
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// TITLE
                      Text(
                        topic["title"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// DESCRIPTION
                      Text(
                        topic["description"],
                        style: TextStyle(color: Colors.grey.shade700),
                      ),

                      const SizedBox(height: 12),

                      /// FOOTER INFO ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.people_outline, size: 18),
                              const SizedBox(width: 5),
                              Text(
                                "${topic["participantsCount"]} participants",
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              const Icon(Icons.flag_outlined, size: 18),
                              const SizedBox(width: 5),
                              Text("${topic["reportsCount"]} reports"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
