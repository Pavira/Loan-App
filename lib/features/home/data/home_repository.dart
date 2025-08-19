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
    try {
      final now = DateTime.now();
      final String monthKey =
          "${now.year}-${now.month.toString().padLeft(2, '0')}";

      final monthRef = _firestore
          .collection('loansByMonth')
          .doc(monthKey)
          .collection('loans');

      QuerySnapshot snapshot =
          await monthRef.where('owner_name', isEqualTo: ownerName).get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return {
          // 'id': doc.id,
          'customer_name': data['customer_name'],
          're-payment_amount': data['re-payment_amount'],
          'total_pending_amount': data['total_pending_amount'],
          'total_loan_amount': data['total_loan_amount'],
          'status': data['is_paid'] ?? false,
        };
      }).toList();
    } catch (e) {
      print('Error fetching present month loan data: $e');
      return [];
    }
  }
}
