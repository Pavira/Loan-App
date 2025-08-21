// loan_details_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/core/theme/app_theme.dart';
import 'package:loan_app/features/loan/data/loan_model.dart';
import 'package:loan_app/features/loan/data/loan_repository.dart';
import 'package:loan_app/widgets/appbar.dart';
import 'package:loan_app/widgets/button.dart';
import 'package:loan_app/widgets/dialog_box.dart';

class LoanDetailsPage extends StatefulWidget {
  final CreateLoanModel createLoanModel;
  const LoanDetailsPage({super.key, required this.createLoanModel});
  @override
  _LoanDetailsPageState createState() => _LoanDetailsPageState();
}

class _LoanDetailsPageState extends State<LoanDetailsPage> {
  final LoanRepository loanRepository = LoanRepository();
  List<Map<String, dynamic>> repaymentList = [];
  double totalFineAmount = 0.0;
  double totalPendingAmount = 0.0; // Initialize totalPending
  bool isLoading = false;
  bool isLoanClosable = false;

  @override
  void initState() {
    super.initState();
    initLoad();
  }

  Future<void> initLoad() async {
    await fetchRepaymentsAndApplyFines(); // ⏳ Wait for fines to be updated
    print("✅ Fines updated, now fetching totals...");
    await fetchTotalPendingAndFine(); // ✅ Now fetch correct totals
    print('Status: ${widget.createLoanModel.status}');
  }

  Future<void> closeLoan() {
    return loanRepository.closeLoan(widget.createLoanModel.loanId!);
  }

  Future<void> fetchRepaymentsAndApplyFines() async {
    final rawList = await loanRepository.fetchRepayments(
      widget.createLoanModel.loanId!,
    );
    final List<Map<String, dynamic>> updatedList = [];

    for (var repayment in rawList) {
      final dueDate = repayment['due_date'];
      final isPaid = repayment['is_paid'] ?? false;

      final amountRaw = repayment['repayment_amount'] ?? 0;
      final double amount = amountRaw is int ? amountRaw.toDouble() : amountRaw;

      final fineRaw = repayment['fine_amount'] ?? 0;
      double fineAmount = fineRaw is int ? fineRaw.toDouble() : fineRaw;

      final finePercentageRaw = repayment['fine_percentage'] ?? 0;
      int finePercentage =
          finePercentageRaw is int
              ? finePercentageRaw.toInt()
              : finePercentageRaw;

      // if (!isPaid && dueDate.isBefore(DateTime.now())) {
      if (!isPaid && DateTime.now().isAfter(dueDate.add(Duration(days: 1)))) {
        final calculatedFineRaw = amount * (finePercentage / 100);

        final calculatedFine = double.parse(
          calculatedFineRaw.toStringAsFixed(0),
        );

        // Only apply fine if not already applied
        if (fineAmount == 0.0) {
          await loanRepository.updateFineAmount(
            widget.createLoanModel.loanId!,
            repayment['id'],
            calculatedFine,
          );
          fineAmount = calculatedFine;
        }
      }

      repayment['fine_amount'] = fineAmount;
      repayment['total_amount'] = amount + fineAmount;
      print('Fine Amount: ' + fineAmount.toString());
      print(amount);
      updatedList.add(repayment);
    }

    setState(() {
      repaymentList = updatedList;
      isLoanClosable = updatedList.every((r) => r['is_paid'] == true);
    });
  }

  Future<void> fetchTotalPendingAndFine() async {
    final total = await loanRepository.fetchTotalPendingAndFine(
      widget.createLoanModel.loanId!,
    );
    print('///////////////');
    print(total['totalPendingAmount']);
    print(total['totalFineAmount']);
    setState(() {
      totalPendingAmount = total['totalPendingAmount'] ?? 0.0;
      totalFineAmount = total['totalFineAmount'] ?? 0.0;
    });
  }

