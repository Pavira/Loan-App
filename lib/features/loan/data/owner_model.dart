import 'package:cloud_firestore/cloud_firestore.dart';

class Owner {
  final String? id;
  final String name;

  Owner({required this.id, required this.name});

  factory Owner.fromFirestore(DocumentSnapshot doc) {
    return Owner(id: doc.id, name: doc['owner_name']);
  }

  @override
  String toString() => name; // So it shows name in dropdown
}
