// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:loan_app/core/theme/app_theme.dart';
// import 'package:loan_app/features/customer/data/customer_model.dart';
// import 'package:loan_app/features/customer/data/customer_repository.dart';
// import 'package:loan_app/features/loan/data/loan_model.dart';
// import 'package:loan_app/features/loan/data/loan_repository.dart';
// import 'package:loan_app/features/loan/data/owner_model.dart';
// import 'package:loan_app/widgets/animated_dynamic_dropdown.dart';
// import 'package:loan_app/widgets/animated_text_area.dart';
// import 'package:loan_app/widgets/animated_text_field.dart';
// import 'package:loan_app/widgets/appbar.dart';
// import 'package:loan_app/widgets/button.dart';
// import 'package:loan_app/widgets/custom_snackbar.dart';
// import 'package:loan_app/widgets/datepicker.dart';

// class UpdateLoanPage extends StatefulWidget {
//   final CreateLoanModel createLoanModel;

//   const UpdateLoanPage({Key? key, required this.createLoanModel})
//     : super(key: key);

//   @override
//   _UpdateLoanPageState createState() => _UpdateLoanPageState();
// }

// class _UpdateLoanPageState extends State<UpdateLoanPage> {
//   Owner? selectedOwner; // Default selected owner
//   CreateCustomerModel? selectedCustomer; // Store selected customer model
//   String? selectedOwnerId; // Store selected owner ID
//   String? selectedCustomerId; // Store selected customer ID
//   bool isSubmitting = false; // Add this at the class level

//   final TextEditingController loanAmountController = TextEditingController();
//   final TextEditingController loanDurationController = TextEditingController();
//   final TextEditingController interestRateController = TextEditingController();
//   final TextEditingController calculatedMonthlyPaymentController =
//       TextEditingController();
//   final TextEditingController totalInterestAmountController =
//       TextEditingController();
//   final TextEditingController securityController = TextEditingController();
//   final TextEditingController remarksController = TextEditingController();
//   final TextEditingController dueDateController = TextEditingController();
//   DateTime? _selectedDueDate; // Initialize with current date

//   @override
//   void initState() {
//     super.initState();
//     // Initialize controllers with existing loan data
//     loanAmountController.text = widget.createLoanModel.loanAmount.toString();
//     loanDurationController.text =
//         widget.createLoanModel.loanDuration.toString();
//     interestRateController.text =
//         widget.createLoanModel.interestRate.toString();
//     calculatedMonthlyPaymentController.text =
//         widget.createLoanModel.calculatedMonthlyPayment.toString();
//     totalInterestAmountController.text =
//         widget.createLoanModel.totalInterestAmount.toString();
//     securityController.text = widget.createLoanModel.security ?? '';
//     remarksController.text = widget.createLoanModel.remarks ?? '';
//     selectedOwnerId = widget.createLoanModel.ownerId;
//     selectedCustomerId = widget.createLoanModel.customerId;
//     selectedCustomer = CreateCustomerModel(
//       customerId: selectedCustomerId,
//       customerName: widget.createLoanModel.customerName ?? '',
//     );
//     selectedOwner = Owner(
//       id: selectedOwnerId,
//       name: widget.createLoanModel.ownerName ?? '',
//     );
//     dueDateController.text =
//         widget.createLoanModel.dueDate != null
//             ? widget.createLoanModel.dueDate!.toLocal().toString().split(' ')[0]
//             : '';

//     loanAmountController.addListener(calculateMonthlyPayment);
//     loanDurationController.addListener(calculateMonthlyPayment);
//     interestRateController.addListener(calculateMonthlyPayment);
//   }

//   @override
//   void dispose() {
//     loanAmountController.dispose();
//     loanDurationController.dispose();
//     interestRateController.dispose();
//     calculatedMonthlyPaymentController.dispose();
//     securityController.dispose();
//     remarksController.dispose();
//     super.dispose();
//   }

//   void calculateMonthlyPayment() {
//     double principal = double.tryParse(loanAmountController.text) ?? 0;
//     double duration = double.tryParse(loanDurationController.text) ?? 0;
//     double interestRate = double.tryParse(interestRateController.text) ?? 0;

//     if (principal == 0 || duration == 0 || interestRate == 0) {
//       calculatedMonthlyPaymentController.text = '';
//       return;
//     }

//     double interest = (principal * interestRate) / 100;
//     double totalPayable = principal + interest;
//     double monthlyPayment = totalPayable / duration;

//     calculatedMonthlyPaymentController.text = monthlyPayment.toStringAsFixed(0);
//     totalInterestAmountController.text = interest.toStringAsFixed(0);
//   }

//   Future<void> onSubmit() async {
//     if (loanAmountController.text.isEmpty ||
//         loanDurationController.text.isEmpty ||
//         interestRateController.text.isEmpty ||
//         calculatedMonthlyPaymentController.text.isEmpty ||
//         selectedCustomer == null ||
//         selectedOwner == null ||
//         _selectedDueDate == null) {
//       showCustomSnackbar(context, "Please fill all required fields");
//       return;
//     }

//     // String loanId = await LoanRepository().createLoanId();
//     // if (loanId.isEmpty) {
//     //   showCustomSnackbar(context, "Failed to generate Loan ID");
//     //   return;
//     // }

