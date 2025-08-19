// loan_details_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/core/theme/app_theme.dart';
import 'package:loan_app/features/customer/data/customer_model.dart';
import 'package:loan_app/features/loan/data/loan_model.dart';
import 'package:loan_app/features/loan/data/loan_repository.dart';
import 'package:loan_app/features/loan/presentation/loan_details_page.dart';
import 'package:loan_app/widgets/appbar.dart';
import 'package:loan_app/widgets/loan_history_card.dart';

class LoanHistoryPage extends StatefulWidget {
  final CreateCustomerModel createCustomer;

  const LoanHistoryPage({Key? key, required this.createCustomer})
    : super(key: key);

  @override
  _LoanHistoryPageState createState() => _LoanHistoryPageState();
}

class _LoanHistoryPageState extends State<LoanHistoryPage> {
  final LoanRepository loanRepository = LoanRepository();
  List<Map<String, dynamic>> loanHistory = [];
  bool isFetching = false;
  String? errorMessage;
  // final ScrollController _scrollController = ScrollController();
  bool hasMoreData = true;
  // DocumentSnapshot? lastDocument;
  String? customerId;

  @override
  void initState() {
    super.initState();
    customerId = widget.createCustomer.customerId;
    fetchLoanHistory();
  }

  String formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return DateFormat('dd-MMM-yy').format(date);
  }

  Future<void> fetchLoanHistory() async {
    if (isFetching) return;

    setState(() {
      isFetching = true;
      errorMessage = null;
    });

    try {
      final querySnapshot = await loanRepository.fetchLoanHistory(customerId);

      setState(() {
        loanHistory = querySnapshot;
        isFetching = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load customers. Please try again.";
        isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyColor,
      appBar: const CustomAppBar(title: 'Loan History', centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [buildCustomerDetails(), buildLoanHistory()],
          ),
        ),
      ),
    );
  }

  //---------------Section 1 Customer Details----------------------
  Widget buildCustomerDetails() {
    final customer = widget.createCustomer;
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Details',

            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          detailItem('Customer ID', customer.customerId),
          detailItem('Customer Name', customer.customerName),
          detailItem('Phone Number', customer.phoneNumber),
          detailItem(
            'Alt. Phone Number',
            customer.alternatePhoneNumber ?? 'N/A',
          ),
          detailItem('Gender', customer.gender),
          detailItem('Address', customer.address),
        ],
      ),
    );
  }

  Widget detailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: cardTextColor,
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              '-',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value ?? '',
              style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
  //---------------Section 2 Loan History----------------------

  //Fetch loan history
  // Widget buildLoanHistory() {
  //   return Scaffold(
  //     body: Padding(
  //       padding: const EdgeInsetsDirectional.only(
  //         top: 10.0,
  //         start: 4.0,
  //         end: 4.0,
  //       ),
  //       child: Column(
  //         children: [
  //           //--------------------/////////////------------------//
  //           // List of loans (Placeholder for now)
  //           Expanded(
  //             child:
  //                 loanHistory.isEmpty && !isFetching
  //                     ? Center(
  //                       child: Text(
  //                         "No Loan History to show",
  //                         textAlign: TextAlign.center,
  //                       ),
  //                     )
  //                     : ListView.builder(
  //                       controller: _scrollController,
  //                       itemCount:
  //                           loanHistory.length +
  //                           1, // extra slot for loader/message
  //                       itemBuilder: (context, index) {
  //                         if (index == loanHistory.length) {
  //                           // return Center(child: CircularProgressIndicator());
  //                           if (isFetching) {
  //                             return Center(child: CircularProgressIndicator());
  //                           } else {
  //                             return Padding(
  //                               padding: const EdgeInsets.symmetric(
  //                                 vertical: 16.0,
  //                               ),
  //                               child: Center(
  //                                 child: Text(
  //                                   "No more loans to show",
  //                                   style: TextStyle(
  //                                     color: Colors.red,
  //                                     fontSize: 16,
  //                                   ),
  //                                 ),
  //                               ),
  //                             );
  //                           }
  //                         }

  //                         var loan = loanHistory[index];
  //                         try {
  //                           return GestureDetector(
  //                             // onTap: () async {
  //                             //   await Navigator.push(
  //                             //     context,
  //                             //     MaterialPageRoute(
  //                             //       builder:
  //                             //           (context) => LoanHistoryPage(
  //                             //             createCustomer: CreateCustomerModel(
  //                             //               customerId: customer['customer_id'],
  //                             //               customerName:
  //                             //                   customer['customer_name'],
  //                             //               phoneNumber:
  //                             //                   customer['phone_number'],
  //                             //               alternatePhoneNumber:
  //                             //                   customer['alternate_phone_number'] ??
  //                             //                   '',
  //                             //               gender: customer['gender'],
  //                             //               address: customer['address'],
  //                             //             ),
  //                             //           ),
  //                             //     ),
  //                             //   ).then((_) => fetchCustomers());
  //                             // },
  //                             child: CustomLoanHistoryCard(
  //                               loanId: loan['loan_id'],
  //                               createdDate: loan['created_date'],
  //                               loanAmount: loan['loan_amount'],
  //                               dueDate: loan['due_date'],
  //                               ownerName: loan['owner_name'],
  //                               status: loan['status'],
  //                             ),
  //                           );
  //                         } catch (e) {
  //                           return ListTile(
  //                             title: Text("Error loading Loan History"),
  //                             subtitle: Text(e.toString()),
  //                           );
  //                         }
  //                       },
  //                     ),
  //           ),
  //           //--------------------/////////////------------------//
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget buildLoanHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Loan History',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          loanHistory.isEmpty && !isFetching
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No Loan History to show"),
                ),
              )
              : ListView.builder(
                shrinkWrap: true, // important for Column
                physics:
                    const NeverScrollableScrollPhysics(), // disable internal scroll
                itemCount: loanHistory.length + 1,
                itemBuilder: (context, index) {
                  if (index == loanHistory.length) {
                    return isFetching
                        ? const Center(child: CircularProgressIndicator())
                        : const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: Text(
                              "No more loans to show",
                              style: TextStyle(color: Colors.red, fontSize: 16),
                            ),
                          ),
                        );
                  }

                  final loan = loanHistory[index];
                  try {
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => LoanDetailsPage(
                                  createLoanModel: CreateLoanModel(
                                    loanId: loan['loan_id'] ?? '',
                                    customerId: loan['customer_id'] ?? '',
                                    ownerId: loan['owner_id'] ?? '',
                                    customerName: loan['customer_name'] ?? '',
                                    ownerName: loan['owner_name'] ?? '',
                                    loanAmount:
                                        double.tryParse(
                                          loan['loan_amount']?.toString() ??
                                              '0',
                                        ) ??
                                        0.0,
                                    dueDate:
                                        loan['due_date'] != null
                                            ? (loan['due_date'] as Timestamp)
                                                .toDate()
                                            : null,
                                    calculatedMonthlyPayment:
                                        loan['calculated_monthly_payment'],
                                    interestRate: loan['interest_rate'],
                                    loanDuration: loan['loan_duration'],
                                    status: loan['status'] ?? 'active',
                                  ),
                                ),
                          ),
                        );
                        fetchLoanHistory(); // Refresh after returning
                      },
                      child: CustomLoanHistoryCard(
                        loanId: loan['loan_id'],
                        createdDate:
                            loan['created_date'] != null
                                ? DateFormat('dd-MMM-yy').format(
                                  (loan['created_date'] as Timestamp).toDate(),
                                )
                                : 'Unknown',
                        loanAmount: loan['loan_amount']?.toString() ?? '0',
                        dueDate:
                            loan['due_date'] != null
                                ? DateFormat('dd-MMM-yy').format(
                                  (loan['due_date'] as Timestamp).toDate(),
                                )
                                : 'Unknown',
                        ownerName: loan['owner_name'],
                        status: loan['status'],
                      ),
                    );
                  } catch (e) {
                    return ListTile(
                      title: const Text("Error loading Loan History"),
                      subtitle: Text(e.toString()),
                    );
                  }
                },
              ),
        ],
      ),
    );
  }
}
