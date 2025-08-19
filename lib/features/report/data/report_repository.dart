import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loan_app/features/loan/data/loan_model.dart'; // replace with your actual Loan model import

class ReportRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<LoanReportModel>> fetchLoanReport({
    required String monthDocId,
    required String ownerName,
  }) async {
    try {
      print('Fetching loan report for monthDocId: $monthDocId');
      final snapshot =
          await _firestore
              .collection('loansByMonth')
              .doc(monthDocId)
              .collection('loans') // e.g. '2025-10'
              .where('owner_name', isEqualTo: ownerName)
              .get();

      return snapshot.docs
          .map((doc) => LoanReportModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch loan report: $e');
    }
  }
}
