import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/features/loan/data/loan_model.dart';
import 'package:loan_app/features/loan/data/owner_model.dart';

class LoanRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Owner>> fetchOwners() async {
    try {
      final snapshot =
          await _firestore
              .collection('ownerDetails')
              .where('status', isEqualTo: true)
              .get();
      return snapshot.docs.map((doc) => Owner.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch owners: $e');
    }
  }

  Future<QuerySnapshot> fetchLoanDetails({
    required String searchQuery,
    String? selectedFilter,
    bool isFilterApplied = false,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    try {
      print("Fetch Loan details ///////////////");
      Query query = _firestore
          .collection('loanDetails')
          // .orderBy('createdDate', descending: true)
          .orderBy('created_date', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      // Search Query (Partial Match Filtering)
      if (searchQuery.isNotEmpty) {
        if (isFilterApplied && selectedFilter != null) {
          String fieldName;
          if (selectedFilter == "Customer Name") {
            fieldName = "customer_lower_name";
          } else if (selectedFilter == "Owner Name") {
            fieldName = "owner_lower_name";
          } else {
            fieldName = selectedFilter;
          }

          query = query
              .where(fieldName, isGreaterThanOrEqualTo: searchQuery)
              .where(fieldName, isLessThanOrEqualTo: searchQuery + '\uf8ff');
        } else {
          query = query
              .where('customer_lower_name', isGreaterThanOrEqualTo: searchQuery)
              .where(
                'customer_lower_name',
                isLessThanOrEqualTo: searchQuery + '\uf8ff',
              );
        }
      }

      return await query.get();
    } catch (e) {
      throw Exception('Failed to fetch loan details: $e');
    }
  }

  // Add a new item with sequence number management
  Future<void> addLoan(CreateLoanModel loan) async {
    try {
      return await FirebaseFirestore.instance.runTransaction((
        transaction,
      ) async {
        //------------ Get current count document
        final countRef = _firestore.collection('Count').doc('count');
        final countSnapshot = await transaction.get(countRef);
        int currentCount = 0;
        int currentActiveLoanCount = 0;
        if (countSnapshot.exists) {
          currentCount = (countSnapshot.data()?['loan_count'] ?? 0) as int;
          currentActiveLoanCount =
              (countSnapshot.data()?['active_loans'] ?? 0) as int;
        }
        final newLoanCount = currentCount + 1;
        final newActiveLoanCount = currentActiveLoanCount + 1;

        //------------ Generate a unique Loan ID
        final String loanId = 'LOAN-${DateTime.now().year}-$newLoanCount';

        //------------ Step 1: Add the main loan document
        DocumentReference newLoanRef = _firestore
            .collection('loanDetails')
            .doc(loanId);

        transaction.set(newLoanRef, {
          ...loan.toMap(),
          'loan_id': loanId,
          'created_date': FieldValue.serverTimestamp(),
          'status': 'active',
          'customer_lower_name': loan.customerName?.toLowerCase() ?? '',
          'owner_lower_name': loan.ownerName?.toLowerCase() ?? '',
        });

        //------------ Step 2: Generate repayment schedule
        final DateTime startDate = loan.dueDate!; // First repayment date
        for (int i = 0; i < loan.loanDuration!; i++) {
          final dueDate = DateTime(
            startDate.year,
            startDate.month + i,
            startDate.day,
          );

          // Add each repayment to subcollection
          //Give code for document ID as month_number
          transaction.set(newLoanRef.collection('repayments').doc('${i + 1}'), {
            'month_number': i + 1,
            'due_date': dueDate,
            'repayment_amount': loan.calculatedMonthlyPayment,
            'repayment_date': null, // Initially null
            'is_paid': false,
            'fine_amount': 0,
            'reminder_sent': false,
            // 'total_due': loan.calculatedMonthlyPayment,
          });

          // 🟢 Add summary in loansByMonth/yyyy-MM/items/loanId
          // final String monthKey =
          //     '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}';

          // final monthRef = _firestore
          //     .collection('loansByMonth')
          //     .doc(monthKey)
          //     .collection('loans')
          //     .doc(loanId);

          // transaction.set(monthRef, {
          //   'loan_id': loanId,
          //   'customer_name': loan.customerName,
          //   'customer_phone': loan.customerPhoneNumber,
          //   'owner_name': loan.ownerName,
          //   're-payment_amount': loan.calculatedMonthlyPayment,
          //   'total_pending_amount': loan.totalPendingAmount,
          //   'total_loan_amount': loan.loanAmount,
          //   'due_date': dueDate,
          //   'is_paid': false,
          // });
        }
        //------------ Step 3: Update loan counter
        if (countSnapshot.exists) {
          transaction.update(countRef, {'loan_count': newLoanCount});
          transaction.update(countRef, {'active_loans': newActiveLoanCount});
        } else {
          transaction.set(countRef, {'loan_count': newLoanCount});
        }
      });
    } catch (e) {
      throw Exception('Failed to add loan: $e');
    }
  }

  // Modify an existing item
  // Future<void> modifyCustomer(
  //   String customerId,
  //   UpdateCustomerModel updatedCustomer,
  // ) async {
  //   try {
  //     QuerySnapshot snapshot =
  //         await _firestore
  //             .collection('customerDetails')
  //             .where('customer_id', isEqualTo: customerId)
  //             .limit(1) // Assuming item_id is unique
  //             .get();

  //     if (snapshot.docs.isEmpty) {
  //       print("No document found for customerId: $customerId");
  //       return;
  //     }

  //     await _firestore.collection('customerDetails').doc(customerId).update({
  //       'customer_name':
  //           updatedCustomer.customerName!.trim(), // Remove extra spaces
  //       'phone_number':
  //           updatedCustomer.phoneNumber!.trim(), // Remove extra spaces
  //       'alternate_phone_number': updatedCustomer.alternatePhoneNumber?.trim(),
  //       'gender': updatedCustomer.gender!.trim(), // Remove extra spaces
  //       'address': updatedCustomer.address!.trim(), // Remove extra spaces
  //     });
  //   } catch (e) {
  //     throw Exception('Failed to modify customer.');
  //   }
  // }

  /////////////////------------------////////////////////////////
  ///Loan Repayment Functions

  Future<List<Map<String, dynamic>>> fetchRepayments(String loanId) async {
    print('#Fetching repayments for loanId: $loanId');
    final snapshot =
        await _firestore
            .collection('loanDetails')
            .doc(loanId)
            .collection('repayments')
            .orderBy('due_date')
            .get();

    final config_ref =
        await _firestore.collection('configurations').doc('app_config').get();

    int finePercentage = 0;
    if (config_ref.exists) {
      final data = config_ref.data()!;
      finePercentage = (data['finePercentage'] as num?)?.toInt() ?? 0;
      print('/////////////Fetched fine percentage: $finePercentage');
    }

    return snapshot.docs.map((doc) {
      final data = doc.data();
      print('Fetched repayment: $data');
      return {
        'id': doc.id,
        'due_date': (data['due_date'] as Timestamp).toDate(),
        'repayment_amount': data['repayment_amount'] ?? 0,
        'is_paid': data['is_paid'] ?? false,
        'fine_amount': data['fine_amount'] ?? 0,
        'fine_percentage': finePercentage,
      };
    }).toList();
  }

  //fetch total pending amount and total fine amount
  Future<Map<String, double>> fetchTotalPendingAndFine(String loanId) async {
    print('Fetching total pending and fine for loanId: $loanId');
    final loanRef = _firestore.collection('loanDetails').doc(loanId);
    final snapshot = await loanRef.get();
    final data = snapshot.data();

    double pendingAmount = 0.0;
    double fineAmount = 0.0;

    if (data != null) {
      final rawPending = data['total_pending_amount'];
      final rawFine = data['total_fine_amount'];

      pendingAmount =
          rawPending is int ? rawPending.toDouble() : (rawPending ?? 0.0);
      fineAmount = rawFine is int ? rawFine.toDouble() : (rawFine ?? 0.0);
    }

    return {'totalPendingAmount': pendingAmount, 'totalFineAmount': fineAmount};
  }

  String formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return DateFormat('dd-MMM-yy').format(date);
  }

  Future<void> toggleRepaymentStatus(
    String loanId,
    String docId,
    DateTime dueDate,
  ) async {
    const maxRetries = 3;
    int retryCount = 0;

    print(dueDate);

    final loanRef = _firestore.collection('loanDetails').doc(loanId);
    final repaymentRef = loanRef.collection('repayments').doc(docId);

    // Get current month key in format "yyyy-MM"
    // final String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    // final String currentMonth = DateFormat('yyyy-MM').format(dueDate);
    // final loanByMonthRef = _firestore
    //     .collection('loansByMonth')
    //     .doc(currentMonth)
    //     .collection('loans')
    //     .doc(loanId);

    while (retryCount < maxRetries) {
      try {
        await _firestore.runTransaction((transaction) async {
          // Read current loan and repayment data
          final loanSnap = await transaction.get(loanRef);
          final repaymentSnap = await transaction.get(repaymentRef);

          final currentStatus = repaymentSnap['is_paid'] ?? false;
          final monthlyPayment = loanSnap['calculated_monthly_payment'] ?? 0;
          final existingPending = loanSnap['total_pending_amount'] ?? 0;

          final updatedPending =
              currentStatus
                  ? (existingPending + monthlyPayment) // Marking unpaid
                  : (existingPending - monthlyPayment); // Marking paid

          final paymentDate =
              currentStatus ? null : FieldValue.serverTimestamp();

          // 🔁 Update loanDetails/{loanId}
          transaction.update(loanRef, {'total_pending_amount': updatedPending});

          // 🔁 Update loanDetails/{loanId}/repayments/{docId}
          transaction.update(repaymentRef, {
            'is_paid': !currentStatus,
            'repayment_date': paymentDate,
          });

          // 🔁 Update loansByMonth/{yyyy-MM}/loans/{loanId}
          // transaction.update(loanByMonthRef, {
          //   'is_paid': !currentStatus,
          //   'total_pending_amount': updatedPending,
          // });
        });

        print('✅ Repayment status toggled successfully');
        break; // Exit on success
      } catch (e) {
        retryCount++;
        print("⚠️ Attempt $retryCount failed: $e");
        await Future.delayed(Duration(milliseconds: 500 * retryCount));
        if (retryCount == maxRetries) {
          throw Exception(
            "❌ Failed to toggle repayment after $maxRetries attempts: $e",
          );
        }
      }
    }
  }

  Future<void> toggleToUnpaidRepaymentStatus(
    String loanId,
    String repaymentId,
    DateTime dueDate,
  ) async {
    const maxRetries = 3;
    int retryCount = 0;

    final loanRef = _firestore.collection('loanDetails').doc(loanId);
    final repaymentRef = loanRef.collection('repayments').doc(repaymentId);

    // final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    // final String currentMonth = DateFormat('yyyy-MM').format(dueDate);
    // final loanByMonthRef = _firestore
    //     .collection('loansByMonth')
    //     .doc(currentMonth)
    //     .collection('loans')
    //     .doc(loanId);

    while (retryCount < maxRetries) {
      try {
        await _firestore.runTransaction((transaction) async {
          final loanSnap = await transaction.get(loanRef);
          final repaymentSnap = await transaction.get(repaymentRef);

          final currentStatus = repaymentSnap['is_paid'] ?? false;

          if (currentStatus == false) {
            throw Exception("Repayment is already marked as unpaid.");
          }

          final monthlyPayment = loanSnap['calculated_monthly_payment'] ?? 0;
          final existingPending = loanSnap['total_pending_amount'] ?? 0;

          final updatedPending = existingPending + monthlyPayment;

          // Update loanDetails main doc
          transaction.update(loanRef, {'total_pending_amount': updatedPending});

          // Update the repayment doc to unpaid
          transaction.update(repaymentRef, {
            'is_paid': false,
            'repayment_date': null,
          });

          // Update the loansByMonth doc
          // transaction.update(loanByMonthRef, {
          //   'is_paid': false,
          //   'total_pending_amount': updatedPending,
          // });
        });

        print('✅ Repayment marked as unpaid successfully');
        break; // Exit loop on success
      } catch (e) {
        retryCount++;
        print("⚠️ Attempt $retryCount failed: $e");
        await Future.delayed(Duration(milliseconds: 500 * retryCount));
        if (retryCount == maxRetries) {
          throw Exception(
            "❌ Failed to mark repayment unpaid after $maxRetries attempts: $e",
          );
        }
      }
    }
  }

  Future<void> updateFineAmount(
    String loanId,
    String docId,
    double fineAmount,
  ) async {
    print('Updating fine amount for loanId: $loanId, docId: $docId');
    const maxRetries = 3;
    int retryCount = 0;
    final loanRef = _firestore.collection('loanDetails').doc(loanId);
    final repaymentRef = loanRef.collection('repayments').doc(docId);
    // double totalFineAmount = 0.0;

    while (retryCount < maxRetries) {
      try {
        await _firestore.runTransaction((transaction) async {
          final document = await transaction.get(loanRef);

          // totalFineAmount = (document['total_fine_amount'] ?? 0) + fineAmount;
          // print('Total Fine Amount: $totalFineAmount');

          transaction.update(loanRef, {
            'total_fine_amount': document['total_fine_amount'] + fineAmount,
          });
          transaction.update(repaymentRef, {'fine_amount': fineAmount});
        });
        print("✅ Fine amount updated successfully.");
        break; // Exit loop on success
      } catch (e) {
        retryCount++;
        print("⚠️ Attempt $retryCount failed: $e");
        await Future.delayed(Duration(milliseconds: 500 * retryCount));
        if (retryCount == maxRetries) {
          throw Exception(
            "❌ Failed to toggle repayment after $maxRetries attempts: $e",
          );
        }
      }
    }
    // return totalFineAmount; // Return the updated fine amount
  }

  //Close Loan
  Future<void> closeLoan(String loanId) async {
    await _firestore.collection('loanDetails').doc(loanId).update({
      'status': 'closed',
    });
    await _firestore.collection('Count').doc('count').update({
      'active_loans': FieldValue.increment(-1),
    });
    await _firestore.collection('Count').doc('count').update({
      'closed_loans': FieldValue.increment(1),
    });
  }

  /////////////////------------------////////////////////////////
  //---------------------Loan History---------------------//
  Future<List<Map<String, dynamic>>> fetchLoanHistory(
    String? customerId,
  ) async {
    if (customerId == null || customerId.isEmpty) {
      throw ArgumentError('Customer ID is required to fetch loan history.');
    }

    try {
      print(
        '---------------Fetching loan history for customer ID: $customerId',
      );
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('loanDetails')
              .where('customer_id', isEqualTo: customerId)
              .orderBy('created_date', descending: true)
              .get();

      final loans =
          querySnapshot.docs.map((doc) {
            final data = doc.data();
            print('Fetched loan: $data'); // 👈 Print each loan
            return data;
          }).toList();

      print('Total loans fetched: ${loans.length}'); // Optional summary

      return loans;
    } catch (e) {
      print('Error fetching loan history: $e'); // Debug log
      throw Exception('Failed to fetch loan history: $e');
    }
  }
}
