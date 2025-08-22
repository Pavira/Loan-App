import 'package:cloud_firestore/cloud_firestore.dart';

class HomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, int>> fetchCounts() async {
    print("feteching counts from firestore ///////////////");
    try {
      DocumentSnapshot countDoc =
          await _firestore.collection('Count').doc('count').get();

      if (countDoc.exists) {
        return {
          'loan_count': countDoc['loan_count'] ?? 0,
          'customer_count': countDoc['customer_count'] ?? 0,
          'active_loans': countDoc['active_loans'] ?? 0,
          'closed_loans': countDoc['closed_loans'] ?? 0,
        };
      }
      return {
        'loan_count': 0,
        'customer_count': 0,
        'active_loans': 0,
        'closed_loans': 0,
      }; // Default values if document doesn't exist
    } catch (e) {
      print('Error fetching counts: $e');
      return {'item_count': 0, 'consignee_count': 0};
    }
  }

  Future<List<Map<String, dynamic>>> fetchPresentMonthLoanData({
    required String ownerName,
  }) async {
    final firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> reportList = [];

    print('Fetching present month loan data for owner: $ownerName');
    try {
      // ✅ Get first and last day of the current month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      print('Start of month: $startOfMonth, End of month: $endOfMonth');

      // ✅ Query all loans for the given owner
      final loanSnapshot =
          await firestore
              .collection('loanDetails')
              .where('owner_name', isEqualTo: ownerName)
              .get();

      for (var loanDoc in loanSnapshot.docs) {
        final loanData = loanDoc.data();

        // ✅ Calculate total loan + interest
        final totalLoanAmount =
            (loanData['loan_amount'] as num?)?.toDouble() ?? 0.0;
        final totalInterestAmount =
            (loanData['total_interest_amount'] as num?)?.toDouble() ?? 0.0;

        final combinedTotal = totalLoanAmount + totalInterestAmount;

        // ✅ Fetch repayments for this loan for current month
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

          reportList.add({
            'customer_name': loanData['customer_name'] ?? '',
            'status': repaymentData['is_paid'] ?? false,
            'repayment_amount':
                (repaymentData['repayment_amount'] as num?)?.toDouble() ?? 0.0,
            'total_pending_amount':
                (loanData['total_pending_amount'] as num?)?.toDouble() ?? 0.0,
            'total_loan_amount': combinedTotal,
            // Optional fields if needed:
            // 'due_date': repaymentData['due_date'],
            // 'loan_id': loanData['loan_id'] ?? '',
          });
        }
      }
    } catch (e) {
      print('❌ Error fetching loan data: $e');
    }
    print(reportList);

    return reportList;
  }

  // Future<List<Map<String, dynamic>>> fetchPresentMonthLoanData({
  //   required String ownerName,
  // }) async {
  //   try {
  //     final now = DateTime.now();
  //     final String monthKey =
  //         "${now.year}-${now.month.toString().padLeft(2, '0')}";

  //     final monthRef = _firestore
  //         .collection('loansByMonth')
  //         .doc(monthKey)
  //         .collection('loans');

  //     QuerySnapshot snapshot =
  //         await monthRef.where('owner_name', isEqualTo: ownerName).get();

  //     return snapshot.docs.map((doc) {
  //       final data = doc.data() as Map<String, dynamic>;

  //       return {
  //         // 'id': doc.id,
  // 'customer_name': data['customer_name'],
  // 're-payment_amount': data['re-payment_amount'],
  // 'total_pending_amount': data['total_pending_amount'],
  // 'total_loan_amount': data['total_loan_amount'],
  //         'status': data['is_paid'] ?? false,
  //       };
  //     }).toList();
  //   } catch (e) {
  //     print('Error fetching present month loan data: $e');
  //     return [];
  //   }
  // }
}