  // Function to change the status of a repayment to paid
  Future<void> toggleRepaymentStatus(String docId, DateTime dueDate) async {
    setState(() => isLoading = true);

    // String pendingAmount = widget.createLoanModel.pendingAmount.toString();
    await loanRepository.toggleRepaymentStatus(
      widget.createLoanModel.loanId!,
      docId,
      dueDate,
    );
    await fetchRepaymentsAndApplyFines();
    await fetchTotalPendingAndFine();
    setState(() => isLoading = false);
  }

  // Function to change the status of a repayment to unpaid
  Future<void> toggleToUnpaidRepaymentStatus(
    String docId,
    DateTime dueDate,
  ) async {
    setState(() => isLoading = true);

    // String pendingAmount = widget.createLoanModel.pendingAmount.toString();
    await loanRepository.toggleToUnpaidRepaymentStatus(
      widget.createLoanModel.loanId!,
      docId,
      dueDate,
    );
    await fetchRepaymentsAndApplyFines();
    await fetchTotalPendingAndFine();
    setState(() => isLoading = false);
  }

  String formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return DateFormat('dd-MMM-yy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyColor,
      appBar: const CustomAppBar(title: 'Loan Details', centerTitle: true),
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [buildLoanDetails(), buildRepaymentTable()],
                  ),
                ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: CustomButton(
            text:
                widget.createLoanModel.status == 'closed'
                    ? "Loan Closed"
                    : "Close Loan",
            enabled:
                isLoanClosable &&
                widget.createLoanModel.status !=
                    'closed', // disabled if already closed
            onPressed:
                isLoanClosable && widget.createLoanModel.status != 'closed'
                    ? () async {
                      await closeLoanWithConfirmation();
                    }
                    : null,
          ),
        ),
      ),
    );
  }

  Future<void> closeLoanWithConfirmation() async {
    await closeLoan(); // your existing closeLoan method

    // Show success dialog
    if (!mounted) return; // safety check
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('🎉 Loan Closed'),
            content: const Text(
              'Congratulations! This loan has been closed successfully.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(context).pop(); // go back
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Widget buildLoanDetails() {
    final loan = widget.createLoanModel;
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
            'Loan Details',

            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          detailItem('Loan ID', loan.loanId),
          detailItem('Customer Name', loan.customerName),
          detailItem('Loan Amount', '₹${loan.loanAmount}'),
          detailItem('Interest Rate', '${loan.interestRate ?? "N/A"}%'),
          detailItem('Loan Duration', '${loan.loanDuration ?? "N/A"} months'),
          detailItem(
            'Monthly EMI',
            loan.calculatedMonthlyPayment != null
                ? '₹${loan.calculatedMonthlyPayment}'
                : 'N/A',
          ),
          detailItem('Due Date', formatDate(loan.dueDate)),
          detailItem('Owner Name', loan.ownerName),
        ],
      ),
    );
  }

  Widget buildRepaymentTable() {
    // double totalLoan = widget.createLoanModel.loanAmount!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Re-Payment Table',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),

        /// Table Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
            // border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              /// Header
              Container(
                // margin: const EdgeInsets.only(top: 12), // gap from top
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFE5E9EC),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Due Date',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          // decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Status',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        'Actions',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// Rows
              ...repaymentList.map((repayment) {
                DateTime dueDate;
                // print('Due Date Type: ${repayment['due_date'].runtimeType}');

                if (repayment['due_date'] is Timestamp) {
                  dueDate = (repayment['due_date'] as Timestamp).toDate();
                } else if (repayment['due_date'] is DateTime) {
                  dueDate = repayment['due_date'] as DateTime;
                } else {
                  // Optional fallback or error logging
                  throw Exception('Invalid date format for due_date');
                }
                // print('Due Date: $dueDate');
                final bool isPaid = repayment['is_paid'] ?? false;
                final bool isOverdue = dueDate.isBefore(DateTime.now());

                // int fineAmount = 0;
                double fineAmount = 0.0;
                // if (isOverdue) {
                // final loan = widget.createLoanModel;
                // fineAmount = (repayment['repayment_amount'] ?? 0.0) * 0.25;
                // _totalFineAmount += fineAmount;
                // try {
                //   loanRepository.updateFineAmount(
                //     loan.loanId!,
                //     repayment['id'],
                //     fineAmount,
                //   );
                //   fetchTotalPendingAndFine();
                // } catch (e) {
                //   fineAmount = 0.0;
                //   print("❌ Error updating fine: $e");
                // }
                // }
                if (isOverdue && isPaid) {
                  fineAmount = repayment['fine_amount'];
                } else {
                  fineAmount = repayment['fine_amount'] ?? 0.0;
                }

                double totalAmount = repayment['total_amount'] ?? 0.0;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    // vertical: 8,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color:
                        repayment['is_paid']
                            ? Colors.grey.shade200
                            : Colors.white,
                    // border: Border(top: BorderSide(color: Colors.grey)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ), // gap from corners
                        height: 1,
                        color: Colors.grey.shade300,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              formatDate(repayment['due_date']),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              '₹${repayment['repayment_amount']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              repayment['is_paid'] ? 'Paid' : 'Due',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    repayment['is_paid']
                                        ? Colors.green
                                        : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    repayment['is_paid']
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color:
                                        repayment['is_paid']
                                            ? Colors.green
                                            : Colors.grey,
                                  ),
                                  onPressed:
                                      repayment['is_paid']
                                          ? null // ❌ disables the button if paid
                                          : () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CustomDialogBox(
                                                  title:
                                                      'Change Repayment Status',
                                                  content:
                                                      'Are you sure you want to mark this as ${repayment['is_paid'] ? 'unpaid' : 'paid'}?',
                                                  onYesPressed: () {
                                                    Navigator.of(
                                                      context,
                                                    ).pop(); // Close dialog
                                                    toggleRepaymentStatus(
                                                      repayment['id'],
                                                      repayment['due_date'],
                                                    ); // Call your function
                                                  },
                                                  onCancelPressed: () {
                                                    Navigator.of(
                                                      context,
                                                    ).pop(); // Just close dialog
                                                  },
                                                );
                                              },
                                            );
                                          },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_note_rounded,
                                    size: 20,
                                    color: Colors.indigo,
                                  ),
                                  onPressed:
                                      repayment['is_paid'] == false ||
                                              widget.createLoanModel.status ==
                                                  'closed'
                                          ? null // ❌ disables the button if paid
                                          : () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CustomDialogBox(
                                                  title:
                                                      'Change Repayment Status',
                                                  content:
                                                      'Are you sure you want to mark this as ${repayment['is_paid'] ? 'unpaid' : 'paid'}?',
                                                  onYesPressed: () {
                                                    Navigator.of(
                                                      context,
                                                    ).pop(); // Close dialog
                                                    toggleToUnpaidRepaymentStatus(
                                                      repayment['id'],
                                                      repayment['due_date'],
                                                    ); // Call your function
                                                  },
                                                  onCancelPressed: () {
                                                    Navigator.of(
                                                      context,
                                                    ).pop(); // Just close dialog
                                                  },
                                                );
                                              },
                                            );
                                          },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Fine display (only if applicable)
                      if (isOverdue && fineAmount > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Row(
                            children: [
                              Flexible(
                                flex: 5,
                                child: Text(
                                  'Fine Amount: ₹${fineAmount.toStringAsFixed(2)},',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ), // 👈 Controls the spacing
                              Flexible(
                                flex: 5,
                                child: Text(
                                  'Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),

        /// 🔻 Summary Section
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
            // border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              summaryItem(
                'Total Pending Amount',
                '₹${totalPendingAmount.toStringAsFixed(2)}',
              ),
              summaryItem(
                'Total Fine Amount',
                '₹${totalFineAmount.toStringAsFixed(2)}',
              ),
              // summaryItem(
              //   'Total Loan Amount',
              //   '₹${totalLoan.toStringAsFixed(2)}',
              // ),
              // summaryItem(
              //   'Total Loan Amount',
              //   '₹${(totalPendingAmount + totalFineAmount).toStringAsFixed(2)}',
              // ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🔹 Summary Item UI
  Widget summaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            // style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: cardTextColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600]),
          ),
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
            flex: 3,
            child: Text(
              value ?? '',
              style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
