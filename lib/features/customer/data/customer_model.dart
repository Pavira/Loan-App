class CustomerModelBase {
  final String? customerId;
  final String? customerName;
  final String? phoneNumber;
  final String? alternatePhoneNumber;
  final String? gender;
  final String? address;

  CustomerModelBase({
    this.customerId = '',
    this.customerName,
    this.phoneNumber,
    this.alternatePhoneNumber,
    this.gender,
    this.address,
  });

  Map<String, dynamic> toMapBase() => {
    'customer_id': customerId,
    'customer_name': _capitalizeEachWord(customerName),
    // Add +91 prefix for Indian phone numbers
    'phone_number':
        phoneNumber != null && phoneNumber!.isNotEmpty
            ? '+91${phoneNumber!.trim()}'
            : '',
    'alternate_phone_number': alternatePhoneNumber,
    'gender': gender,
    'address': address,
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

class CreateCustomerModel extends CustomerModelBase {
  final DateTime? createdDate;
  final DateTime? modifiedDate;
  final String? createdUserName;
  final String? modifiedUserName;

  CreateCustomerModel({
    super.customerName,
    super.phoneNumber,
    super.alternatePhoneNumber,
    super.gender,
    super.address,
    super.customerId,
    this.createdDate,
    this.modifiedDate,
    this.createdUserName,
    this.modifiedUserName,
  });

  Map<String, dynamic> toMap() {
    return {
      ...toMapBase(),
      'customer_id': customerId,
      'created_date': createdDate,
      'modified_date': modifiedDate,
      'created_username': createdUserName,
      'modified_username': modifiedUserName,
    };
  }

  factory CreateCustomerModel.fromMap(Map<String, dynamic> data) {
    return CreateCustomerModel(
      customerId: data['customer_id'],
      customerName: data['customer_name'] ?? '',
      phoneNumber: data['phone_number'] ?? '',
      alternatePhoneNumber: data['alternate_phone_number'],
      gender: data['gender'] ?? '',
      address: data['address'] ?? '',
      createdDate: _parseDate(data['created_date']),
      modifiedDate: _parseDate(data['modified_date']),
      createdUserName: data['created_username'],
      modifiedUserName: data['modified_username'],
    );
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    try {
      return DateTime.parse(date);
    } catch (_) {
      return null;
    }
  }
}

class UpdateCustomerModel extends CustomerModelBase {
  final DateTime? modifiedDate;
  final String? modifiedUserName;

  UpdateCustomerModel({
    super.customerId,
    super.customerName,
    super.phoneNumber,
    super.alternatePhoneNumber,
    super.gender,
    super.address,
    this.modifiedDate,
    this.modifiedUserName,
  });

  Map<String, dynamic> toMap() {
    return {
      ...toMapBase(),
      'modified_date': modifiedDate,
      'modified_username': modifiedUserName,
    };
  }
}
