import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heatic/constants/app_strings.dart';
import 'package:heatic/screens/request_category_screen.dart';
import 'package:heatic/services/create_topic_service.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../constants/app_colors.dart';

class CreateTopicScreen extends StatefulWidget {
  const CreateTopicScreen({super.key});

  @override
  State<CreateTopicScreen> createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends State<CreateTopicScreen> {
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
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          AppStrings.createTopicAppBarTitle,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          /// TOPIC NAME FIELD
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _topicNameController,
              minLines: 3,
              maxLines: null,
              maxLength: 120,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
              ],
              decoration: InputDecoration(
                hintText: "Enter Topic Name",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.secondary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          /// TOPIC DESCRIPTION FIELD
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _topicDescriptionController,
              minLines: 5,
              maxLines: null,
              maxLength: 380,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
              ],
              decoration: InputDecoration(
                hintText: "Enter Topic Description",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.secondary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          /// CATEGORY DROPDOWN
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("categories")
                .where("approved", isEqualTo: true)
                .snapshots(),

            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: DropdownMenu<String>(
                  width: MediaQuery.of(context).size.width * 0.9,

                  hintText: "Select Category",

                  menuStyle: MenuStyle(
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    elevation: const WidgetStatePropertyAll(6),
                  ),

                  onSelected: (value) {
                    final selectedDoc = snapshot.data!.docs.firstWhere(
                      (doc) => doc.id == value,
                    );

                    setState(() {
                      selectedCategoryId = value!;
                      selectedCategoryName = selectedDoc["name"];
                    });
                  },

                  dropdownMenuEntries: snapshot.data!.docs.map((doc) {
                    return DropdownMenuEntry<String>(
                      value: doc.id,
                      label: doc["name"],
                    );
                  }).toList(),
                ),
              );
            },
          ),

          /// REQUEST CATEGORY BUTTON
          TextButton(
            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) => const RequestCategoryScreen(),
                ),
              );
            },

            child: const Text("Can't find category? Request one"),
          ),

          /// Submit Topic Button
          ElevatedButton(
            onPressed: loading ? null : submitTopic,
            child: loading
                ? const CircularProgressIndicator(
                    color: AppColors.secondary,
                    padding: EdgeInsets.all(4.0),
                  )
                : const Text(
                    "Submit Topic",
                    style: TextStyle(color: Colors.black),
                  ),
          ),
        ],
      ),
    );
  }
}
