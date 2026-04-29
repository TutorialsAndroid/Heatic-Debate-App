import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:heatic/screens/request_category_screen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../constants/app_colors.dart';
import '../services/create_topic_service.dart';

class CreateTopicScreen2 extends StatefulWidget {
  const CreateTopicScreen2({super.key});

  @override
  State<CreateTopicScreen2> createState() => _CreateTopicScreen2State();
}

class _CreateTopicScreen2State extends State<CreateTopicScreen2> {
  String? selectedCategoryId;
  String? selectedCategoryName;

  bool loading = false;

  final TextEditingController _topicNameController = TextEditingController();
  final TextEditingController _topicDescriptionController =
  TextEditingController();

  Future submitTopic() async {
    if (_topicNameController.text.isEmpty ||
        _topicDescriptionController.text.isEmpty ||
        selectedCategoryId == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: "Please fill all required fields",
      );

      return;
    }

    setState(() => loading = true);

    try {
      await CreateTopicService().createTopic(
        title: _topicNameController.text.trim(),
        description: _topicDescriptionController.text.trim(),
        categoryId: selectedCategoryId!,
        categoryName: selectedCategoryName!,
      );

      if (!mounted) return;

      Navigator.pop(context);

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: "Topic submitted successfully for review",
      );
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: "Failed to submit topic",
      );
    }

    setState(() => loading = false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F172A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 10),

            /// HERO TITLE (same tone as login screen)
            const Text(
              "Start a discussion",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 40),

            /// DISCUSSION CARD CONTAINER
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),

              child: Column(
                children: [

                  /// TOPIC FIELD
                  TextField(
                    controller: _topicNameController,
                    minLines: 3,
                    maxLines: null,
                    maxLength: 120,
                    style: const TextStyle(color: Colors.white),

                    decoration: InputDecoration(
                      hintText: "What should people debate about?",
                      hintStyle:
                      const TextStyle(color: Colors.white),

                      filled: true,
                      fillColor: const Color(0xff1E293B),

                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// DESCRIPTION FIELD
                  TextField(
                    controller: _topicDescriptionController,
                    minLines: 5,
                    maxLines: null,
                    maxLength: 380,
                    style: const TextStyle(color: Colors.white),

                    decoration: InputDecoration(
                      hintText:
                      "Explain the issue so others understand both sides",
                      hintStyle:
                      const TextStyle(color: Colors.white),

                      filled: true,
                      fillColor: const Color(0xff1E293B),

                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// CATEGORY DROPDOWN
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("categories")
                        .where("approved", isEqualTo: true)
                        .snapshots(),

                    builder: (context, snapshot) {

                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      return DropdownMenu<String>(
                        width:
                        MediaQuery.of(context).size.width *
                            0.8,

                        hintText: "Select category",

                        onSelected: (value) {

                          final selectedDoc =
                          snapshot.data!.docs.firstWhere(
                                  (doc) => doc.id == value);

                          setState(() {
                            selectedCategoryId = value!;
                            selectedCategoryName =
                            selectedDoc["name"];
                          });
                        },

                        dropdownMenuEntries:
                        snapshot.data!.docs.map((doc) {

                          return DropdownMenuEntry<String>(
                            value: doc.id,
                            label: doc["name"],
                          );

                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  /// REQUEST CATEGORY BUTTON
                  TextButton(
                    onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const RequestCategoryScreen(),
                        ),
                      );

                    },
                    child: const Text(
                      "Can't find category? Request one",
                      style:
                      TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// SUBMIT BUTTON (same style as login screen)
            SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                ),

                onPressed: loading ? null : submitTopic,

                child: loading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text(
                  "Send for review",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
