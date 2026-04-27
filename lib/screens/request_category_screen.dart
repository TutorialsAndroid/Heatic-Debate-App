import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heatic/services/category_service.dart';
import 'package:quickalert/quickalert.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class RequestCategoryScreen extends StatefulWidget {
  const RequestCategoryScreen({super.key});

  @override
  State<RequestCategoryScreen> createState() => _RequestCategoryScreenState();
}

class _RequestCategoryScreenState extends State<RequestCategoryScreen> {
  final _topicCategoryName = TextEditingController();
  bool loading = false;

  Future submitCategory() async {
    if (_topicCategoryName.text.trim().isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: "Category name required",
      );

      return;
    }

    setState(() => loading = true);

    try {
      await CategoryService().submitCategoryRequest(_topicCategoryName.text);

      if (!mounted) return;

      Navigator.pop(context);

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: "Category submitted for review",
      );
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: "Submission failed",
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
          AppStrings.requestCategoryAppBarTitle,
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

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _topicCategoryName,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                ],
                decoration: InputDecoration(
                  hintText: "Enter Category Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : submitCategory,

              child: loading
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    )
                  : const Text("Submit Request"),
            ),
          ],
        ),
      ),
    );
  }
}
