import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loan_app/features/customer/data/customer_model.dart';

class CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot> fetchCustomers({
    required String searchQuery,
    String? selectedFilter,
    bool isFilterApplied = false,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    try {
      print("Fetch Customer details ///////////////");
      Query query = _firestore
          .collection('customerDetails')
          // .orderBy('createdDate', descending: true)
          .orderBy('created_date', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      // Search Query (Partial Match Filtering)
      if (searchQuery.isNotEmpty) {
        if (isFilterApplied && selectedFilter != null) {
          print("Selected Filter: $selectedFilter");
          print('searchQuery : $searchQuery');
          String fieldName;
          if (selectedFilter == "Customer Name") {
            fieldName = "customer_lower_name";
          } else if (selectedFilter == "Phone Number") {
            fieldName = "phone_number";
          } else {
            fieldName = selectedFilter;
          }

          query = query
              .where(fieldName, isGreaterThanOrEqualTo: searchQuery)
              .where(fieldName, isLessThanOrEqualTo: searchQuery + '\uf8ff');
        } else {
          print('searchQuery : $searchQuery');
          query = query
              .where('customer_lower_name', isGreaterThanOrEqualTo: searchQuery)
              .where(
                'customer_lower_name',
                isLessThanOrEqualTo: searchQuery + '\uf8ff',
              );
          print('Query: $query');
        }
      }

      return await query.get();
    } catch (e) {
      throw Exception('Failed to fetch customers: $e');
    }
  }

  // Add a new item with sequence number management
  Future<void> addCustomer(CreateCustomerModel customer) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference countRef = _firestore
            .collection('Count')
            .doc('count');
        DocumentSnapshot countSnapshot = await transaction.get(countRef);

        int currentCount =
            countSnapshot.exists
                ? (countSnapshot['customer_count'] ?? 0) as int
                : 0;
        int newCustomerCount = currentCount + 1; // Compute new count

        // Update Count collection
        if (!countSnapshot.exists) {
          transaction.set(countRef, {'customer_count': newCustomerCount});
        } else {
          transaction.update(countRef, {
            'customer_count': newCustomerCount,
          }); // Avoid re-fetching
        }

        DocumentReference newCustomerRef = _firestore
            .collection('customerDetails')
            .doc(newCustomerCount.toString());
        transaction.set(newCustomerRef, {
          ...customer.toMap(),
          'customer_id': newCustomerCount.toString(),
          'created_date': FieldValue.serverTimestamp(),
          'customer_lower_name': customer.customerName!.toLowerCase(),
          // 'modified_date': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to add item.');
    }
  }

  // Modify an existing item
  Future<void> modifyCustomer(
    String customerId,
    UpdateCustomerModel updatedCustomer,
  ) async {
    try {
      // print("reached modifyItem method://///////----- $itemId");
      // print("modifyItem method://///////----- ${updatedItem.toMap()}");
      // Step 1: Query the document where item_id == itemId
      QuerySnapshot snapshot =
          await _firestore
              .collection('customerDetails')
              .where('customer_id', isEqualTo: customerId)
              .limit(1) // Assuming item_id is unique
              .get();

      if (snapshot.docs.isEmpty) {
        print("No document found for customerId: $customerId");
        return;
      }
      // Step 2: Get the document ID
      // String docId = snapshot.docs.first.id;
      // print("Found document with ID: $docId");

      await _firestore.collection('customerDetails').doc(customerId).update({
        'customer_name':
            updatedCustomer.customerName!.trim(), // Remove extra spaces
        'phone_number':
            updatedCustomer.phoneNumber!.trim(), // Remove extra spaces
        'alternate_phone_number': updatedCustomer.alternatePhoneNumber?.trim(),
        'gender': updatedCustomer.gender!.trim(), // Remove extra spaces
        'address': updatedCustomer.address!.trim(), // Remove extra spaces
      });
    } catch (e) {
      throw Exception('Failed to modify customer.');
    }
  }
}