//     CreateLoanModel newLoan = CreateLoanModel(
//       // loanId: loanId,
//       customerId: selectedCustomerId!,
//       ownerId: selectedOwnerId!,
//       customerName: selectedCustomer?.customerName,
//       ownerName: selectedOwner?.name,
//       loanAmount: int.tryParse(loanAmountController.text) ?? 0,
//       loanDuration: int.tryParse(loanDurationController.text) ?? 0,
//       interestRate: int.tryParse(interestRateController.text) ?? 0,
//       dueDate: _selectedDueDate, // Replace with actual date picker value
//       calculatedMonthlyPayment:
//           int.tryParse(calculatedMonthlyPaymentController.text) ?? 0,
//       totalInterestAmount:
//           int.tryParse(totalInterestAmountController.text) ?? 0,
//       security: securityController.text,
//       remarks: remarksController.text,
//     );

//     if (isSubmitting) return; // Prevent multiple clicks
//     setState(() {
//       isSubmitting = true; // Disable button
//     });

//     try {
//       await LoanRepository().addLoan(newLoan);
//       Navigator.pop(context); // Go back to previous page
//       showCustomSnackbar(
//         context,
//         "Loan saved successfully!",
//         color: Colors.green,
//       );
//     } catch (e) {
//       showCustomSnackbar(
//         context,
//         "Failed to save Loan. Please try again!",
//         color: Colors.red,
//       );
//     } finally {
//       setState(() {
//         isSubmitting = false; // Re-enable button
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: bodyColor,
//       appBar: CustomAppBar(title: 'Add New Loan', centerTitle: true),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(6),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 6,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   DropdownSearchWidget<Owner>(
//                     label: "Select Owner*",
//                     isReadOnly: false,
//                     selectedItem: selectedOwner,
//                     asyncItemsFetcher: (filter) async {
//                       return await LoanRepository().fetchOwners();
//                     },
//                     itemAsString: (owner) => owner.name,
//                     onChanged: (Owner? owner) {
//                       setState(() {
//                         selectedOwner = owner;
//                         selectedOwnerId = owner?.id;
//                       });
//                     },
//                   ),

//                   SizedBox(height: 16),
//                   DropdownSearchWidget<CreateCustomerModel>(
//                     label: "Select Customer*",
//                     isReadOnly: false,
//                     asyncItemsFetcher: (String filter) async {
//                       final snapshot = await CustomerRepository()
//                           .fetchCustomers(
//                             searchQuery: filter,
//                             isFilterApplied: false,
//                           );
//                       return snapshot.docs.map((doc) {
//                         final data = doc.data() as Map<String, dynamic>;
//                         data['customer_id'] =
//                             doc.id; // Add Firestore ID to data
//                         return CreateCustomerModel.fromMap(data);
//                       }).toList();
//                     },
//                     itemAsString:
//                         (CreateCustomerModel customer) =>
//                             customer.customerName!,
//                     selectedItem: selectedCustomer,
//                     onChanged: (CreateCustomerModel? customer) {
//                       setState(() {
//                         selectedCustomer = customer;
//                         selectedCustomerId = customer?.customerId;
//                       });
//                     },
//                   ),
//                   SizedBox(height: 16),
//                   AnimatedTextField(
//                     label: 'Loan Amount*',
//                     isReadOnly: true,
//                     controller: loanAmountController,
//                     inputFormatter: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(6),
//                     ],
//                     keyboardType: TextInputType.number,
//                   ),
//                   SizedBox(height: 16),
//                   AnimatedTextField(
//                     label: 'Loan Duration (Months)*',
//                     isReadOnly: true,
//                     controller: loanDurationController,
//                     inputFormatter: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(2),
//                     ],
//                     keyboardType: TextInputType.number,
//                   ),
//                   SizedBox(height: 16),
//                   AnimatedTextField(
//                     label: 'Interest Rate (%)*',
//                     isReadOnly: true,
//                     controller: interestRateController,
//                     inputFormatter: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(5),
//                     ],
//                     keyboardType: TextInputType.number,
//                   ),
//                   SizedBox(height: 16),
//                   AnimatedTextField(
//                     label: 'Total Interest Amount',
//                     isReadOnly: true,
//                     controller: totalInterestAmountController,
//                   ),
//                   SizedBox(height: 16),
//                   AnimatedTextField(
//                     label: 'Calculated Monthly Payment',
//                     isReadOnly: true,
//                     controller: calculatedMonthlyPaymentController,
//                   ),
//                   SizedBox(height: 16),
//                   CustomDatePicker(
//                     hintText: 'Select Due Date*',
//                     controller: dueDateController,
//                     onDateSelected: (date) {
//                       _selectedDueDate = date; // Store the DateTime object here
//                     },
//                   ),
//                   SizedBox(height: 16),
//                   AnimatedTextField(
//                     label: 'Security',
//                     controller: securityController,
//                   ),
//                   SizedBox(height: 16),
//                   AnimatedTextArea(
//                     label: 'Remarks',
//                     controller: remarksController,
//                   ),
//                   SizedBox(height: 16),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),

//       // 👇 Fixed Button at Bottom
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
//         child: SizedBox(
//           width: double.infinity,
//           height: 50,
//           child: CustomButton(
//             text: "Submit",
//             onPressed: () {
//               onSubmit();
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
