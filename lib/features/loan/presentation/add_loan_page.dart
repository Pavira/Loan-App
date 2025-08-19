import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loan_app/core/theme/app_theme.dart';
import 'package:loan_app/features/customer/data/customer_model.dart';
import 'package:loan_app/features/customer/data/customer_repository.dart';
import 'package:loan_app/features/loan/data/loan_model.dart';
import 'package:loan_app/features/loan/data/loan_repository.dart';
import 'package:loan_app/features/loan/data/owner_model.dart';
import 'package:loan_app/widgets/animated_dynamic_dropdown.dart';
import 'package:loan_app/widgets/animated_text_area.dart';
import 'package:loan_app/widgets/animated_text_field.dart';
import 'package:loan_app/widgets/appbar.dart';
import 'package:loan_app/widgets/button.dart';
import 'package:loan_app/widgets/custom_snackbar.dart';
import 'package:loan_app/widgets/datepicker.dart';

class AddLoanPage extends StatefulWidget {
  @override
  _AddLoanPageState createState() => _AddLoanPageState();
}

class _AddLoanPageState extends State<AddLoanPage> {
  Owner? selectedOwner; // Default selected owner
  CreateCustomerModel? selectedCustomer; // Store selected customer model
  String? selectedCustomerPhone;
  String? selectedOwnerId; // Store selected owner ID
  String? selectedCustomerId; // Store selected customer ID
  bool isSubmitting = false; // Add this at the class level

  final TextEditingController loanAmountController = TextEditingController();
  final TextEditingController loanDurationController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  final TextEditingController calculatedMonthlyPaymentController =
      TextEditingController();
  final TextEditingController securityController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  final TextEditingController totalInterestAmountController =
      TextEditingController();
  DateTime? _selectedDueDate; // Initialize with current date

  @override
  void initState() {
    super.initState();
    loanAmountController.addListener(calculateMonthlyPayment);
    loanDurationController.addListener(calculateMonthlyPayment);
    interestRateController.addListener(calculateMonthlyPayment);
  }

  @override
  void dispose() {
    loanAmountController.dispose();
    loanDurationController.dispose();
    interestRateController.dispose();
    calculatedMonthlyPaymentController.dispose();
    securityController.dispose();
    remarksController.dispose();
    totalInterestAmountController.dispose();
    super.dispose();
  }

  void calculateMonthlyPayment() {
    double principal = double.tryParse(loanAmountController.text) ?? 0;
    int duration = int.tryParse(loanDurationController.text) ?? 0;
    double interestRate = double.tryParse(interestRateController.text) ?? 0;

    if (principal == 0 || interestRate == 0) {
      calculatedMonthlyPaymentController.text = '';
      totalInterestAmountController.text = '';
      return;
    } else if (duration == 0) {
      calculatedMonthlyPaymentController.text = '';
    }

    double interest = (principal * interestRate) / 100;
    double totalPayable = principal + interest;
    double monthlyPayment = totalPayable / duration;
    totalInterestAmountController.text = interest.toStringAsFixed(2);

    if (duration != 0 && interestRate != 0 && principal != 0) {
      calculatedMonthlyPaymentController.text = monthlyPayment.toStringAsFixed(
        2,
      );
    }
  }

