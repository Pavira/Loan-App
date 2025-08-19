import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loan_app/features/owner/data/owner_model.dart';

class OwnerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot> fetchOwners({
    required String searchQuery,
    String? selectedFilter,
    bool isFilterApplied = false,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    try {
      print("Fetch Owner details ///////////////");
      Query query = _firestore
          .collection('ownerDetails')
          .where('status', isEqualTo: true)
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
          if (selectedFilter == "Owner Name") {
            fieldName = "owner_lower_name";
          } else {
            fieldName = selectedFilter;
          }

          query = query
              .where(fieldName, isGreaterThanOrEqualTo: searchQuery)
              .where(fieldName, isLessThanOrEqualTo: searchQuery + '\uf8ff');
        } else {
          print('searchQuery : $searchQuery');
          query = query
              .where('owner_lower_name', isGreaterThanOrEqualTo: searchQuery)
              .where(
                'owner_lower_name',
                isLessThanOrEqualTo: searchQuery + '\uf8ff',
              );
          print('Query: $query');
        }
      }

      return await query.get();
    } catch (e) {
      throw Exception('Failed to fetch Owners: $e');
    }
  }

  // Add a new item with sequence number management
  Future<void> addOwner(CreateOwnerModel owner) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference countRef = _firestore
            .collection('Count')
            .doc('count');
        DocumentSnapshot countSnapshot = await transaction.get(countRef);

        int currentCount =
            countSnapshot.exists
                ? (countSnapshot['owner_count'] ?? 0) as int
                : 0;
        int newOwnerCount = currentCount + 1; // Compute new count

        // Update Count collection
        if (!countSnapshot.exists) {
          transaction.set(countRef, {'owner_count': newOwnerCount});
        } else {
          transaction.update(countRef, {
            'owner_count': newOwnerCount,
          }); // Avoid re-fetching
        }

        DocumentReference newOwnerRef = _firestore
            .collection('ownerDetails')
            .doc(newOwnerCount.toString());
        transaction.set(newOwnerRef, {
          ...owner.toMap(),
          'owner_id': newOwnerCount.toString(),
          'owner_lower_name': owner.ownerName!.toLowerCase(),
          'status': true,
        });
      });
    } catch (e) {
      throw Exception('Failed to add item.');
    }
  }

  // Modify an existing item
  Future<void> modifyOwner(
    String ownerId,
    UpdateOwnerModel updatedOwner,
  ) async {
    try {
      // print("reached modifyItem method://///////----- $itemId");
      // print("modifyItem method://///////----- ${updatedItem.toMap()}");
      // Step 1: Query the document where item_id == itemId
      QuerySnapshot snapshot =
          await _firestore
              .collection('ownerDetails')
              .where('owner_id', isEqualTo: ownerId)
              .limit(1) // Assuming item_id is unique
              .get();

      if (snapshot.docs.isEmpty) {
        print("No document found for ownerId: $ownerId");
        return;
      }
      // Step 2: Get the document ID
      // String docId = snapshot.docs.first.id;
      // print("Found document with ID: $docId");

      await _firestore.collection('ownerDetails').doc(ownerId).update({
        'owner_name': updatedOwner.ownerName!.trim(),
        'phone_number': updatedOwner.phoneNumber!.trim(), // Remove extra spaces
      });
    } catch (e) {
      throw Exception('Failed to modify Owner.');
    }
  }

  Future<void> deleteOwner(String ownerId) async {
    try {
      await FirebaseFirestore.instance
          .collection('ownerDetails')
          .doc(ownerId)
          .update({'status': false}); // ✅ just update status
    } catch (e) {
      throw Exception("Failed to update owner status: $e");
    }
  }
}
