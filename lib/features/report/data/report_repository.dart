import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:loan_app/features/loan/data/loan_model.dart';
class ReportRepository {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchLoanReport({
    required String? monthName,
    required String ownerName,
  }) async {
    final firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> reportList = [];

    // print('monthName: $monthName');
    if (monthName == null) {
      print('❌ Month not provided');
      return reportList;
    }

    try {
      // ✅ Safely parse year and month
      final parts = monthName.split('-'); // ["2025", "08"]
      if (parts.length != 2) throw FormatException('Invalid month format');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      // ✅ Calculate start and end of the month
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

      print(
        'Fetching loan data for $ownerName from $startOfMonth to $endOfMonth',
      );

      // ✅ Query loans by owner name
      final loanSnapshot =
          await firestore
              .collection('loanDetails')
              .where('owner_name', isEqualTo: ownerName)
              .get();

      for (var loanDoc in loanSnapshot.docs) {
        final loanData = loanDoc.data();

        // ✅ Calculate loan + interest
        final totalLoanAmount =
            (loanData['loan_amount'] as num?)?.toDouble() ?? 0.0;
        final totalInterestAmount =
            (loanData['total_interest_amount'] as num?)?.toDouble() ?? 0.0;

        // ✅ Fetch repayments for the selected month
        final repaymentSnapshot =
            await loanDoc.reference
                .collection('repayments')
                .where(
                  'due_date',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
                )
                .where(
                  'due_date',
                  isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth),
                )
                .get();

        for (var repaymentDoc in repaymentSnapshot.docs) {
          final repaymentData = repaymentDoc.data();
          final currentMonth = repaymentData['month_number'] ?? 0;
          final totalMonth = loanData['loan_duration'] ?? 0;
          final pendingMonth = totalMonth - currentMonth;
          final totalPendingAmount =
              (loanData['total_pending_amount'] as num?)?.toDouble() ?? 0.0;
          final totalFineAmount =
              (loanData['total_fine_amount'] as num?)?.toDouble() ?? 0.0;
          final combinedTotal =
              totalLoanAmount + totalInterestAmount + totalFineAmount;
          final totalLoanPaid = combinedTotal - totalPendingAmount;

          reportList.add({
            'customer_name': loanData['customer_name'] ?? '',
            'customer_phone_number': loanData['customer_phone_number'] ?? '',
            'status': repaymentData['is_paid'] ?? false,
            'loan_amount': totalLoanAmount,
            'loan_duration': totalMonth,
            'interest_rate': loanData['interest_rate'] ?? 0.0,
            'repayment_amount':
                (repaymentData['repayment_amount'] as num?)?.toDouble() ?? 0.0,
            'current_month': currentMonth,
            'pending_month': pendingMonth,
            'total_paid_amount': totalLoanPaid,
            'total_pending_amount': totalPendingAmount,
            'fine_amount': repaymentData['fine_amount'] ?? 0.0,
            'total_loan_amount': combinedTotal,
          });
        }
      }
    } catch (e) {
      print('❌ Error fetching loan data: $e');
    }

    print(reportList);
    return reportList;
  }
}
