// import 'dart:ffi';

class OwnerModelBase {
  final String? ownerId;
  final String? ownerName;
  final String? phoneNumber;
  final bool? status;

  const OwnerModelBase({
    this.ownerId,
    this.ownerName,
    this.phoneNumber,
    this.status,
  });

  Map<String, dynamic> toMapBase() => {
    'owner_id': ownerId,
    'owner_name': _capitalizeEachWord(ownerName),
    'phone_number': phoneNumber,
    'status': status,
  };
}

String? _capitalizeEachWord(String? name) {
  if (name == null || name.isEmpty) return name;

  return name
      .toLowerCase()
      .split(' ')
      .map(
        (word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
      )
      .join(' ');
}

class CreateOwnerModel extends OwnerModelBase {
  const CreateOwnerModel({
    String? ownerId,
    String? ownerName,
    String? phoneNumber,
    bool? status,
  }) : super(
         ownerId: ownerId,
         ownerName: ownerName,
         phoneNumber: phoneNumber,
         status: status,
       );

  Map<String, dynamic> toMap() => toMapBase();

  factory CreateOwnerModel.fromMap(Map<String, dynamic> data) {
    return CreateOwnerModel(
      ownerId: data['owner_id'] as String?,
      ownerName: data['owner_name'] as String?,
      phoneNumber: data['phone_number'] as String?,
      status: data['status'] as bool?,
    );
  }
}

class UpdateOwnerModel extends OwnerModelBase {
  const UpdateOwnerModel({super.ownerId, super.ownerName, super.phoneNumber});

  Map<String, dynamic> toMap() => toMapBase();
}
