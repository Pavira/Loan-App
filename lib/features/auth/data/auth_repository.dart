import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> validatePin(String pin) async {
    try {
      final snapshot =
          await _firestore
              .collection('Auth')
              .doc('admin') // Change to your document ID logic
              .get();

      if (snapshot.exists) {
        final storedPin = snapshot.data()?['pin'];
        return storedPin == pin;
      }
    } catch (e) {
      print('Pin validation error: $e');
    }
    return false;
  }
}
