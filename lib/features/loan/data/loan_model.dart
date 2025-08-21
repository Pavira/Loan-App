class LoanModelBase {
  final String? loanId;
  final String? customerId;
  final String? customerName;
  final String? customerPhoneNumber;
  final String? ownerId;
  final String? ownerName;
  final double? loanAmount;
  final int? loanDuration; // in months
  final double? interestRate;
  final DateTime? dueDate;
  final double? calculatedMonthlyPayment;
  final double? totalInterestAmount;
  final String? security;
  final String? remarks;
  final String? status;
  final double? totalPendingAmount;
  final double? totalFineAmount;

  LoanModelBase({
    this.loanId = '',
    this.customerId,
    this.customerName,
    this.customerPhoneNumber,
    this.ownerId,
    this.ownerName,
    this.loanAmount,
    this.loanDuration,
    this.interestRate,
    this.dueDate,
    this.calculatedMonthlyPayment,
    this.totalInterestAmount,
    this.security,
    this.remarks,
    this.status,
    this.totalPendingAmount,
    this.totalFineAmount,
  });

  Map<String, dynamic> toMapBase() => {
    'loan_id': loanId,
    'customer_id': customerId,
    'customer_name': customerName,
    'customer_phone_number': customerPhoneNumber,
    'owner_name': ownerName,
    'owner_id': ownerId,
    'loan_amount': loanAmount,
    'loan_duration': loanDuration,
    'interest_rate': interestRate,
    'due_date': dueDate,
    'calculated_monthly_payment': calculatedMonthlyPayment,
    'total_interest_amount': totalInterestAmount,
    'security': security,
    'remarks': remarks,
    'status': status,
    'total_pending_amount': totalPendingAmount,
    'total_fine_amount': totalFineAmount,
  };
}

class CreateLoanModel extends LoanModelBase {
  final DateTime? createdDate;
  // final DateTime? modifiedDate;
  // final String? createdUserName;
  // final String? modifiedUserName;

  CreateLoanModel({
    super.loanId,
    super.customerId,
    super.customerName,
    super.customerPhoneNumber,
    super.ownerName,
    super.ownerId,
    super.loanAmount,
    super.loanDuration,
    super.interestRate,
    super.dueDate,
    super.calculatedMonthlyPayment,
    super.totalInterestAmount,
    super.security,
    super.remarks,
    super.status,
    super.totalPendingAmount,
    super.totalFineAmount,
    this.createdDate,
  });

  Map<String, dynamic> toMap() {
    return {
      ...toMapBase(),
      'created_date': createdDate,
      // 'modified_date': modifiedDate?.toIso8601String(),
      // 'created_username': createdUserName,
      // 'modified_username': modifiedUserName,
    };
  }

  factory CreateLoanModel.fromMap(Map<String, dynamic> data) {
    return CreateLoanModel(
      loanId: data['loan_id'] ?? '',
      customerId: data['customer_id'] ?? '',
      customerName: data['customer_name'] ?? '',
      customerPhoneNumber: data['customer_phone_number'] ?? '',
      ownerName: data['owner_name'] ?? '',
      ownerId: data['owner_id'] ?? '',
      loanAmount: (data['loan_amount'] as num?)?.toDouble() ?? 0.0,
      loanDuration: data['loan_duration'] ?? 0,
      interestRate: (data['interest_rate'] as num?)?.toDouble() ?? 0.0,
      dueDate: data['due_date'],
      calculatedMonthlyPayment:
          (data['calculated_monthly_payment'] as num?)?.toDouble() ?? 0.0,
      totalInterestAmount:
          (data['total_interest_amount'] as num?)?.toDouble() ?? 0.0,
      security: data['security'],
      remarks: data['remarks'],
      status: data['status'],
      createdDate: data['created_date'],
      totalPendingAmount:
          (data['total_pending_amount'] as num?)?.toDouble() ?? 0.0,
      totalFineAmount: (data['total_fine_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // static DateTime? _parseDate(dynamic date) {
  //   if (date == null) return null;
  //   try {
  //     return DateTime.parse(date);
  //   } catch (_) {
  //     return null;
  //   }
  // }
}

class UpdateLoanModel extends LoanModelBase {
  final DateTime? modifiedDate;
  final String? modifiedUserName;

  UpdateLoanModel({
    super.loanId,
    super.customerId,
    super.ownerId,
    super.loanAmount,
    super.loanDuration,
    super.interestRate,
    super.dueDate,
    super.calculatedMonthlyPayment,
    super.security,
    super.remarks,
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

class LoanReportModel {
  final String loanId;
  final String customerName;
  final String customerPhone;
  final double repaymentAmount;
  final bool isPaid;
  final double totalLoanAmount;
  final double totalPendingAmount;

  LoanReportModel({
    required this.loanId,
    required this.customerName,
    required this.customerPhone,
    required this.repaymentAmount,
    required this.isPaid,
    required this.totalLoanAmount,
    required this.totalPendingAmount,
  });

  factory LoanReportModel.fromMap(Map<String, dynamic> data) {
    return LoanReportModel(
      loanId: data['loan_id'] ?? '',
      customerName: data['customer_name'] ?? '',
      customerPhone: data['customer_phone'] ?? '',
      repaymentAmount: data['re-payment_amount'] ?? 0.0,
      isPaid: data['is_paid'] ?? false,
      totalLoanAmount: data['total_loan_amount'] ?? 0.0,
      totalPendingAmount: data['total_pending_amount'] ?? 0.0,
    );
  }
}
