import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loan_app/core/theme/app_theme.dart';
import 'package:loan_app/features/customer/data/customer_model.dart';
import 'package:loan_app/features/customer/data/customer_repository.dart';
import 'package:loan_app/widgets/animated_text_area.dart';
import 'package:loan_app/widgets/animated_text_field.dart';
import 'package:loan_app/widgets/appbar.dart';
import 'package:loan_app/widgets/button.dart';
import 'package:loan_app/widgets/custom_snackbar.dart';
import 'package:loan_app/widgets/gender_selector.dart';

class UpdateCustomerPage extends StatefulWidget {
  final CreateCustomerModel createCustomer; // <-- Accept ItemModel

  const UpdateCustomerPage({required this.createCustomer}) : super(key: null);
  @override
  UpdateCustomerPageState createState() => UpdateCustomerPageState();
}

class UpdateCustomerPageState extends State<UpdateCustomerPage> {
  // String defaultSelectedGender = 'Male'; // Default
  String customerId = '';

  String? selectedGender;
  bool isSubmitting = false; // Add this at the class level

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController phnoneNoController = TextEditingController();
  final TextEditingController alternatePhnoneNoController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    customerId = widget.createCustomer.customerId!;
    customerNameController.text = widget.createCustomer.customerName!;
    //Remove +91 prefix
    phnoneNoController.text = widget.createCustomer.phoneNumber!.replaceFirst(
      '+91',
      '',
    );
    alternatePhnoneNoController.text =
        widget.createCustomer.alternatePhoneNumber ?? '';
    addressController.text = widget.createCustomer.address!;
    selectedGender = widget.createCustomer.gender;
  }

  @override
  void dispose() {
    customerNameController
        .dispose(); // Dispose controller to avoid memory leaks
    phnoneNoController.dispose();
    alternatePhnoneNoController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> onSubmit() async {
    if (customerNameController.text.isEmpty ||
        phnoneNoController.text.length != 10 ||
        addressController.text.isEmpty ||
        selectedGender == null) {
      showCustomSnackbar(context, "Please fill all required fields");
      return;
    }
    if (phnoneNoController.text == alternatePhnoneNoController.text) {
      showCustomSnackbar(
        context,
        "Alternate phone number cannot be the same as primary phone number",
      );
      return;
    }
    if (alternatePhnoneNoController.text.isNotEmpty &&
        alternatePhnoneNoController.text.length != 10) {
      showCustomSnackbar(context, "Alternate phone number must be 10 digits");
      return;
    }
    UpdateCustomerModel updatedCustomer = UpdateCustomerModel(
      customerId: widget.createCustomer.customerId,
      customerName: customerNameController.text,
      phoneNumber: phnoneNoController.text,
      alternatePhoneNumber: alternatePhnoneNoController.text,
      gender: selectedGender!,
      address: addressController.text,
    );

    if (isSubmitting) return; // Prevent multiple clicks
    setState(() {
      isSubmitting = true; // Disable button
    });

    try {
      await CustomerRepository().modifyCustomer(customerId, updatedCustomer);
      Navigator.pop(context);
      showCustomSnackbar(
        context,
        "Customer ${customerNameController.text.trim()} updated successfully!",
        color: Colors.green,
      );
    } catch (e) {
      showCustomSnackbar(
        context,
        "Failed to update Customer. Try again!",
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
      appBar: CustomAppBar(title: 'Update Customer', centerTitle: true),
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
                    label: 'Customer Name*',
                    controller: customerNameController,
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
                  SizedBox(height: 16),
                  AnimatedTextField(
                    label: 'Alternate Phone Number',
                    controller: alternatePhnoneNoController,
                    keyboardType: TextInputType.number,
                    inputFormatter: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  SizedBox(height: 16),
                  GenderSelector(
                    initialGender: selectedGender!,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  AnimatedTextArea(
                    label: 'Address*',
                    controller: addressController,
                  ),
                  SizedBox(height: 16),
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
            text: "Update Customer",
            onPressed: () {
              onSubmit();
            },
          ),
        ),
      ),
    );
  }
}
