// import 'dart:io';
// import 'package:excel/excel.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:intl/intl.dart';

// Future<void> exportLoanReport(
//   String ownerName,
//   DateTime? selectedMonth,
//   List<Map<String, dynamic>> loanData,
// ) async {
//   // Permissions
//   if (Platform.isAndroid) {
//     if (!await Permission.storage.request().isGranted) {
//       print("Permission denied");
//       return;
//     }
//   }

//   var excel = Excel.createExcel();
//   Sheet sheet = excel['Sheet1'];

//   String monthName = DateFormat('MMMM').format(DateTime(0, selectedMonth));

//   // Report headings
//   sheet.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("H1"));
//   sheet.cell(CellIndex.indexByString("A1")).value = "Report for $monthName";
//   sheet.merge(CellIndex.indexByString("A2"), CellIndex.indexByString("H2"));
//   sheet.cell(CellIndex.indexByString("A2")).value = "Owner: $ownerName";

//   // Column headers
//   sheet.appendRow([
//     'S.No.',
//     'Loan ID',
//     'Customer Name',
//     'Phone Number',
//     'Re-payment Amount',
//     'Is Paid',
//     'Pending Amount',
//     'Total Loan Amount',
//   ]);

//   // Fill data
//   for (int i = 0; i < loanData.length; i++) {
//     final item = loanData[i];
//     sheet.appendRow([
//       i + 1,
//       item['loan_id'] ?? '',
//       item['customer_name'] ?? '',
//       item['customer_phone'] ?? '',
//       item['re-payment_amount'] ?? 0,
//       item['is_paid'] == true ? 'Paid' : 'Pending',
//       item['total_pending_amount'] ?? 0,
//       item['total_loan_amount'] ?? 0,
//     ]);
//   }

//   // Save file
//   final directory = await getExternalStorageDirectory();
//   String fileName = 'Loan_Report_${monthName}_$ownerName.xlsx'.replaceAll(
//     ' ',
//     '_',
//   );
//   String filePath = '${directory!.path}/$fileName';

//   File file =
//       File(filePath)
//         ..createSync(recursive: true)
//         ..writeAsBytesSync(excel.encode()!);

//   print("✅ Excel saved to $filePath");
// }
