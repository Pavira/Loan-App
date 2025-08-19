import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loan_app/core/theme/app_theme.dart';
import 'package:loan_app/features/owner/data/owner_model.dart';
import 'package:loan_app/features/owner/data/owner_repository.dart';
import 'package:loan_app/widgets/animated_text_area.dart';
import 'package:loan_app/widgets/animated_text_field.dart';
import 'package:loan_app/widgets/appbar.dart';
import 'package:loan_app/widgets/button.dart';
import 'package:loan_app/widgets/custom_snackbar.dart';

class AddOwnerPage extends StatefulWidget {
  @override
  _AddOwnerPageState createState() => _AddOwnerPageState();
}

class _AddOwnerPageState extends State<AddOwnerPage> {
  bool isSubmitting = false; // Add this at the class level

  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    ownerNameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> onSubmit() async {
    if (ownerNameController.text.isEmpty ||
        phoneNumberController.text.isEmpty) {
      showCustomSnackbar(context, "Please fill all Owner Name");
      return;
    }

    CreateOwnerModel newOwner = CreateOwnerModel(
      ownerName: ownerNameController.text,
      phoneNumber: phoneNumberController.text,
    );

    if (isSubmitting) return; // Prevent multiple clicks
    setState(() {
      isSubmitting = true; // Disable button
    });

    try {
      await OwnerRepository().addOwner(newOwner);
      Navigator.pop(context); // Go back to previous page
      showCustomSnackbar(
        context,
        "Owner ${ownerNameController.text.trim()} saved successfully!",
        color: Colors.green,
      );
    } catch (e) {
      showCustomSnackbar(
        context,
        "Failed to save Owner. Try again!",
        color: Colors.red,
      );
    } finally {
      setState(() {
        isSubmitting = false; // Re-enable button
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyColor,
      appBar: CustomAppBar(title: 'Add New Owner', centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedTextField(
                    label: 'Owner Name*',
                    controller: ownerNameController,
                  ),
                  SizedBox(height: 16),
                  AnimatedTextField(
                    label: 'Phone Number*',
                    controller: phoneNumberController,
                    inputFormatter: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // 👇 Fixed Button at Bottom
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: CustomButton(
            text: "Save Owner",
            onPressed: () {
              onSubmit();
            },
          ),
        ),
      ),
    );
  }
}