  Future<void> onSubmit() async {
    if (loanAmountController.text.isEmpty ||
        loanDurationController.text.isEmpty ||
        interestRateController.text.isEmpty ||
        calculatedMonthlyPaymentController.text.isEmpty ||
        selectedCustomer == null ||
        selectedCustomerPhone == null ||
        selectedOwner == null ||
        _selectedDueDate == null) {
      showCustomSnackbar(context, "Please fill all required fields");
      return;
    }
    CreateLoanModel newLoan = CreateLoanModel(
      // loanId: loanId,
      customerId: selectedCustomerId!,
      ownerId: selectedOwnerId!,
      customerName: selectedCustomer?.customerName,
      customerPhoneNumber: selectedCustomerPhone,
      ownerName: selectedOwner?.name,
      loanAmount: double.tryParse(loanAmountController.text) ?? 0.0,
      loanDuration: int.tryParse(loanDurationController.text) ?? 0,
      interestRate: double.tryParse(interestRateController.text) ?? 0.0,
      dueDate: _selectedDueDate, // Replace with actual date picker value
      calculatedMonthlyPayment:
          double.tryParse(calculatedMonthlyPaymentController.text) ?? 0.0,
      totalInterestAmount:
          double.tryParse(totalInterestAmountController.text) ?? 0.0,
      security: securityController.text,
      remarks: remarksController.text,
      totalPendingAmount:
          (double.tryParse(loanAmountController.text) ?? 0.0) +
          (double.tryParse(totalInterestAmountController.text) ?? 0.0),
      totalFineAmount: 0.0, // Initialize to 0
    );

    if (isSubmitting) return; // Prevent multiple clicks
    setState(() {
      isSubmitting = true; // Disable button
    });

    try {
      await LoanRepository().addLoan(newLoan);
      Navigator.pop(context); // Go back to previous page
      showCustomSnackbar(
        context,
        "Loan saved successfully!",
        color: Colors.green,
      );
    } catch (e) {
      showCustomSnackbar(
        context,
        "Failed to save Loan. Please try again!",
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
      appBar: CustomAppBar(title: 'Add New Loan', centerTitle: true),
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
                  DropdownSearchWidget<Owner>(
                    label: "Select Owner*",
                    selectedItem: selectedOwner,
                    asyncItemsFetcher: (filter) async {
                      return await LoanRepository().fetchOwners();
                    },
                    itemAsString: (owner) => owner.name,
                    onChanged: (Owner? owner) {
                      setState(() {
                        selectedOwner = owner;
                        selectedOwnerId = owner?.id;
                      });
                    },
                  ),

                  SizedBox(height: 16),
                  DropdownSearchWidget<CreateCustomerModel>(
                    label: "Select Customer*",
                    asyncItemsFetcher: (String filter) async {
                      final snapshot = await CustomerRepository()
                          .fetchCustomers(
                            searchQuery: filter,
                            isFilterApplied: false,
                          );
                      return snapshot.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        data['customer_id'] =
                            doc.id; // Add Firestore ID to data
                        return CreateCustomerModel.fromMap(data);
                      }).toList();
                    },
                    itemAsString:
                        (CreateCustomerModel customer) =>
                            customer.customerName!,
                    selectedItem: selectedCustomer,
                    onChanged: (CreateCustomerModel? customer) {
                      setState(() {
                        selectedCustomer = customer;
                        selectedCustomerId = customer?.customerId;
                        selectedCustomerPhone = customer?.phoneNumber;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  AnimatedTextField(
                    label: 'Loan Amount*',
                    controller: loanAmountController,
                    inputFormatter: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  AnimatedTextField(
                    label: 'Interest Rate (%)*',
                    controller: interestRateController,
                    inputFormatter: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  AnimatedTextField(
                    label: 'Total Interest Amount',
                    isReadOnly: true,
                    controller: totalInterestAmountController,
                  ),

                  SizedBox(height: 16),
                  AnimatedTextField(
                    label: 'Loan Duration (Months)*',
                    controller: loanDurationController,
                    inputFormatter: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),

                  AnimatedTextField(
                    label: 'Calculated Monthly Payment',
                    isReadOnly: true,
                    controller: calculatedMonthlyPaymentController,
                  ),
                  SizedBox(height: 16),
                  CustomDatePicker(
                    hintText: 'Select Due Date*',
                    onDateSelected: (date) {
                      _selectedDueDate = date; // Store the DateTime object here
                    },
                  ),
                  SizedBox(height: 16),
                  AnimatedTextField(
                    label: 'Security',
                    controller: securityController,
                  ),
                  SizedBox(height: 16),
                  AnimatedTextArea(
                    label: 'Remarks',
                    controller: remarksController,
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
            text: "Submit",
            onPressed: () {
              onSubmit();
            },
          ),
        ),
      ),
    );
  }
}
