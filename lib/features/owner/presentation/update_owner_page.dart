import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loan_app/core/theme/app_theme.dart';
import 'package:loan_app/features/owner/data/owner_model.dart';
import 'package:loan_app/features/owner/data/owner_repository.dart';
import 'package:loan_app/widgets/animated_text_field.dart';
import 'package:loan_app/widgets/appbar.dart';
import 'package:loan_app/widgets/button.dart';
import 'package:loan_app/widgets/custom_snackbar.dart';

class UpdateOwnerPage extends StatefulWidget {
  final CreateOwnerModel createOwner; // <-- Accept ItemModel

  const UpdateOwnerPage({required this.createOwner}) : super(key: null);
  @override
  UpdateOwnerPageState createState() => UpdateOwnerPageState();
}

class UpdateOwnerPageState extends State<UpdateOwnerPage> {
  // String defaultSelectedGender = 'Male'; // Default
  String ownerId = '';

  bool isSubmitting = false; // Add this at the class level

  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController phnoneNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ownerId = widget.createOwner.ownerId!;
    ownerNameController.text = widget.createOwner.ownerName!;
    //Remove +91 prefix
    phnoneNoController.text = widget.createOwner.phoneNumber!;
  }

  @override
  void dispose() {
    ownerNameController.dispose(); // Dispose controller to avoid memory leaks
    phnoneNoController.dispose();
    super.dispose();
  }

  Future<void> onSubmit() async {
    if (ownerNameController.text.isEmpty ||
        phnoneNoController.text.length != 10) {
      showCustomSnackbar(context, "Please fill all required fields");
      return;
    }
    UpdateOwnerModel updatedOwner = UpdateOwnerModel(
      ownerId: widget.createOwner.ownerId,
      ownerName: ownerNameController.text,
      phoneNumber: phnoneNoController.text,
    );

    if (isSubmitting) return; // Prevent multiple clicks
    setState(() {
      isSubmitting = true; // Disable button
    });

    try {
      await OwnerRepository().modifyOwner(ownerId, updatedOwner);
      Navigator.pop(context);
      showCustomSnackbar(
        context,
        "Owner ${ownerNameController.text.trim()} updated successfully!",
        color: Colors.green,
      );
    } catch (e) {
      showCustomSnackbar(
        context,
        "Failed to update Owner. Try again!",
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
      appBar: CustomAppBar(title: 'Update Owner', centerTitle: true),
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
                  // SizedBox(height: 16),
                  // AnimatedTextField(
                  //   label: 'Last Name*',
                  //   controller: hsnCodeController,
                  // ),
                  SizedBox(height: 16),
                  AnimatedTextField(
                    label: 'Phone Number*',
                    controller: phnoneNoController,
                    keyboardType: TextInputType.number,
                    inputFormatter: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
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
            text: "Update Owner",
            onPressed: () {
              onSubmit();
            },
          ),
        ),
      ),
    );
  }
}
