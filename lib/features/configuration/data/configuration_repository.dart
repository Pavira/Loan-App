import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loan_app/features/configuration/data/configuration_model.dart';

class ConfigurationRepository {
  final _docRef = FirebaseFirestore.instance
      .collection('configurations')
      .doc('app_config'); // 🔹 single config doc

  Future<ConfigurationModel?> getConfiguration() async {
    try {
      final snapshot = await _docRef.get();
      if (snapshot.exists) {
        return ConfigurationModel.fromMap(snapshot.data()!);
      }
      return null;
    } catch (e) {
      throw Exception("Failed to fetch configuration: $e");
    }
  }

  Future<void> saveConfiguration(ConfigurationModel config) async {
    try {
      await _docRef.set(config.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception("Failed to save configuration: $e");
    }
  }

  // Modify an existing item
  // Future<void> modifyOwner(
  //   String ownerId,
  //   UpdateOwnerModel updatedOwner,
  // ) async {
  //   try {
  //     // print("reached modifyItem method://///////----- $itemId");
  //     // print("modifyItem method://///////----- ${updatedItem.toMap()}");
  //     // Step 1: Query the document where item_id == itemId
  //     QuerySnapshot snapshot =
  //         await _firestore
  //             .collection('ownerDetails')
  //             .where('owner_id', isEqualTo: ownerId)
  //             .limit(1) // Assuming item_id is unique
  //             .get();

  //     if (snapshot.docs.isEmpty) {
  //       print("No document found for ownerId: $ownerId");
  //       return;
  //     }
  //     // Step 2: Get the document ID
  //     // String docId = snapshot.docs.first.id;
  //     // print("Found document with ID: $docId");

  //     await _firestore.collection('ownerDetails').doc(ownerId).update({
  //       'owner_name': updatedOwner.ownerName!.trim(),
  //       'phone_number': updatedOwner.phoneNumber!.trim(), // Remove extra spaces
  //     });
  //   } catch (e) {
  //     throw Exception('Failed to modify Owner.');
  //   }
  // }

  // Future<void> deleteOwner(String ownerId) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('ownerDetails')
  //         .doc(ownerId)
  //         .update({'status': false}); // ✅ just update status
  //   } catch (e) {
  //     throw Exception("Failed to update owner status: $e");
  //   }
  // }
}
